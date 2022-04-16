import ../gfx/window
import nimgl/[imgui, glfw]

var show_demo: bool = true
var somefloat: float32 = 0.0f
var counter: int32 = 0

proc draw_imgui*(w: Window) =
  if show_demo:
    igShowDemoWindow(show_demo.addr)

  # Simple window
  igBegin("Hello, world!")

  igText("This is some useful text.")
  igCheckbox("Demo Window", show_demo.addr)

  igSliderFloat("float", somefloat.addr, 0.0f, 1.0f)

  if igButton("Button", ImVec2(x: 0, y: 0)):
    counter.inc

  if igButton("Make Window Clickthrough", ImVec2(x: 0, y: 0)):
    counter.inc
    w.setWindowFlag(GLFWMouseButtonPassthrough, GLFW_TRUE)
  
  igSameLine()
  igText("counter = %d", counter)

  igText("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / igGetIO().framerate, igGetIO().framerate)
