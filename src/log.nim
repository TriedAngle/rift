import std/logging
import std/strformat
import std/sequtils

export logging

proc initLogging*() =
    writeFile("log.log", "")

proc registerLoggers*(file: string) =
    let consoleLogger = newConsoleLogger(fmtStr=fmt"[$time] - $levelname: ")
    let fileLogger = newFileLogger(fmt"logs/{file}.log", fmWrite, lvlAll, "[$time] - $levelname: ")
    addHandler(consoleLogger)
    addHandler(fileLogger)

template logThreaded*(level: Level, args: varargs[string, `$`]) =
    var arr: seq[string] = @args
    arr.insert(fmt"[thread: {getThreadId()}] - ")
    log(level, arr)