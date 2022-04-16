import std/[strutils, strformat, options, tables]
import ../log
import nimgl/[opengl, imgui]
import riftlib/types/consts
import ../utils


proc initLauncherImages*(images: ref Table[string, Image]) =
  proc loadImage(name, path: string) =
    var   
      texPosBot: GLuint
      imgPosBot = path.readImage()
    imgPosBot.loadTextureFromData(texPosBot)
    images[name] = (texPosBot, imgPosBot)

  loadImage("posTop", "assets/icons/party/icon-position-top.png")
  loadImage("posJgl", "assets/icons/party/icon-position-jungle.png")
  loadImage("posMid", "assets/icons/party/icon-position-middle.png")
  loadImage("posBot", "assets/icons/party/icon-position-bottom.png")
  loadImage("posSup", "assets/icons/party/icon-position-utility.png")
  loadImage("posFil", "assets/icons/party/icon-position-fill.png")
  loadImage("posNon", "assets/icons/party/icon-position-unselected.png")

type

  Rank* = object
    tier*: Tier
    division*: Division

  Account* = object
    id*: int64
    name*: string
    accountName*: string
    solo*: Rank
    flex*: Rank

  LobbyMember* = object
    id*: SummonerId
    name*: string
    accountName*: string
    solo*: Rank
    flex*: Rank
    position1*: Position
    position2*: Position
  
  Lobby* = object
    leader*: SummonerId
    members*: seq[LobbyMember]


proc drawRole(role: Position) =
  case role:
  of Position.Top: drawImage("posTop", 60, 60)
  of Position.Jungle: drawImage("posJgl", 60, 60)
  of Position.Middle: drawImage("posMid", 60, 60)
  of Position.Bottom: drawImage("posBot", 60, 60)
  of Position.Utility: drawImage("posSup", 60, 60)
  of Position.Fill: drawImage("posFil", 60, 60)
  of Position.Unselected: drawImage("posNon", 60, 60)

proc lAccounts*(accounts: seq[Account]) =
  for i, account in accounts:
    igSpacing()
    let division = if account.solo.division == Division.NA: "" else: $account.solo.division
    if igButton(cstring(fmt"{account.name}{'\n'}{account.solo.tier} {division}"), ImVec2(x: 256 - 15, y: 42)): discard

proc lobby*(selectedQueue: Option[Queue], lobby: Lobby) =
  if selectedQueue.isNone():
    igDummy(ImVec2(x: 0.0, y: 258.9))
    igSetWindowFontScale(2.0)
    igDummy(ImVec2(x: 290.0, y: 0.0))
    igSameLine()
    igText("Not In Lobby")
    igSetWindowFontScale(1.0)
    igDummy(ImVec2(x: 0.0, y: 259.0))

  elif selectedQueue.isSome() and selectedQueue.get() in Queue.Draft..Queue.Aram: 
    igDummy(ImVec2(x: 0.0, y: 20.0))
    igSeparator()
    for member in lobby.members:
      igDummy(ImVec2(x: 0.0, y: 25))
      igSetWindowFontScale(1.5)
      igDummy(ImVec2(x: 25.0, y: 0.0))
      igSameLine()
      igColumns(3)
      igSetColumnOffset(1, 200.0)
      igSetColumnOffset(2, 350.0)
      igText(cstring(fmt"{member.name}"))
      igSetWindowFontScale(1.0)
      if member.solo.tier != Tier.Unranked:
        igText(cstring(fmt"{member.solo.tier} {member.solo.division}"))
      else:
        igText(cstring("Unraked"))
      igNextColumn()
      drawRole(member.position1)
      igSameLine()
      drawRole(member.position2)
      igNextColumn()
      igEndColumns()
      igDummy(ImVec2(x: 0.0, y: 25))
      igSeparator()

