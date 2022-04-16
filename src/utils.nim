import nimgl/[opengl, imgui]
import stb_image/read as stbi
import std/[tables, os]

when defined posix:
  const configPath* = getHomeDir() & ".config/rift/"
else:
  const configPath* = getHomeDir() & "AppData\\Rift\\"

type
  Image* = tuple[texture: GLuint, data: ImageData]
  ImageData* = tuple[image: seq[byte], width, height: int]

var images* = newTable[string, Image]()

proc drawImage*(name: string) =
  let img = images[name]
  igImage(cast[ptr ImTextureID](img.texture), ImVec2(x: img.data.width.float32, y: img.data.height.float32))

proc drawImage*(name: string, width, height: float32) =
  let img = images[name]
  igImage(cast[ptr ImTextureID](img.texture), ImVec2(x: width, y: height))

proc readImage*(path: string): ImageData = 
  var channels: int
  result.image = stbi.load(path, result.width, result.height, channels, stbi.Default)

proc loadTextureFromData*(data: var ImageData, outTexture: var GLuint) =
    # Create a OpenGL texture identifier
    glGenTextures(1, outTexture.addr)
    glBindTexture(GL_TEXTURE_2D, outTexture)

    # Setup filtering parameters for display
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR.GLint)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR.GLint)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE.GLint) # This is required on WebGL for non power-of-two textures
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE.GLint) # Same

    # Upload pixels into texture
    # if defined(GL_UNPACK_ROW_LENGTH) && !defined(__EMSCRIPTEN__)
    glPixelStorei(GL_UNPACK_ROW_LENGTH, 0)

    glTexImage2D(GL_TEXTURE_2D, GLint 0, GL_RGBA.GLint, GLsizei data.width, GLsizei data.height, GLint 0, GL_RGBA, GL_UNSIGNED_BYTE, data.image[0].addr)


proc createDirIfNotExist(path: string) =
  if not dirExists(path):
    createDir(path)

proc saveData*(name: string, data: string, path: string = "") =
  let path = configPath & path
  createDirIfNotExist(path)
  writeFile(path & "/" & name, data)

proc readData*(name: string, path: string = ""): string =
  let path = configPath & path
  readFile(path & "/" & name)
