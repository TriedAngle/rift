import std/[os, strutils, strformat, options, tables]
import nimgl/imgui, nimgl/imgui/[impl_opengl, impl_glfw]
import nimgl/[opengl, glfw]
import glm

# import riftlib/types/consts

import ./log
import ./gfx/window
import ./keys
import ./ui/[overlay, launcher]
import ./states
import ./utils


proc main() =
  registerLoggers("main")
  logThreaded(lvlInfo, "Starting Rift")

  var window = newWindow()
    .withSize(1280, 720)
    .withName("Rift UI")
    .withHint(GLFWContextVersionMajor, 3)
    .withHint(GLFWContextVersionMinor, 3)
    .withHint(GLFWOpenglForwardCompat, GLFW_TRUE)
    .withHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
    .withHint(GLFWResizable, GLFW_TRUE)
    .build()
    .withCallback(keyCallback)
    .withContext()
    .withOpenGL()
    .withImGui()
    .withStyle(imGuiCherryStyle)

  logThreaded(lvlInfo, "Created: Window with OpenGL and Imgui Support")

  initLauncherImages(images)
  logThreaded(lvlInfo, "Init: Images")

  var (data, ui) = newMockUpLauncher()

  window.runIt:
    uiLauncher(data, ui, window)

main()