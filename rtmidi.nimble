# Package
const 
  rtmidiVersion = "6.0.0"
  wrapperPatch = "0"

version       = rtmidiVersion & "." & wrapperPatch
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
    "--git.url:https://github.com/stoneface86/nim-rtmidi",
    "--git.commit:" & version,
    "--git.devel:" & "rtmidi-" & rtmidiVersion,
    "-p:" & srcDir,
    "--outdir:htmldocs",
    "doc",
    srcDir / "rtmidi.nim"
  ]
