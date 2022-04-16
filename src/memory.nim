import winim
import strutils

var screenWidth = 800
var screenHeight = 450

let className: cstring = "RiotWindowClass"
let windowName: cstring = "League of Legends.exe"

var windowHandle = FindWindowA(className, nil);
echo "handle: ", windowHandle

var pid: DWORD
GetWindowThreadProcessId(windowHandle, pid.addr)
echo "pid: ", pid

proc toString(arr: array[0..255, uint16]): string =
  for val in arr:
    if val == 0: break
    result.add(char(val))

proc getModuleBaseAddress(procId: DWORD, modName: cstring): DWORD =
  var modBaseAddr: DWORD = 0
  var hSnap = CreateToolHelp32Snapshot(TH32CS_SNAPMODULE + TH32CS_SNAPMODULE32, procId)
  defer: CloseHandle(hSnap)

  if hSnap != INVALID_HANDLE_VALUE:
    var modEntry: MODULEENTRY32
    modEntry.dwSize = cast[DWORD](sizeof(modEntry))
    if Module32First(hSnap, addr modEntry):
      var szModName = modEntry.szModule.toString()
      echo "name: ", szModName
      echo "modName: ", $modName
      if (cmpIgnoreCase(szModName, $modName) == 0):
        echo "matched!"
        modBaseAddr = cast[DWORD](modEntry.modBaseAddr)
        return modBaseAddr
        
      while Module32Next(hSnap, addr modEntry):
        szModName = modEntry.szModule.toString()
        echo "name: ", szModName
        echo "modName: ", $modName
        if (cmpIgnoreCase(szModName, $modName) == 0):
          echo "matched!"
          modBaseAddr = cast[DWORD](modEntry.modBaseAddr)
          break
  
  return modBaseAddr

var base = getModuleBaseAddress(pid, windowName)

echo "base: ", base

var processHandle = OpenProcess(PROCESS_ALL_ACCESS, 0, pid)

echo "processHandle: ", processHandle


# echo window
# var mem = ReadProcessMemory("League of Legends.exe")
# ReadProcessMemory(processHandle, cast[LPCVOID](base + offset), reinspeichern, sizeOfSpeichern, nil)