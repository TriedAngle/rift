import std/[strformat, strutils, times, os]
import riftlib/types/consts
import ../utils

type
  RunePage* = object
    name*: string
    created*: DateTime
    primary*: PerkCategory
    secondary*: PerkCategory
    ids*: seq[Perk]
  
proc toRunePage*(name: string, primary, secondary: PerkCategory, ids: seq[Perk]): RunePage =
  RunePage(name: name, created: now(), primary: primary, secondary: secondary, ids: ids)

proc save*(page: RunePage) =
  var buffer: string
  let created = page.created.format("yyyy-MM-dd'T'HH:mm:sszzz:fffffffff")
  buffer.add fmt("[Page]\n")
  buffer.add fmt("name = \"{page.name}\"\n")
  buffer.add fmt("created = \"{created}\"\n")
  buffer.add fmt("primary = \"{perkCategoryToString[page.primary]}\"\n")
  buffer.add fmt("secondary = \"{perkCategoryToString[page.secondary]}\"\n")
  buffer.add "runes = [\n"
  for rune in page.ids:
    buffer.add fmt("  \"{rune}\",\n")
  buffer.add "]"

  saveData(fmt"{page.name}.toml", buffer, "runes")

proc loadRuneData(data: string): RunePage =
  let data = data.replace("\"", "").split("\n")
  result.name = data[1].split(" = ")[1]
  result.created = data[2].split(" = ")[1].parse("yyyy-MM-dd'T'HH:mm:sszzz:fffffffff")
  result.primary = parseEnum[PerkCategory](data[3].split(" = ")[1])
  result.secondary = parseEnum[PerkCategory](data[4].split(" = ")[1])
  for i in 6..14: 
    result.ids.add parseEnum[Perk](data[i].replace("  ", "").replace(",", ""))

proc loadRunePage*(name: string): RunePage =
  let data = readData(name & ".toml", "runes")
  result = loadRuneData(data)


proc loadRunes*(): seq[RunePage] =
  for file in walkDir(configPath & "runes/"):
    let (kind, path) = file
    if kind != pcFile: continue
    result.add loadRuneData(readFile(path))

proc deleteRune*(name: string, isPath: bool = false) =
  if isPath:
    removeFile(name)
  else:
    removeFile(configPath & "runes/" & name & ".toml")

when isMainModule:
  let runePage = RunePage(
    name: "Janna Kitten",
    created: now(),
    primary: PerkCategory.Sorcery,
    secondary: PerkCategory.Domination,
    ids: @[
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

  echo loadRunes()
