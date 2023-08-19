## Opens an input MIDI port and prints received MIDI messages to stdout
## 
## usage: cmidiin [portNum]
## 
## If portNum is not provided then you will be prompted for one.
## 


when NimMajor >= 2:
  import std/cmdline
else:
  import std/os

import std/[strformat, strutils]
import rtmidi

proc usage() =
  stderr.writeLine "usage: cmidiin <port>"
  quit(2)

proc midiInCallback(timestamp: float64; msg: openArray[byte]) {.thread.} =
  stdout.write &"{timestamp:9.7f}: "
  for b in msg:
    stdout.write toHex(b)
    stdout.write ' '
  echo ""

proc parsePort(portstr: string): int =
  try:
    result = parseInt(portstr)
  except ValueError:
    stderr.writeLine "error: invalid port number"
    return -1
  if result < 0:
    stderr.writeLine "error: port number must be >= 0"
    result = -1


proc main() =
  let cmd = commandLineParams()
  if cmd.len notin 0..1:
    usage()
    
  var dev = initMidiIn()

  var port: int
  if cmd.len == 1:
    port = parsePort(cmd[0])
    if port == -1:
      usage()
  else:
    for i in 0..<dev.portCount():
      echo "Port #", i, ": ", dev.portName(i)
    while true:
      stdout.write "Please select a port: "
      port = parsePort(stdin.readLine())
      if port != -1: break

  
  dev.openPort(port, "")
  dev.setCallback(midiInCallback)

  echo "Reading MIDI input ... press <enter> to quit."
  discard stdin.readLine()

  

when isMainModule:
  main()
