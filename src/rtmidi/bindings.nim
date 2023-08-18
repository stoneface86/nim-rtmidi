import private/vendor

# type
#   CStdException* {. importcpp: "std::exception", header: "<exception>", inheritable.} = object
#   CStdString* {. importcpp: "std::string", header: "<string>" .} = object
#   CStdVec*[T] {. importcpp: "std::vector", header: "<vector>" .} = object

# proc cppString*(str: cstring): CStdString
#   {. importcpp: "std::string(@)", constructor .}


# {. push header: "RtMidi.h" .}

# type
#   MidiApi {. importcpp, incompleteStruct .}= object
    
#   RtMidiErrorType* {. importcpp: "RtMidiError::Type", size: sizeof(cint) .} = enum
#     warning
#     debugWarning
#     unspecified
#     noDevicesFound
#     invalidDevice
#     memoryError
#     invalidParameter
#     invalidUse
#     driverError
#     systemError
#     threadError
  
#   RtMidiError* {. importcpp .} = object of CStdException
#     message: CStdString
#     `type`: RtMidiErrorType
  
#   RtMidiErrorCallback* = proc(ty: RtMidiErrorType; text: CStdString; data: pointer) {.noconv.}

#   RtMidi* {. importcpp, inheritable .} = object
#     api: ptr MidiApi
  
#   RtMidiApi* {. importcpp: "RtMidi::Api", size: sizeof(cint) .} = enum
#     unspecified
#     macosxCore
#     linuxAlsa
#     unixJack
#     windowsMM
#     rtmidiDummy

#   RtMidiIn* {. importcpp .} = object of RtMidi
#   RtMidiOut* {. importcpp .} = object of RtMidi

#   RtMidiCallback* {. importcpp: "RtMidiIn::RtMidiCallback" .} = proc(timestamp: float64; msg: ptr CStdVec[uint8]; data: pointer)

# {. push noconv .}

# # === RtMidiError ===

# proc init*(_: typedesc[RtMidiError]; msg: CStdString;
#            ty = RtMidiErrorType.unspecified): RtMidiError
#   {. importcpp: "RtMidiError(@)", constructor .}

# proc printMessage*(e: RtMidiError) {. importcpp: "#.printMessage()" .}
# proc getType*(e: RtMidiError): RtMidiErrorType {. importcpp: "#.getType()" .}
# proc getMessage*(e: RtMidiError): CStdString {. importcpp: "#.getMessage()" .}
# proc what*(e: RtMidiError): cstring {. importcpp: "#.what()" .}

# # === RtMidi ===

# # static functions
# proc getVersion*(_: typedesc[RtMidi]): CStdString
#   {. importcpp: "RtMidi::getVersion()" .}
# proc getCompiledApi*(_: typedesc[RtMidi]; apis: var CStdVec[RtMidiApi])
#   {. importcpp: "RtMidi::getCompiledApi(@)" .}
# proc getApiName*(_: typedesc[RtMidi]; api: RtMidiApi): CStdString
#   {. importcpp: "RtMidi::getApiName(@)" .}
# proc getApiDisplayName*(_: typedesc[RtMidi]; api: RtMidiApi): CStdString
#   {. importcpp: "RtMidi::getApiDisplayName(@)" .}
# proc getCompiledApiByName*(_: typedesc[RtMidi]; name: CStdString): RtMidiApi
#   {. importcpp: "RtMidi::getCompiledApiByName(@)" .}

# # member functions
# proc openPort*(m: var RtMidi; portNum: cuint = 0; portName = cppString("RtMidi"))
#   {. importcpp: "#.openPort(@)" .}
# proc openVirtualPort*(m: var RtMidi; portName = cppString("RtMidi"))
#   {. importcpp: "#.openVirtualPort(@)" .}
# proc getPortCount*(m: var RtMidi): cuint
#   {. importcpp: "#.getPortCount()" .}
# proc getPortName*(m: var RtMidi; portNum: cuint = 0): CStdString
#   {. importcpp: "#.getPortName(@)" .}
# proc setClientName*(m: var RtMidi; clientName: CStdString)
#   {. importcpp: "#.setClientName(@)" .}
# proc setPortName*(m: var RtMidi; portName: CStdString)
#   {. importcpp: "#.setPortName(@)" .}
# proc isPortOpen*(m: RtMidi): bool
#   {. importcpp: "#.isPortOpen()" .}
# proc setErrorCallback*(m: var RtMidi; callback: RtMidiErrorCallback = nil; data: pointer = nil)
#   {. importcpp: "#.setErrorCallback(@)" .}

