# Package

version       = "4.0.0.0"
author        = "stoneface"
description   = "Bindings for RtMidi, a cross-platform MIDI input/output library"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.4.0"

import std/os

task docs, "Generate documentation":
  selfExec quoteShellCommand [
    "--hints:off",
    "--project",
    "--index:on",
    "-p:" & srcDir,
    "--outdir:htmldocs",
    "doc",
    srcDir / "rtmidi.nim"
  ]
