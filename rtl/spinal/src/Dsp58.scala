// SPDX-License-Identifier: MIT
package nvfp4

import spinal.core._

/** Versal INT8 Dot3 plus C/CARRYIN, with input and output registers. */
class Dsp58 extends BlackBox {
    setDefinitionName("DSP58")
    noIoPrefix()
    addGeneric("DSP_MODE", "INT8")
    addGeneric("USE_SIMD", "ONE58")
    Seq("AREG", "ACASCREG", "BREG", "BCASCREG", "PREG").foreach(addGeneric(_, 1))
    Seq("CREG", "CARRYINREG", "MREG", "OPMODEREG", "CARRYINSELREG", "ALUMODEREG",
        "ADREG", "DREG", "INMODEREG").foreach(addGeneric(_, 0))

    val io = new Bundle {
        val CLK = in Bool()
        val A = in Bits(34 bits)
        val B = in Bits(24 bits)
        val C = in Bits(58 bits)
        val D = in Bits(27 bits)
        val PCIN = in Bits(58 bits)
        val P = out Bits(58 bits)
        val OPMODE = in Bits(9 bits)
        val ALUMODE = in Bits(4 bits)
        val INMODE = in Bits(5 bits)
        val NEGATE = in Bits(3 bits)
        val CARRYIN = in Bool()
        val CARRYINSEL = in Bits(3 bits)
        val CARRYCASCIN = in Bool()
        val ACIN = in Bits(34 bits)
        val BCIN = in Bits(24 bits)
        val MULTSIGNIN = in Bool()
        val CEA1, CEA2, CEB1, CEB2, CEAD, CEALUMODE, CEC, CECARRYIN,
            CECTRL, CED, CEINMODE, CEM, CEP = in Bool()
        val RSTA, RSTB, RSTC, RSTD, RSTM, RSTP, RSTCTRL, RSTALUMODE,
            RSTINMODE, RSTALLCARRYIN = in Bool()
        val ASYNC_RST = in Bool()
    }

    def connect_control(clk: Bool, rst: Bool, ce: Bool): Unit = {
        io.CLK := clk
        io.OPMODE := B(0x185, 9 bits)
        io.ALUMODE := 0
        io.INMODE := 0
        io.NEGATE := 0
        io.CARRYINSEL := 0
        io.D := 0
        io.PCIN := 0
        io.ACIN := 0
        io.BCIN := 0
        io.CARRYCASCIN := False
        io.MULTSIGNIN := False
        io.ASYNC_RST := False
        Seq(io.CEA1, io.CEA2, io.CEB1, io.CEB2, io.CEAD, io.CEALUMODE, io.CEC,
            io.CECARRYIN, io.CECTRL, io.CED, io.CEINMODE, io.CEM, io.CEP).foreach(_ := ce)
        Seq(io.RSTA, io.RSTB, io.RSTC, io.RSTD, io.RSTM, io.RSTP, io.RSTCTRL,
            io.RSTALUMODE, io.RSTINMODE, io.RSTALLCARRYIN).foreach(_ := rst)
    }
}
