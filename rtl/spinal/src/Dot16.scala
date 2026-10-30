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

/** Two enabled stages; backpressure freezes the whole datapath. */
class Dot16 extends Component {
    setDefinitionName("nvfp4_dot16")
    noIoPrefix()
    val io = new Bundle {
        val clk, rst, ce, in_valid = in Bool()
        val in_data = in Bits(128 bits)
        val out_valid = out Bool()
        val out_data = out SInt(13 bits)
    }

    val pipeline = new ClockingArea(ClockDomain(
        clock = io.clk, reset = io.rst,
        config = ClockDomainConfig(resetKind = SYNC, resetActiveLevel = HIGH)
    )) {
        val valid_pipe = Reg(Bits(2 bits)) init(0)
        valid_pipe.addAttribute("shreg_extract", "no")
        when(io.ce) { valid_pipe := valid_pipe(0).asBits ## io.in_valid.asBits }
        io.out_valid := valid_pipe(1)

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
        io.out_data := total
    }
}

class Dot16Axis extends Component {
    setDefinitionName("nvfp4_dot16_axis")
    noIoPrefix()
    val io = new Bundle {
        val ap_clk, ap_rst = in Bool()
        val s_axis_tdata = in Bits(128 bits)
        val s_axis_tvalid = in Bool()
        val s_axis_tready = out Bool()
        val m_axis_tdata = out Bits(16 bits)
        val m_axis_tvalid = out Bool()
        val m_axis_tready = in Bool()
    }
    val core = new Dot16
    val advance = !io.ap_rst && (!core.io.out_valid || io.m_axis_tready)
    core.io.clk := io.ap_clk
    core.io.rst := io.ap_rst
    core.io.ce := advance
    core.io.in_valid := io.s_axis_tvalid
    core.io.in_data := io.s_axis_tdata
    io.s_axis_tready := advance
    io.m_axis_tvalid := !io.ap_rst && core.io.out_valid
    io.m_axis_tdata := core.io.out_data.resize(16).asBits
}

class Dot16Fifo extends Component {
    setDefinitionName("nvfp4_dot16_rtl")
    noIoPrefix()
    val io = new Bundle {
        val ap_clk, ap_rst, ap_ce = in Bool()
        val input_dout = in Bits(128 bits)
        val input_empty_n = in Bool()
        val input_read = out Bool()
        val output_din = out Bits(16 bits)
        val output_full_n = in Bool()
        val output_write = out Bool()
    }
    val core = new Dot16
    val advance = !io.ap_rst && io.ap_ce && (!core.io.out_valid || io.output_full_n)
    core.io.clk := io.ap_clk
    core.io.rst := io.ap_rst
    core.io.ce := advance
    core.io.in_valid := io.input_empty_n
    core.io.in_data := io.input_dout
    io.input_read := advance && io.input_empty_n
    io.output_write := !io.ap_rst && io.ap_ce && core.io.out_valid && io.output_full_n
    io.output_din := core.io.out_data.resize(16).asBits
}
