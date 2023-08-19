##
## Displays all compiled APIs and all available ports in each API.
##
import rtmidi

proc main() =
  let apis = getCompiledApis()
  stdout.write "Compiled APIs: "
  for api in apis:
    stdout.write api.displayName()
    stdout.write ' '
  echo ""

  for api in apis:
    var devIn = initMidiIn(api)
    echo "\nCurrent input API: ", devIn.api().displayName()
    let inPortCount = devIn.portCount()
    echo "\nThere are ", inPortCount, " input ports available."
    for i in 0..<inPortCount:
      echo "  Input Port #", i, ": ", devIn.portName(i)

    var devOut = initMidiOut(api)
    echo "\nCurrent output API: ", devOut.api().displayName()
    let outPortCount = devOut.portCount()
    echo "\nThere are ", outPortCount, " output ports available."
    for i in 0..<outPortCount:
      echo "  Output Port #", i, ": ", devOut.portName(i)

when isMainModule:
  main()

