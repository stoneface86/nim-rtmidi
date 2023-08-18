##
## High-level API for RtMidi
## 
## This module provides a high-level wrapper over the rtmidi bindings. The
## C API for rtmidi is wrapped so you can use either the C or C++ backends.
## 
## Usage:
## 
## Create a MidiIn object to receive MIDI data or a MidiOut object to send
## data. For both types you can query the devices (ports) available as well as
## their names. Then open a port to send/receive data.
## 
## ```nim
## var dev = midiIn() # midiOut() for output
## # dev.portCount()
## # dev.portName(num)
## # dev.portOpen(num)
## # etc
## ```
## 
## For receiving data with MidiIn, you can either use a callback to handle the
## data as soon as it comes in, or poll for it manually. Use `setCallback` to
## register the callback, or use `recv` to receive the message manually. Care
## is needed when using a callback, as a foreign thread managed by RtMidi will
## call it.
## 
## For sending data with MidiOut, using the `send` proc to send an array of
## bytes to a previously opened port.
## 
## Error Handling:
## 
## The RtMidi C API catches any RtMidi exception and stores its error message.
## Therefore, none of the procs in this module will raise exceptions. You can
## check for errors by using the `ok` proc, which will return `false` on a
## Midi object if the last proc called on it caused an error. For example:
## 
## ```nim
## if not device.ok:
##   stderr.writeLine("midi error: " & device.getError())
##   quit(1)
## ```
##


import rtmidi/bindings

type
  MidiCallback* = proc(timestamp: float64; msg: openArray[byte]) {.thread.}
    ## Callback procedure type for incoming MIDI messages. The `thread` pragma
    ## is attached since this proc is called from a thread that is managed by
    ## RtMidi. When using a callback, make sure your procedure is thread-safe.
    ## 
    ## **GC-safety**: When using GC, you must ensure this callback does not call
    ## any code that uses the GC. If this is unavoidable, then consider using
    ## `setupForeignThreadGc` and `tearDownForeignThreadGc`. Or use ARC/ORC.
    ##
  
  MidiIn* = object
    ## MIDI input interface. Allows you to query available MIDI input ports and
    ## open one to recieve incoming data from a connected MIDI device.
    ##
    impl*: RtMidiInPtr
      ## Implementation. Contains a reference to an RtMidiIn.
      ##
    callback: MidiCallback
  
  MidiOut* = object
    ## MIDI output. Allows you to query available MIDI output ports and open
    ## one to send data to a connected MIDI device.
    ##
    impl*: RtMidiOutPtr
      ## Implementation. Contains a reference to an RtMidiOut.
      ##
    callback: MidiCallback

  SomeMidi* = MidiIn | MidiOut
    ## Type class for some MIDI interface.
    ##

  MidiApi* = enum
    ## Available MIDI backends/providers.
    ##
    maUnspecified ## No specific API / use default
    maMacosxCore  ## MacOS CoreMIDI
    maLinuxAlsa   ## Linux ALSA
    maUnixJack    ## Unix JACK
    maWindowsMM   ## Windows MultiMedia (winmm)
    maDummy       ## RtMidi Dummy
  
  MidiError* = enum
    ## A category of error that has occurred
    ## 
    meWarning
    meDebugWarning
    meUnspecified
    meNoDevicesFound
    meInvalidDevice
    meMemory
    meInvalidParameter
    meInvalidUse
    meDriver
    meSystem
    meThread
  
  MidiMsgType* = enum
    ## Special MIDI message types, for filtering incoming data.
    ##
    midiSysex
    midiTime
    midiSense

when NimMajor >= 2:
  {. push warning[Deprecated]:off .}

proc `=destroy`*(dev: var MidiIn) =
  if dev.impl != nil:
    rtmidi_in_free(dev.impl)
    dev.impl = nil

proc `=destroy`*(dev: var MidiOut) =
  if dev.impl != nil:
    rtmidi_out_free(dev.impl)
    dev.impl = nil

when NimMajor >= 2:
  {. pop .}

proc `=copy`*(dst: var MidiIn; src: MidiIn) {.error.}
proc `=copy`*(dst: var MidiOut; src: MidiOut) {.error.}


proc ok*(m: SomeMidi): bool =
  ## Returns `true` when the last function call using this Midi device had
  ## no error.
  ##
  result = m.impl[].ok

proc getError*(m: SomeMidi): string =
  ## Gets the error message that occurred if `m.ok` was `false`.
  ##
  result = $(m.impl[].msg)

proc getCompiledApis*(): set[MidiApi] =
  ## Gets all MIDI API support that was compiled with this version of RtMidi.
  ##
  var arr: array[RTMIDI_API_NUM.ord, RtMidiApi]
  let len = rtmidi_get_compiled_api(arr[0].addr, arr.len.cuint).int
  for i in 0..<len:
    result.incl cast[MidiApi](arr[i])

