import std/[strformat, strutils, os, options]
import riftlib/types/consts
import ../utils
import ../types
import ../log

proc canSaveRune*(page: RuneEditPage): bool =
  for perk in page.runes:
    if perk.isNone(): return false
  return true

proc finishRunePage*(page: RuneEditPage): RunePage =
  result = RunePage()
  for c in page.name:
    if c == '\0': break
    result.name.add c

  result.primary = page.primary.get()
  result.secondary = page.primary.get()

  for i, rune in page.runes:
    result.runes[i] = rune.get()

  page.name = newString(40)

proc nameToStr(page: RuneEditPage): string =
  for c in page.name:
    if c == '\0': break
    result.add c

proc isSameName*(page: RunePage, edit: RuneEditPage): bool =
  let editName = edit.nameToStr()
  page.name == editName

proc toEditPage*(page: RunePage): RuneEditPage =
  result = RuneEditPage()
  result.name = newString(40)
  for i, c in page.name:
    result.name[i] = c
  
  result.primary = some page.primary
  result.secondary = some page.primary
  for i, rune in page.runes:
    result.runes[i] = some rune

proc newEmptyEditPage*(): RuneEditPage =
  result = RuneEditPage()
  result.name = newString(40)


proc save*(page: RunePage) =
  var buffer: string
  buffer.add fmt("[Page]\n")
  buffer.add fmt("name = \"{page.name}\"\n")
  buffer.add fmt("primary = \"{perkCategoryToString[page.primary]}\"\n")
  buffer.add fmt("secondary = \"{perkCategoryToString[page.secondary]}\"\n")
  buffer.add "runes = [\n"
  for rune in page.runes:
    buffer.add fmt("  \"{rune}\",\n")
  buffer.add "]"

  saveData(fmt"{page.name}.toml", buffer, "runes")

proc loadRuneData(data: string): RunePage =
  result = RunePage()
  let data = data.replace("\"", "").split("\n")
  result.name = data[1].split(" = ")[1]
  result.primary = parseEnum[PerkCategory](data[2].split(" = ")[1])
  result.secondary = parseEnum[PerkCategory](data[3].split(" = ")[1])
  for i in 5..13: 
    result.runes[i - 5] = parseEnum[Perk](data[i].replace("  ", "").replace(",", ""))

proc loadRunePage*(name: string): RunePage =
  let data = readData(name & ".toml", "runes")
  result = loadRuneData(data)


proc loadRunes*(): seq[RunePage] =
  for file in walkDir(configPath & "runes/"):
    let (kind, path) = file
    if kind != pcFile: continue
    try:
      let rune = loadRuneData(readFile(path))
      result.add rune
      logThreaded(lvlDebug, fmt"Loaded: Runepage: {rune.name:<15} <== {path}")
    except:
      logThreaded(lvlError, fmt"Couldn't Load: Runepage from {path}")
    

proc delete*(page: RunePage, isPath: bool = false) =
  if isPath:
    removeFile(page.name)
  else:
    removeFile(configPath & "runes/" & page.name & ".toml")

when isMainModule:
  let runePage = RunePage(
    name: "Janna Kitten",
    primary: PerkCategory.Sorcery,
    secondary: PerkCategory.Domination,
    runes: [
      Perk.SummonAery,
      Perk.ManaflowBand,
      Perk.Trancendence,
      Perk.GatheringStorm,
      Perk.EyeBallCollection,
      Perk.UltimateHunter,
      Perk.CDRScaling,
      Perk.Adaptive,
      Perk.Armor
    ]
  )
  runePage.save()
  let page = loadRunePage("Janna Kitten")
  doAssert runePage == page 

  let runes = loadRunes()
  echo runes