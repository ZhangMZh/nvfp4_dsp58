// SPDX-License-Identifier: MIT
package nvfp4

import spinal.core._
import java.nio.file.{Files, Path, Paths}

object Generate {
    def main(args: Array[String]): Unit = {
        require(args.length == 1 || (args.length == 2 && args(1) == "--block-scaling"),
            "Usage: nvfp4.Generate OUTPUT_DIRECTORY [--block-scaling]")
        val block_scaling = args.length == 2
        val family = if (block_scaling) "nvfp4_scaled_dot16" else "nvfp4_dot16"
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
        // Elaborate only the selected mode; each family has distinct module/file names.
        config(output.resolve("axis")).generateSystemVerilog(new Dot16Axis(block_scaling))
        config(output.resolve("fifo")).generateSystemVerilog(new Dot16Fifo(block_scaling))
        Seq("axis" -> s"$family.sv", "axis" -> s"${family}_axis.sv",
            "fifo" -> s"${family}_rtl.sv").foreach { case (wrapper, file) =>
            val content = Files.readString(output.resolve(wrapper).resolve(file))
            Files.writeString(output.resolve(file),
                content.linesIterator.map(_.stripTrailing).mkString("", "\n", "\n"))
        }
        println(s"Generation runtime: Java ${System.getProperty("java.version")}, Scala ${util.Properties.versionNumberString}")
        println("DOT16_GENERATION_PASS")
    }
}