proc name*(api: MidiApi): string =
  ## Get the name of the `api`.
  ##
  $(rtmidi_api_name(cast[RtMidiApi](api)))

proc displayName*(api: MidiApi): string =
  ## Get a presentable name of the `api`.
  ##
  $(rtmidi_api_display_name(cast[RtMidiApi](api)))

proc getApiByName*(name: string): MidiApi =
  ## Gets a MidiApi enum from the given name. `MidiApi.unspecified` is returned
  ## if no such api was found.
  ##
  cast[MidiApi](rtmidi_compiled_api_by_name(name.cstring))

proc error*(ty: MidiError; errorStr: string) =
  ## Report an error with the given type and message.
  ##
  rtmidi_error(cast[RtMidiErrorType](ty), errorStr.cstring)

proc openPort*(dev: var SomeMidi; portNum: Natural = 0; portName = "RtMidi") =
  ## Opens a MIDI port `portNum` with a given name.
  ##
  rtmidi_open_port(dev.impl, portNum.cuint, portName.cstring)

proc openVirtualPort*(dev: var SomeMidi; portName: string) =
  ## Opens a virtual MIDI port. Only supported on the JACK, ALSA and CoreMIDI
  ## backends.
  ##
  rtmidi_open_virtual_port(dev.impl, portName.cstring)

proc closePort*(dev: var SomeMidi) =
  ## Closes the opened port.
  ##
  rtmidi_close_port(dev.impl)

proc portCount*(dev: SomeMidi): int =
  ## Gets the number of available ports.
  ##
  rtmidi_get_port_count(dev.impl).int

proc portName*(dev: SomeMidi; portNum: Natural): string =
  ## Gets the name of the given port.
  ##
  $(rtmidi_get_port_name(dev.impl, portNum.cuint))

proc midiIn*(): MidiIn =
  ## Creates a `MidiIn` for receiving incoming MIDI data, using default
  ## settings.
  ##
  MidiIn(impl: rtmidi_in_create_default())

proc midiIn*(api: MidiApi; clientName: string; queueSizeLimit: Natural): MidiIn =
  ## Creates a `MidiIn` with the given api, client name and queue size limit.
  ##
  MidiIn(impl: rtmidi_in_create(
    cast[RtMidiApi](api),
    clientName.cstring,
    queueSizeLimit.cuint
  ))

proc api*(dev: MidiIn): MidiApi =
  cast[MidiApi](rtmidi_in_get_current_api(dev.impl))

proc callbackWrapper(timestamp: float64; msg: ptr UncheckedArray[byte]; msgSize: csize_t; data: pointer) {.noconv.} =
  cast[ptr MidiCallback](data)[](
    timestamp,
    toOpenArray(msg, 0, msgSize.int)
  )

proc removeCallback*(dev: var MidiIn) =
  dev.callback = nil
  rtmidi_in_cancel_callback(dev.impl)

proc setCallback*(dev: var MidiIn; callback: MidiCallback) =
  if callback == nil:
    dev.removeCallback()
  else:
    dev.callback = callback
    rtmidi_in_set_callback(dev.impl, callbackWrapper, unsafeAddr(dev.callback))

proc ignoreTypes*(dev: var MidiIn; msgTypes: set[MidiMsgType]) =
  rtmidi_in_ignore_types(
    dev.impl,
    midiSysex in msgTypes,
    midiTime in msgTypes,
    midiSense in msgTypes
  )

proc recv*(dev: var MidiIn; msg: var seq[byte]): float64 =
  const maxMsgLen = 1024
  var 
    msgsize = maxMsgLen
    msgbuf: array[maxMsgLen, byte]
  result = rtmidi_in_get_message(
    dev.impl,
    msgbuf[0].addr,
    cast[ptr csize_t](msgsize.addr)
  )
  msg.setLen(msgsize.int)
  if msgsize > 0:
    copyMem(msg[0].addr, msgbuf[0].addr, msgsize.int)

proc midiOut*(): MidiOut =
  MidiOut(impl: rtmidi_out_create_default())

proc midiOut*(api: MidiApi; clientName: string): MidiOut =
  MidiOut(impl: rtmidi_out_create(
    cast[RtMidiApi](api), clientName.cstring
  ))

proc api*(dev: MidiOut): MidiApi =
  cast[MidiApi](rtmidi_out_get_current_api(dev.impl))

proc send*(dev: var MidiOut; msg: openArray[byte]): int {.discardable.} =
  rtmidi_out_send_message(dev.impl, msg[0].unsafeAddr, msg.len.cint).int