# # === RtMidiIn ===
# proc init*(_: typedesc[RtMidiIn]; api = RtMidiApi.unspecified;
#            clientName = cppString("RtMidi Input Client");
#            queueLimit: cint = 100): RtMidiIn
#   {. importcpp: "RtMidiIn(@)", constructor .}
# proc openPort*(m: var RtMidiIn; portNum: cuint = 0; portName = cppString("RtMidi Input"))
#   {. importcpp: "#.openPort(@)" .}
# proc openVirtualPort*(m: var RtMidiIn; portName = cppString("RtMidi Input"))
#   {. importcpp: "#.openVirtualPort(@)" .}
# proc setCallback*(m: var RtMidiIn; callback: RtMidiCallback; data: pointer = nil)
#   {. importcpp: "#.setCallback(@)" .}
# proc cancelCallback*(m: var RtMidiIn)
#   {. importcpp: "#.cancelCallback()" .}
# proc closePort*(m: var RtMidiIn)
#   {. importcpp: "#.closePort()" .}
# proc isPortOpen*(m: RtMidiIn): bool
#   {. importcpp: "#.isPortOpen()" .}
# proc getPortCount*(m: var RtMidiIn): cuint
#   {. importcpp: "#.getPortCount()" .}
# proc getPortName*(m: var RtMidiIn; portNum: cuint = 0): CStdString
#   {. importcpp: "#.getPortName(@)" .}
# proc ignoreTypes*(m: var RtMidiIn; midiSysex = true; midiTime = true; midiSense = true)
#   {. importcpp: "#.ignoreTypes(@)" .}
# proc getMessage*(m: var RtMidiIn; message: ptr CstdVec[byte]): float64
#   {. importcpp: "#.getMessage(@)" .}
# proc setErrorCallback*(m: var RtMidiIn; callback: RtMidiErrorCallback = nil;
#                        data: pointer = nil)
#   {. importcpp: "#.setErrorCallback(@)" .}

# === RtMidiOut ===

{. push header: "rtmidi_c.h" .}

type
  RtMidiWrapper* {.importc: "struct RtMidiWrapper".} = object
    `ptr`*: pointer
    data*: pointer
    ok*: bool
    msg*: cstring
  
  RtMidiPtr* {.importc.} = ptr RtMidiWrapper
  RtMidiInPtr* {.importc.} = ptr RtMidiWrapper
  RtMidiOutPtr* {.importc.} = ptr RtMidiWrapper

  RtMidiApi* {. importc: "enum RtMidiApi", size: sizeof(cint) .} = enum
    RTMIDI_API_UNSPECIFIED
    RTMIDI_API_MACOSX_CORE
    RTMIDI_API_LINUX_ALSA
    RTMIDI_API_UNIX_JACK
    RTMIDI_API_WINDOWS_MM
    RTMIDI_API_RTMIDI_DUMMY
    RTMIDI_API_NUM
  
  RtMidiErrorType* {. importc: "enum RtMidiErrorType", size: sizeof(cint) .} = enum
    RTMIDI_ERROR_WARNING
    RTMIDI_ERROR_DEBUG_WARNING
    RTMIDI_ERROR_UNSPECIFIED
    RTMIDI_ERROR_NO_DEVICES_FOUND
    RTMIDI_ERROR_INVALID_DEVICE
    RTMIDI_ERROR_MEMORY_ERROR
    RTMIDI_ERROR_INVALID_PARAMETER
    RTMIDI_ERROR_INVALID_USE
    RTMIDI_ERROR_DRIVER_ERROR
    RTMIDI_ERROR_SYSTEM_ERROR
    RTMIDI_ERROR_THREAD_ERROR

  RtMidiCCallback* {.importc.} = proc(timestamp: float64; msg: ptr UncheckedArray[byte]; msgSize: csize_t; userData: pointer) {.noconv.}

{. pop .}
{. push header: "rtmidi_c.h", importc, noconv .}

# general
proc rtmidi_get_compiled_api*(apis: ptr RtMidiApi; len: cuint): cint
proc rtmidi_api_name*(api: RtMidiApi): cstring
proc rtmidi_api_display_name*(api: RtMidiApi): cstring
proc rtmidi_compiled_api_by_name*(name: cstring): RtMidiApi
proc rtmidi_error*(ty: RtMidiErrorType; msg: cstring)

# in/out
proc rtmidi_open_port*(device: RtMidiPtr; portNum: cuint; portName: cstring)
proc rtmidi_open_virtual_port*(device: RtMidiPtr; portName: cstring)
proc rtmidi_close_port*(device: RtMidiPtr)
proc rtmidi_get_port_count*(device: RtMidiPtr): cuint
proc rtmidi_get_port_name*(device: RtMidiPtr; portNum: cuint): cstring

# in
proc rtmidi_in_create_default*(): RtMidiInPtr
proc rtmidi_in_create*(api: RtMidiApi; clientName: cstring; queueSizeLimit: cuint): RtMidiInPtr
proc rtmidi_in_free*(device: RtMidiInPtr)
proc rtmidi_in_get_current_api*(device: RtMidiInPtr): RtMidiApi
proc rtmidi_in_set_callback*(device: RtMidiInPtr; callback: RtMidiCCallback; data: pointer)
proc rtmidi_in_cancel_callback*(device: RtMidiInPtr)
proc rtmidi_in_ignore_types*(device: RtMidiInPtr; midiSysex, midiTime, midiSense: bool; )
proc rtmidi_in_get_message*(device: RtMidiInPtr; message: ptr byte; size: ptr csize_t): float64

# out
proc rtmidi_out_create_default*(): RtMidiOutPtr
proc rtmidi_out_create*(api: RtMidiApi; clientName: cstring): RtMidiOutPtr
proc rtmidi_out_free*(dev: RtMidiOutPtr)
proc rtmidi_out_get_current_api*(dev: RtMidiOutPtr): RtMidiApi
proc rtmidi_out_send_message*(dev: RtMidiOutPtr; msg: ptr byte; len: cint): cint

{. pop .}
