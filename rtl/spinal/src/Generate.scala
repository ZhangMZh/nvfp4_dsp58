// SPDX-License-Identifier: MIT
package nvfp4

import spinal.core._
import java.nio.file.{Files, Path, Paths}

object Generate {
    def main(args: Array[String]): Unit = {
        require(args.length == 1, "Usage: nvfp4.Generate OUTPUT_DIRECTORY")
        val output = Paths.get(args(0)).toAbsolutePath
        val header = "SPDX-License-Identifier: MIT\nGenerated from rtl/spinal/; edit Scala and run cmake --build <build-dir> --target rtl-gen."
        def config(directory: Path) = SpinalConfig(
            targetDirectory = directory.toString,
            oneFilePerComponent = true,
            headerWithDate = false,
            headerWithRepoHash = false,
            genLineComments = false,
            rtlHeader = header
        )
        // Elaborate each public wrapper and collect the three public modules.
        config(output.resolve("axis")).generateSystemVerilog(new Dot16Axis)
        config(output.resolve("fifo")).generateSystemVerilog(new Dot16Fifo)
        val core = "nvfp4_dot16.sv"
        Seq("axis" -> core, "axis" -> "nvfp4_dot16_axis.sv", "fifo" -> "nvfp4_dot16_rtl.sv")
            .foreach { case (directory, file) =>
                Files.copy(output.resolve(directory).resolve(file), output.resolve(file),
                    java.nio.file.StandardCopyOption.REPLACE_EXISTING)
            }
        // Spinal emits SInt as unsigned vectors with explicit signed casts internally.
        // Preserve the existing signed public Verilog port for external consumers.
        val core_path = output.resolve(core)
        val core_text = Files.readString(core_path)
        val signed_port = "(?m)^(\\s*output\\s+wire\\s+)(\\[12:0\\]\\s+out_data\\b)".r
        require(signed_port.findAllIn(core_text).size == 1, "Unexpected core output declaration")
        Files.writeString(core_path, signed_port.replaceFirstIn(core_text, "$1signed $2"))
        Seq(core, "nvfp4_dot16_axis.sv", "nvfp4_dot16_rtl.sv").foreach { file =>
            val path = output.resolve(file)
            Files.writeString(path, Files.readString(path).linesIterator.map(_.stripTrailing).mkString("", "\n", "\n"))
        }
        println(s"Generation runtime: Java ${System.getProperty("java.version")}, Scala ${util.Properties.versionNumberString}")
        println("DOT16_GENERATION_PASS")
    }
}
