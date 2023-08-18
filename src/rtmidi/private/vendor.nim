{.used.}

import std/os

func cdefine(def: string): string =
  const definePrefix = when defined(vcc): "/D" else: "-D"
  definePrefix & def

func cinclude(incl: string): string =
  const includePrefix = when defined(vcc): "/I" else: "-I"
  includePrefix & incl

const
  apiDefine = block:
    when defined(linux):
      "__LINUX_ALSA__"
    elif defined(macosx):
      "__MACOSX_CORE__"
    elif defined(windows):
      "__WINDOWS_MM__"
    else:
      {. error: "unsupported operating system" .}
  rtmidiPassc = block:
    var args: seq[string]
    args.add cdefine(apiDefine)
    when defined(vcc):
      args.add "/EHsc"
    quoteShellCommand args

{. compile("rtmidi_c.cpp", rtmidiPassc) .}
{. compile("RtMidi.cpp", rtmidiPassc) .}

{. passc: quoteShell(cinclude(currentSourcePath().parentDir())) .}

# external libraries.
#  - Linux: ALSA, pthreads
#  - MacOS: CoreMIDI, CoreAudio, CoreFoundation
#  - Windows: Windows multimedia library (winmm)
when defined(linux):
  {. passl: "-lasound -lpthread -lstdc++" .}
elif defined(macosx):
  {. passl: "-framework CoreMIDI -framework CoreAudio -framework CoreFoundation -lstdc++" .}
elif defined(windows):
  when defined(vcc):
    {. passl: "winmm.lib" .}
  else:
    {. passl: "-lwinmm" .}
