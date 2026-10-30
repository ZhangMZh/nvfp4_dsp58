// SPDX-License-Identifier: MIT
ThisBuild / scalaVersion := "2.13.14"

val spinal_version = "1.15.0"
libraryDependencies ++= Seq(
    "com.github.spinalhdl" %% "spinalhdl-core" % spinal_version,
    "com.github.spinalhdl" %% "spinalhdl-lib" % spinal_version,
    compilerPlugin("com.github.spinalhdl" %% "spinalhdl-idsl-plugin" % spinal_version)
)
Compile / scalaSource := baseDirectory.value / "src"
Compile / run / fork := true
