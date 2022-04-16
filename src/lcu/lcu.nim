import std/[sequtils, strformat, strutils, options]
import psutil/psutil_linux
import ../log
from slicerator import zipIter

proc findProcessId*(name: string = "LeagueClientUx"): tuple[id: int, args: seq[string]] =
    logThreaded(lvlDebug, fmt"findProcessId: {name}")
    let pids = pids()
    let names = pid_names(pids)

    for pid, name in zipIter(pids.items, names.items):
        if name.contains("LeagueClientUx"):
            let cmdLine = pid_cmdline(pid)
            let args = cmdLine.split("--")
            echo args
            for arg in args:
                if arg.contains("remoting-auth"):
                    logThreaded(lvlDebug, fmt"found: pid: {pid}, name: {name}")
                    result = (pid, args)



proc startLCULauncher*() =
    discard