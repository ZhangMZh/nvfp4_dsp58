// SPDX-License-Identifier: MIT
package nvfp4

import spinal.core._

object E2m1 {
    private val magnitudes = Seq(0, 1, 2, 3, 4, 6, 8, 12)

    def decode(code: Bits): SInt = {
        val value = SInt(5 bits)
        value.assignDontCare()
        switch(code) {
            for (i <- 0 until 16) {
                is(B(i, 4 bits)) {
                    value := S(if (i < 8) magnitudes(i) else -magnitudes(i & 7), 5 bits)
                }
            }
        }
        value
    }

    // Multiplication happens in Scala; generated hardware is a combinational truth table.
    def magnitude_product(a: Bits, b: Bits): Bits = {
        val value = Bits(8 bits)
        value.assignDontCare()
        switch(a ## b) {
            for (i <- 0 until 8; j <- 0 until 8) {
                is(B(i * 8 + j, 6 bits)) { value := B(magnitudes(i) * magnitudes(j), 8 bits) }
            }
        }
        value
    }
}

/** Two or five enabled stages; backpressure freezes the whole datapath. */
class Dot16(block_scaling: Boolean) extends Component {
    setDefinitionName(if (block_scaling) "nvfp4_scaled_dot16" else "nvfp4_dot16")
    noIoPrefix()
    val io = new Bundle {
        val clk, rst, ce, in_valid = in Bool()
        val in_data = in Bits((if (block_scaling) 144 else 128) bits)
        val out_valid = out Bool()
        val out_data = out SInt((if (block_scaling) 48 else 13) bits)
        val out_invalid = if (block_scaling) out Bool() else null
    }

