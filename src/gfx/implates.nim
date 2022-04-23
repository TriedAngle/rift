import nimgl/[opengl, imgui]


template uiButton*(id: string, body: untyped) =
  if igButton(cstring(id), ImVec2(x: 0.0, y: 0.0)):
    body

template uiButton*(id: string, size: (float, float) = (0.0, 0.0), body: untyped) =
  if igButton(cstring(id), ImVec2(x: size[0], y: size[1])):
    body

template uiColoredOnConButton*(id: string, size: (float, float) = (0.0, 0.0), condition: bool, color: (float, float, float, float), body1, body2: untyped) =
  if condition:
    igPushStyleColor(ImGuiCol.Button, ImVec4(x: color[0], y: color[1], z: color[2], w: color[3]))
    uiButton id, size: body1
    igPopStyleColor(1)
  else:
    uiButton id, size: body2

template uiText(text: string) =
  igText(cstring(text))

template uiColoredText*(text: string, color: (float, float, float, float)) =
  igPushStyleColor(ImGuiCol.Text, ImVec4(x: color[0], y: color[1], z: color[2], w: color[3]))
  uiText(text)
  igPopStyleColor(1)

template uiWindow*(name: string, flags: ImGuiWindowFlags = 0.ImGuiWindowFlags, body: untyped) =
  igBegin(cstring(name), nil, flags)
  body
  igEnd()

template uiWindow*(name: string, flags: ImGuiWindowFlags = 0.ImGuiWindowFlags, open: bool, body: untyped) =
  if open:
    igBegin(cstring(name), nil, flags)
    body
    igEnd()

template uiCols*(amount: int, body: untyped) =
  igColumns(amount)
  body
  igEndColumns()

template uiCol*(body: untyped) =
  body
  igNextColumn()

template uiColLast*(body: untyped) =
  body

template uiChild*(id: string, body: untyped) =
  igBeginChild(cstring(id))
  body
  igEndChild()

template uiChild*(id: string, size: (float, float), body: untyped) =
  igBeginChild(cstring(id), ImVec2(x: size[0], y: size[1]), false, 0.ImGuiWindowFlags)
  body
  igEndChild()

template uiChild*(id: string, flags: ImGuiWindowFlags, body: untyped) =
  igBeginChild(cstring(id), ImVec2(x: 0, y: 0), false, flags)
  body
  igEndChild()

template uiChild*(id: string, size: (float, float), flags: ImGuiWindowFlags, body: untyped) =
  igBeginChild(cstring(id), ImVec2(x: size[0], y: size[1]), false, flags)
  body
  igEndChild()

template uiMenuBar*(body: untyped) =
  if igBeginMenuBar():
    body
    igEndMenuBar()

template uiMenu*(text: string, body: untyped) =
  if igBeginMenu(cstring(text)):
    body
    igEndMenu()

template uiMenuItem*(id: string, body: untyped) =
  if igMenuItem(cstring(id)): body

template uiEmpty*(size: (float, float)) =
  igDummy(ImVec2(x: size[0], y: size[1]))