proc runeMenu*(category: PerkCategory, selected: var seq[Option[Perk]], primary: bool) =
  igDummy(ImVec2(x: 0.0, y: 30.0))
  if primary:
    case category:
    of PerkCategory.Precision: 
      if igBeginMenu(cstring(if selected[0].isNone(): "Keystone" else: perkToString[selected[0].get()])):
        for perk in Perk.PressTheAttack..Perk.FleetFootwork:
          if igMenuItem(cstring(perkToString[perk])):
            selected[0] = some perk
        igEndMenu()
      
      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if selected[1].isNone(): "Row 1" else: perkToString[selected[1].get()])):
        for perk in Perk.Overheal..Perk.PresenceOfMind:
          if igMenuItem(cstring(perkToString[perk])):
            selected[1] = some perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if selected[2].isNone(): "Row 2" else: perkToString[selected[2].get()])):
        for perk in Perk.LegendAlacrity..Perk.LegendBloodline:
          if igMenuItem(cstring(perkToString[perk])):
            selected[2] = some perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if selected[3].isNone(): "Row 3" else: perkToString[selected[3].get()])):
        for perk in Perk.CoupDeGras..Perk.LastStand:
          if igMenuItem(cstring(perkToString[perk])):
            selected[3] = some perk
        igEndMenu()
    
    of PerkCategory.Domination:
      if igBeginMenu(cstring(if selected[0].isNone(): "Keystone" else: perkToString[selected[0].get()])):
        for perk in Perk.Electrocute..Perk.HailOfBlades:
          if igMenuItem(cstring(perkToString[perk])):
            selected[0] = some perk
        igEndMenu()
      
      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if selected[1].isNone(): "Row 1" else: perkToString[selected[1].get()])):
        for perk in Perk.CheapShot..Perk.SuddenImpact:
          if igMenuItem(cstring(perkToString[perk])):
            selected[1] = some perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if selected[2].isNone(): "Row 2" else: perkToString[selected[2].get()])):
        for perk in Perk.ZombieWard..Perk.EyeBallCollection:
          if igMenuItem(cstring(perkToString[perk])):
            selected[2] = some perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if selected[3].isNone(): "Row 3" else: perkToString[selected[3].get()])):
        for perk in Perk.TreasureHunter..Perk.UltimateHunter:
          if igMenuItem(cstring(perkToString[perk])):
            selected[3] = some perk
        igEndMenu()
    
    of PerkCategory.Sorcery:
      if igBeginMenu(cstring(if selected[0].isNone(): "Keystone" else: perkToString[selected[0].get()])):
        for perk in Perk.SummonAery..Perk.PhaseRush:
          if igMenuItem(cstring(perkToString[perk])):
            selected[0] = some perk
        igEndMenu()
      
      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if selected[1].isNone(): "Row 1" else: perkToString[selected[1].get()])):
        for perk in Perk.NullifyingOrb..Perk.NimbusCloak:
          if igMenuItem(cstring(perkToString[perk])):
            selected[1] = some perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if selected[2].isNone(): "Row 2" else: perkToString[selected[2].get()])):
        for perk in Perk.Trancendence..Perk.AbsoluteFocus:
          if igMenuItem(cstring(perkToString[perk])):
            selected[2] = some perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if selected[3].isNone(): "Row 3" else: perkToString[selected[3].get()])):
        for perk in Perk.Scorch..Perk.GatheringStorm:
          if igMenuItem(cstring(perkToString[perk])):
            selected[3] = some perk
        igEndMenu()
    
    of PerkCategory.Resolve:
      if igBeginMenu(cstring(if selected[0].isNone(): "Keystone" else: perkToString[selected[0].get()])):
        for perk in Perk.GraspOfTheUndying..Perk.Guardian:
          if igMenuItem(cstring(perkToString[perk])):
            selected[0] = some perk
        igEndMenu()
      
      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if selected[1].isNone(): "Row 1" else: perkToString[selected[1].get()])):
        for perk in Perk.Demolish..Perk.ShieldBash:
          if igMenuItem(cstring(perkToString[perk])):
            selected[1] = some perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if selected[2].isNone(): "Row 2" else: perkToString[selected[2].get()])):
        for perk in Perk.Conditioning..Perk.BonePlating:
          if igMenuItem(cstring(perkToString[perk])):
            selected[2] = some perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if selected[3].isNone(): "Row 3" else: perkToString[selected[3].get()])):
        for perk in Perk.Overgrowth..Perk.Unflinching:
          if igMenuItem(cstring(perkToString[perk])):
            selected[3] = some perk
        igEndMenu()
    
    of PerkCategory.Inspiration:
      if igBeginMenu(cstring(if selected[0].isNone(): "Keystone" else: perkToString[selected[0].get()])):
        for perk in Perk.GlacialAugment..Perk.FirstStrike:
          if igMenuItem(cstring(perkToString[perk])):
            selected[0] = some perk
        igEndMenu()
      
      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if selected[1].isNone(): "Row 1" else: perkToString[selected[1].get()])):
        for perk in Perk.HextechFlashtraption..Perk.PerfectTiming:
          if igMenuItem(cstring(perkToString[perk])):
            selected[1] = some perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if selected[2].isNone(): "Row 2" else: perkToString[selected[2].get()])):
        for perk in Perk.FuturesMarket..Perk.BiscuitDelivery:
          if igMenuItem(cstring(perkToString[perk])):
            selected[2] = some perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if selected[3].isNone(): "Row 3" else: perkToString[selected[3].get()])):
        for perk in Perk.CosmicInsight..Perk.TimeWarpTonic:
          if igMenuItem(cstring(perkToString[perk])):
            selected[3] = some perk
        igEndMenu()
  
  else:
    case category:
    of PerkCategory.Precision: 
      if igBeginMenu(cstring(if selected[4].isNone(): "Secondary 1" else: perkToString[selected[4].get()])):
        for perk in Perk.Overheal..Perk.LastStand:
          if selected[4].isSome() and selected[4].get() == perk: continue
          if igMenuItem(cstring(perkToString[perk])):
            selected[4] = some perk
            if selected[5].isSome() and selected[5].get() == perk: selected[5] = none Perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if selected[5].isNone(): "Secondary 2" else: perkToString[selected[5].get()])):
        for perk in Perk.Overheal..Perk.LastStand:
          if selected[5].isSome() and selected[5].get() == perk: continue
          if selected[4].isSome() and selected[4].get() == perk: continue
          if igMenuItem(cstring(perkToString[perk])):
            selected[5] = some perk
        igEndMenu()
    
    of PerkCategory.Domination:
      if igBeginMenu(cstring(if selected[4].isNone(): "Secondary 1" else: perkToString[selected[4].get()])):
        for perk in Perk.CheapShot..Perk.UltimateHunter:
          if selected[4].isSome() and selected[4].get() == perk: continue
          if igMenuItem(cstring(perkToString[perk])):
            selected[4] = some perk
            if selected[5].isSome() and selected[5].get() == perk: selected[5] = none Perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if selected[5].isNone(): "Secondary 2" else: perkToString[selected[5].get()])):
        for perk in Perk.CheapShot..Perk.UltimateHunter:
          if selected[5].isSome() and selected[5].get() == perk: continue
          if selected[4].isSome() and selected[4].get() == perk: continue
          if igMenuItem(cstring(perkToString[perk])):
            selected[5] = some perk
        igEndMenu()

    of PerkCategory.Sorcery:
      if igBeginMenu(cstring(if selected[4].isNone(): "Secondary 1" else: perkToString[selected[4].get()])):
        for perk in Perk.NullifyingOrb..Perk.GatheringStorm:
          if selected[4].isSome() and selected[4].get() == perk: continue
          if igMenuItem(cstring(perkToString[perk])):
            selected[4] = some perk
            if selected[5].isSome() and selected[5].get() == perk: selected[5] = none Perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if selected[5].isNone(): "Secondary 2" else: perkToString[selected[5].get()])):
        for perk in Perk.NullifyingOrb..Perk.GatheringStorm:
          if selected[5].isSome() and selected[5].get() == perk: continue
          if selected[4].isSome() and selected[4].get() == perk: continue
          if igMenuItem(cstring(perkToString[perk])):
            selected[5] = some perk
        igEndMenu()

    of PerkCategory.Resolve:
      if igBeginMenu(cstring(if selected[4].isNone(): "Secondary 1" else: perkToString[selected[4].get()])):
        for perk in Perk.Demolish..Perk.Unflinching:
          if selected[4].isSome() and selected[4].get() == perk: continue
          if igMenuItem(cstring(perkToString[perk])):
            selected[4] = some perk
            if selected[5].isSome() and selected[5].get() == perk: selected[5] = none Perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if selected[5].isNone(): "Secondary 2" else: perkToString[selected[5].get()])):
        for perk in Perk.Demolish..Perk.Unflinching:
          if selected[5].isSome() and selected[5].get() == perk: continue
          if selected[4].isSome() and selected[4].get() == perk: continue
          if igMenuItem(cstring(perkToString[perk])):
            selected[5] = some perk
        igEndMenu()
    
    of PerkCategory.Inspiration:
      if igBeginMenu(cstring(if selected[4].isNone(): "Secondary 1" else: perkToString[selected[4].get()])):
        for perk in Perk.HextechFlashtraption..Perk.TimeWarpTonic:
          if selected[4].isSome() and selected[4].get() == perk: continue
          if igMenuItem(cstring(perkToString[perk])):
            selected[4] = some perk
            if selected[5].isSome() and selected[5].get() == perk: selected[5] = none Perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if selected[5].isNone(): "Secondary 2" else: perkToString[selected[5].get()])):
        for perk in Perk.HextechFlashtraption..Perk.TimeWarpTonic:
          if selected[5].isSome() and selected[5].get() == perk: continue
          if selected[4].isSome() and selected[4].get() == perk: continue
          if igMenuItem(cstring(perkToString[perk])):
            selected[5] = some perk
        igEndMenu()

    igDummy(ImVec2(x: 0.0, y: 15.0))
    if igBeginMenu(cstring(if selected[6].isNone(): "Utility 1" else: fmt"1. {perkToString[selected[6].get()]}")):
      const perks = [Perk.Adaptive, Perk.AttackSpeed, Perk.CDRScaling]
      for perk in perks:
        if selected[6].isSome() and selected[6].get() == perk: continue
        if igMenuItem(cstring(perkToString[perk])):
          selected[6] = some perk
      igEndMenu()

    igDummy(ImVec2(x: 0.0, y: 10.0))
    if igBeginMenu(cstring(if selected[7].isNone(): "Utility 2" else: fmt"2. {perkToString[selected[7].get()]}")):
      const perks = [Perk.Adaptive, Perk.Armor, Perk.MagicRes]
      for perk in perks:
        if selected[7].isSome() and selected[7].get() == perk: continue
        if igMenuItem(cstring(perkToString[perk])):
          selected[7] = some perk
      igEndMenu()

    igDummy(ImVec2(x: 0.0, y: 10.0))
    if igBeginMenu(cstring(if selected[8].isNone(): "Utility 3" else: fmt"3. {perkToString[selected[8].get()]}")):
      const perks = [Perk.Adaptive, Perk.Armor, Perk.MagicRes]
      for perk in perks:
        if selected[8].isSome() and selected[8].get() == perk: continue
        if igMenuItem(cstring(perkToString[perk])):
          selected[8] = some perk
      igEndMenu()