
# nim-rtmidi

Nim wrapper for RtMidi, a cross-platform realtime MIDI input/output library.
This wrapper contains both low-level bindings and a high-level API. 

## Versioning

This library uses the same versioning as RtMidi, adding an extra patch number.
For example version `4.0.0.1` uses RtMidi version `4.0.0`, and the wrapper's
version is `1`.

The following versions are available:

| RtMidi version | Status      |
|----------------|-------------|
| 4.0.0          | In progress |
| 5.0.0          | not started |
| 6.0.0          | not started |

## Dependencies

Nim v1.4.0 and up is required.

A vendored copy of RtMidi is included in this repository when linking
statically, so you will need to install RtMidi's dependencies:

 - Linux:   ALSA development libraries
 - OSX:     None
 - Windows: None

## Install

Install via nimble:

```sh
nimble install "https://github.com/stoneface86/nim-rtmidi"
```

Then use in your project:

```nim
# high-level API
import rtmidi
# and/or you want bindings
# import rtmidi/bindings
```

## Options

| Define        | Default       | Description                                      |
|---------------|---------------|--------------------------------------------------|
| rtmidiUseJack | not present   | Enables compilation of the JACK backend          |
| rtmidiUseDll  | not present   | Dynamic link to rtmidi instead of static linking |
| rtmidiDll     | depends on OS | Set the name of the rtmidi dynamic library used  |

Support for the JACK API is not compiled in by default, so define
`rtmidiUseJack` to enable it when static linking.

Static linking is done by default, define `rtmidiUseDll` to link dynamically.
By default the DLL file used depends on your OS:

 - Linux: `librtmidi.so`
 - MacOS: `librtmidi.dylib`
 - Windows: `rtmidi.dll`

Define `rtmidiDll` to override this filename.