    val pipeline = new ClockingArea(ClockDomain(
        clock = io.clk, reset = io.rst,
        config = ClockDomainConfig(resetKind = SYNC, resetActiveLevel = HIGH)
    )) {
        val valid_pipe = Reg(Bits(2 bits)) init(0)
        valid_pipe.addAttribute("shreg_extract", "no")
        when(io.ce) { valid_pipe := valid_pipe(0).asBits ## io.in_valid.asBits }

        val groups = (0 until 4).map(g => new Area {
            val a = io.in_data(g * 16 + 15 downto g * 16)
            val b = io.in_data(64 + g * 16 + 15 downto 64 + g * 16)
            val a_port = Bits(27 bits)
            val b_port = Bits(24 bits)
            for (k <- 0 until 3) {
                a_port(k * 9 + 8 downto k * 9) := E2m1.decode(a(k * 4 + 3 downto k * 4)).resize(9).asBits
                b_port(k * 8 + 7 downto k * 8) := E2m1.decode(b(k * 4 + 3 downto k * 4)).resize(8).asBits
            }

            val magnitude = E2m1.magnitude_product(a(14 downto 12), b(14 downto 12))
            val sign = a(15) ^ b(15)
            val complement = (B(0, 1 bits) ## magnitude) ^ Mux(sign, B(511, 9 bits), B(0, 9 bits))
            // Keep this register in fabric for hold repair, aligned with DSP AREG/BREG.
            val fourth_pipe = Reg(Bits(10 bits)) init(0)
            fourth_pipe.addAttribute("dont_touch", "yes")
            when(io.ce) { fourth_pipe := sign.asBits ## complement }

            val dsp = new Dsp58
            dsp.connect_control(io.clk, io.rst, io.ce)
            dsp.io.A := a_port.asSInt.resize(34).asBits
            dsp.io.B := b_port
            dsp.io.C := fourth_pipe(8 downto 0).asSInt.resize(58).asBits
            dsp.io.CARRYIN := fourth_pipe(9)
            val sum = dsp.io.P(10 downto 0).asSInt
        })

        // Explicit widening at both fabric adder levels; no final output register.
        val pair_left = groups(0).sum.resize(12) + groups(1).sum.resize(12)
        val pair_right = groups(2).sum.resize(12) + groups(3).sum.resize(12)
        val total = pair_left.resize(13) + pair_right.resize(13)
        Seq(pair_left, pair_right, total).foreach(_.addAttribute("use_dsp", "no"))
        val scaling = if (block_scaling) new Area {
            // Every register, including metadata, uses the same CE and synchronous reset.
            def stage[T <: Data](value: T): T = {
                val delayed = Reg(cloneOf(value)) init(value.getZero)
                // SRL-to-FF dedicated routes cannot repair hold with 100 ps uncertainty.
                delayed.addAttribute("shreg_extract", "no")
                when(io.ce) { delayed := value }
                delayed
            }
            val scales = (0 until 2).map(i => new Area {
                val code = io.in_data(128 + 8 * i + 7 downto 128 + 8 * i)
                val exponent = code(6 downto 3).asUInt
                val fraction = code(2 downto 0).asUInt
                val invalid = code(6 downto 0) === B(127, 7 bits)
                val magnitude = UInt(4 bits)
                magnitude := U(8, 4 bits) | fraction.resize(4)
                when(exponent === 0) { magnitude := fraction.resize(4) }
                when(invalid) { magnitude := 0 }
                val mantissa = magnitude.resize(5).asSInt
                val signed_mantissa = Mux(code(7), -mantissa, mantissa)
                val shift = Mux(exponent === 0, U(0, 4 bits), exponent - 1)
                val m1 = stage(signed_mantissa)
                val h1 = stage(shift)
                val invalid1 = stage(invalid)
            })
            val mantissa_product = scales(0).m1 * scales(1).m1
            mantissa_product.addAttribute("use_dsp", "no")
            val k2 = stage(mantissa_product.resize(9))
            val h2 = stage(scales(0).h1.resize(5) + scales(1).h1.resize(5))
            val invalid2 = stage(scales(0).invalid1 || scales(1).invalid1)

            val q3 = stage(total)
            val k3 = stage(k2)
            val h3 = stage(h2)
            val invalid3 = stage(invalid2)
            val product = q3 * k3
            product.addAttribute("use_dsp", "yes")
            // |Q*K| <= 2304*225 = 518400 < 2^19; signed 20 bits are exact.
            val p4 = stage(product.resize(20))
            val h4 = stage(h3)
            val invalid4 = stage(invalid3)
            val shifted5 = stage((p4.resize(48) |<< h4).resize(48))
            shifted5.addAttribute("dont_touch", "yes")
            io.out_data := shifted5
            io.out_invalid := stage(invalid4)
            io.out_valid := (0 until 3).foldLeft(valid_pipe(1))((valid, _) => stage(valid))
        } else {
            io.out_data := total
            io.out_valid := valid_pipe(1)
            null
        }
    }
}

class Dot16Axis(block_scaling: Boolean) extends Component {
    setDefinitionName(if (block_scaling) "nvfp4_scaled_dot16_axis" else "nvfp4_dot16_axis")
    noIoPrefix()
    val io = new Bundle {
        val ap_clk, ap_rst = in Bool()
        val s_axis_tdata = in Bits((if (block_scaling) 144 else 128) bits)
        val s_axis_tvalid = in Bool()
        val s_axis_tready = out Bool()
        val m_axis_tdata = out Bits((if (block_scaling) 64 else 16) bits)
        val m_axis_tvalid = out Bool()
        val m_axis_tready = in Bool()
    }
    val core = new Dot16(block_scaling)
    val advance = !io.ap_rst && (!core.io.out_valid || io.m_axis_tready)
    core.io.clk := io.ap_clk
    core.io.rst := io.ap_rst
    core.io.ce := advance
    core.io.in_valid := io.s_axis_tvalid
    core.io.in_data := io.s_axis_tdata
    io.s_axis_tready := advance
    io.m_axis_tvalid := !io.ap_rst && core.io.out_valid
    io.m_axis_tdata := (if (block_scaling)
        B(0, 15 bits) ## core.io.out_invalid.asBits ## core.io.out_data.asBits
    else core.io.out_data.resize(16).asBits)
}

class Dot16Fifo(block_scaling: Boolean) extends Component {
    setDefinitionName(if (block_scaling) "nvfp4_scaled_dot16_rtl" else "nvfp4_dot16_rtl")
    noIoPrefix()
    val io = new Bundle {
        val ap_clk, ap_rst, ap_ce = in Bool()
        val input_dout = in Bits((if (block_scaling) 144 else 128) bits)
        val input_empty_n = in Bool()
        val input_read = out Bool()
        val output_din = out Bits((if (block_scaling) 64 else 16) bits)
        val output_full_n = in Bool()
        val output_write = out Bool()
    }
    val core = new Dot16(block_scaling)
    val advance = !io.ap_rst && io.ap_ce && (!core.io.out_valid || io.output_full_n)
    core.io.clk := io.ap_clk
    core.io.rst := io.ap_rst
    core.io.ce := advance
    core.io.in_valid := io.input_empty_n
    core.io.in_data := io.input_dout
    io.input_read := advance && io.input_empty_n
    io.output_write := !io.ap_rst && io.ap_ce && core.io.out_valid && io.output_full_n
    io.output_din := (if (block_scaling)
        B(0, 15 bits) ## core.io.out_invalid.asBits ## core.io.out_data.asBits
    else core.io.out_data.resize(16).asBits)
}
