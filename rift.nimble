# Package

version       = "0.1.0"
author        = "TryAngle"
description   = "A new awesome nimble package"
license       = "Apache-2.0"
srcDir        = "src"
bin           = @["rift"]
backend       = "cpp"

requires "psutil >= 0.6.0"
requires "nim >= 1.6.4"
requires "nimgl"
# requires "winim >= 3.8.0"
requires "glm >= 1.1.1"
requires "slicerator >= 0.2.1"
requires "riftlib"
requires "stb_image >= 2.5"