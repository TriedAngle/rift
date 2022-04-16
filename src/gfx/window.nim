import nimgl/imgui, nimgl/imgui/[impl_opengl, impl_glfw]
import nimgl/[glfw, opengl]

import std/options

type
  WindowBuilder = object
    hints: seq[tuple[name: int32, value: int32]]
    name: string
    size: tuple[width: int32, height: int32]

  Window* = ref object
    hints*: seq[tuple[name: int32, value: int32]]
    name*: string
    size*: tuple[width: int32, height: int32]
    internalWindow*: GLFWWindow
    isOpenGL: bool
    igContext: Option[ptr ImGuiContext]

proc newWindow*(): WindowBuilder =
  doAssert glfwInit()
  WindowBuilder()

proc withHints*(builder: WindowBuilder, hints: openArray[tuple[name: int32, value: int32]]): WindowBuilder =
  result = builder
  for hint in hints:
    result.hints.add(hint)

proc withHint*(builder: WindowBuilder, hint: tuple[name: int32, value: int32]): WindowBuilder =
  result = builder
  result.hints.add(hint)

proc withHint*(builder: WindowBuilder, name: int32, value: int32): WindowBuilder =
  result = builder
  result.hints.add((name, value))

proc withSize*(builder: WindowBuilder, size: tuple[width: int32, height: int32]): WindowBuilder =
  result = builder
  result.size = size

proc withSize*(builder: WindowBuilder, width: int32, height: int32): WindowBuilder =
  result = builder
  result.size = (width, height)

proc withName*(builder: WindowBuilder, name: string): WindowBuilder =
  result = builder
  result.name = name

proc primaryMonitor*(builder: WindowBuilder): WindowBuilder =
  result = builder
  let primaryMonitor = glfwGetPrimaryMonitor()
  let videoMode = getVideoMode(primaryMonitor)
  result.size = (videoMode.width - 1, videoMode.height - 1)

proc build*(builder: WindowBuilder): Window =
  for hint in builder.hints:
    glfwWindowHint(hint.name, hint.value)

  let internalWindow = glfwCreateWindow(builder.size.width, builder.size.height, cast[cstring](builder.name))
  doAssert internalWindow != nil

  result = Window(hints: builder.hints, name: builder.name, size: builder.size, internalWindow: internalWindow)

proc withCallback*(window: Window, callback: GLFWKeyfun): Window =
  result = window
  discard result.internalWindow.setKeyCallback(callback)

proc withContext*(window: Window): Window =
  result = window 
  result.internalWindow.makeContextCurrent()

proc shouldClose*(window: Window): bool = window.internalWindow.windowShouldClose()

proc swapBuffers*(window: Window) = window.internalWindow.swapBuffers()

proc close*(window: Window) =
  if window.igContext.isSome():
    igOpenGL3Shutdown()
    igGlfwShutdown()
    window.igContext.get().igDestroyContext()
  
  window.internalWindow.destroyWindow()
  glfwTerminate()


proc setWindowFlag*(window: Window, hint: tuple[name: int32, value: int32]) =
  window.internalWindow.setWindowAttrib(hint.name, hint.value)

proc setWindowFlag*(window: Window, name: int32, value: int32) =
  window.internalWindow.setWindowAttrib(name, value)

proc setContext*(window: Window) = 
  window.internalWindow.makeContextCurrent()

proc setCallback*(window: Window, callback: GLFWKeyfun) =
  discard window.internalWindow.setKeyCallback(callback)


# proc frameBufferCallback(window: GLFWWindow, width: int32, height: int32): void =
#   glViewPort(0, 0, width, height)

# openGL
proc withOpenGL*(window: Window): Window =
  result = window
  result.isOpenGL = true
  doAssert glInit()
  echo $glVersionMajor & "." & $glVersionMinor
  # result.internalWindow.setFramebufferSizeCallback(frameBufferCallback)

proc initOpenGL*(window: Window) =
  window.isOpenGL = true
  doAssert glInit()
  echo $glVersionMajor & "." & $glVersionMinor

# imGUI
proc withImGui*(window: Window): Window =
  result = window
  result.igContext = some(igCreateContext())
  doAssert igGlfwInitForOpenGL(result.internalWindow, true)
  doAssert igOpenGL3Init()

proc initImGui*(window: Window) =
  window.igContext = some(igCreateContext())
  doAssert igGlfwInitForOpenGL(window.internalWindow, true)
  doAssert igOpenGL3Init()

proc withStyle*(window: Window, style: proc(dst: ptr ImGuiStyle = nil)): Window =
  result = window
  style()

proc addStyle*(window: Window, style: proc(dst: ptr ImGuiStyle = nil)) =
  style()


proc imGuiCherryStyle*(dst: ptr ImGuiStyle = nil) = igStyleColorsCherry()


# other
proc run*(window: Window, loop: proc()) =
  while not window.shouldClose():
    glClearColor(0.0, 0.0, 0.0, 0.0)
    glClear(GL_COLOR_BUFFER_BIT)

    if window.igContext.isSome():
      igOpenGL3NewFrame()
      igGlfwNewFrame()
      igNewFrame()

    loop()

    if window.igContext.isSome():
      igRender()
      igOpenGL3RenderDrawData(igGetDrawData())

    window.swapBuffers()
    glfwPollEvents()
  
  window.close()