import std/[strutils, strformat, options, tables]
import nimgl/[opengl, imgui]
import riftlib/types/consts

import ../log
import ../utils
import ../types
import ../states
import ../gfx/[window, implates]
import ../widgets/runes

const activeQueueButtonColor = (0.502, 0.075, 0.256, 1.0)

proc initLauncherImages*(images: ref Table[string, Image]) =
  proc loadImage(name, path: string) =
    var   
      texPosBot: GLuint
      imgPosBot = path.readImage()
    imgPosBot.loadTextureFromData(texPosBot)
    images[name] = (texPosBot, imgPosBot)
    logThreaded(lvlDebug, fmt"Added Image: {name:<20} <== {path}")

  loadImage("posTop", "assets/icons/party/icon-position-top.png")
  loadImage("posJgl", "assets/icons/party/icon-position-jungle.png")
  loadImage("posMid", "assets/icons/party/icon-position-middle.png")
  loadImage("posBot", "assets/icons/party/icon-position-bottom.png")
  loadImage("posSup", "assets/icons/party/icon-position-utility.png")
  loadImage("posFil", "assets/icons/party/icon-position-fill.png")
  loadImage("posNon", "assets/icons/party/icon-position-unselected.png")

proc drawRole(role: Position) =
  case role:
  of Position.Top: drawImage("posTop", 60, 60)
  of Position.Jungle: drawImage("posJgl", 60, 60)
  of Position.Middle: drawImage("posMid", 60, 60)
  of Position.Bottom: drawImage("posBot", 60, 60)
  of Position.Utility: drawImage("posSup", 60, 60)
  of Position.Fill: drawImage("posFil", 60, 60)
  of Position.Unselected: drawImage("posNon", 60, 60)

proc uiAccounts*(launcher: Launcher) =
  for i, account in launcher.accounts:
    igSpacing()
    let division = if account.solo.division == Division.NA: "" else: $account.solo.division
    if igButton(cstring(fmt"{account.name}{'\n'}{account.solo.tier} {division}"), ImVec2(x: 256 - 15, y: 42)): discard

proc lobby*(instance: Instance) =
  case instance.state.kind:
    of skNothing:
      uiEmpty (0.0, 258.9)
      igSetWindowFontScale(2.0)
      uiEmpty (290.0, 0.0)
      igSameLine()
      igText("Not In Lobby")
      igSetWindowFontScale(1.0)
      uiEmpty (0.0, 259.0)
    
    of skPlanning, skSearching:
      uiEmpty (0.0, 10.0)
      let lobby = instance.state.lobby
      case lobby.queue
        of Queue.Draft..Queue.Aram:
          for member in lobby.members:
            igSeparator()
            uiEmpty (0.0, 5.0)
            igSetWindowFontScale(1.5)
            uiEmpty (25.0, 0.0)

            igSameLine()

            uiCols 3:
              igSetColumnOffset(1, 200.0)
              igSetColumnOffset(2, 350.0)
              uiCol:
                igText(cstring(fmt"{member.name}"))
                igSetWindowFontScale(1.0)
                if member.solo.tier != Tier.Unranked:
                  igText(cstring(fmt"{member.solo.tier} {member.solo.division}"))
                else:
                  igText(cstring("Unraked"))
              uiCol:
                drawRole(member.position1)
                igSameLine()
                drawRole(member.position2)
              uiColLast: discard
            uiEmpty (0.0, 5.0)
            igSeparator()
            uiEmpty (0.0, 10.0)
        else: discard
    else: discard

proc runeMenu*(page: RuneEditPage, primary: bool) =
  igDummy(ImVec2(x: 0.0, y: 30.0))
  if primary:
    case page.primary.get():
    of PerkCategory.Precision: 
      if igBeginMenu(cstring(if page.runes[0].isNone(): "Keystone" else: perkToString[page.runes[0].get()])):
        for perk in Perk.PressTheAttack..Perk.FleetFootwork:
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[0] = some perk
        igEndMenu()
      
      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if page.runes[1].isNone(): "Row 1" else: perkToString[page.runes[1].get()])):
        for perk in Perk.Overheal..Perk.PresenceOfMind:
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[1] = some perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if page.runes[2].isNone(): "Row 2" else: perkToString[page.runes[2].get()])):
        for perk in Perk.LegendAlacrity..Perk.LegendBloodline:
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[2] = some perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if page.runes[3].isNone(): "Row 3" else: perkToString[page.runes[3].get()])):
        for perk in Perk.CoupDeGras..Perk.LastStand:
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[3] = some perk
        igEndMenu()
    
    of PerkCategory.Domination:
      if igBeginMenu(cstring(if page.runes[0].isNone(): "Keystone" else: perkToString[page.runes[0].get()])):
        for perk in Perk.Electrocute..Perk.HailOfBlades:
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[0] = some perk
        igEndMenu()
      
      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if page.runes[1].isNone(): "Row 1" else: perkToString[page.runes[1].get()])):
        for perk in Perk.CheapShot..Perk.SuddenImpact:
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[1] = some perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if page.runes[2].isNone(): "Row 2" else: perkToString[page.runes[2].get()])):
        for perk in Perk.ZombieWard..Perk.EyeBallCollection:
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[2] = some perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if page.runes[3].isNone(): "Row 3" else: perkToString[page.runes[3].get()])):
        for perk in Perk.TreasureHunter..Perk.UltimateHunter:
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[3] = some perk
        igEndMenu()
    
    of PerkCategory.Sorcery:
      if igBeginMenu(cstring(if page.runes[0].isNone(): "Keystone" else: perkToString[page.runes[0].get()])):
        for perk in Perk.SummonAery..Perk.PhaseRush:
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[0] = some perk
        igEndMenu()
      
      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if page.runes[1].isNone(): "Row 1" else: perkToString[page.runes[1].get()])):
        for perk in Perk.NullifyingOrb..Perk.NimbusCloak:
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[1] = some perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if page.runes[2].isNone(): "Row 2" else: perkToString[page.runes[2].get()])):
        for perk in Perk.Trancendence..Perk.AbsoluteFocus:
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[2] = some perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if page.runes[3].isNone(): "Row 3" else: perkToString[page.runes[3].get()])):
        for perk in Perk.Scorch..Perk.GatheringStorm:
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[3] = some perk
        igEndMenu()
    
    of PerkCategory.Resolve:
      if igBeginMenu(cstring(if page.runes[0].isNone(): "Keystone" else: perkToString[page.runes[0].get()])):
        for perk in Perk.GraspOfTheUndying..Perk.Guardian:
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[0] = some perk
        igEndMenu()
      
      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if page.runes[1].isNone(): "Row 1" else: perkToString[page.runes[1].get()])):
        for perk in Perk.Demolish..Perk.ShieldBash:
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[1] = some perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if page.runes[2].isNone(): "Row 2" else: perkToString[page.runes[2].get()])):
        for perk in Perk.Conditioning..Perk.BonePlating:
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[2] = some perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if page.runes[3].isNone(): "Row 3" else: perkToString[page.runes[3].get()])):
        for perk in Perk.Overgrowth..Perk.Unflinching:
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[3] = some perk
        igEndMenu()
    
    of PerkCategory.Inspiration:
      if igBeginMenu(cstring(if page.runes[0].isNone(): "Keystone" else: perkToString[page.runes[0].get()])):
        for perk in Perk.GlacialAugment..Perk.FirstStrike:
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[0] = some perk
        igEndMenu()
      
      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if page.runes[1].isNone(): "Row 1" else: perkToString[page.runes[1].get()])):
        for perk in Perk.HextechFlashtraption..Perk.PerfectTiming:
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[1] = some perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if page.runes[2].isNone(): "Row 2" else: perkToString[page.runes[2].get()])):
        for perk in Perk.FuturesMarket..Perk.BiscuitDelivery:
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[2] = some perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if page.runes[3].isNone(): "Row 3" else: perkToString[page.runes[3].get()])):
        for perk in Perk.CosmicInsight..Perk.TimeWarpTonic:
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[3] = some perk
        igEndMenu()
  
  else:
    case page.secondary.get():
    of PerkCategory.Precision: 
      if igBeginMenu(cstring(if page.runes[4].isNone(): "Secondary 1" else: perkToString[page.runes[4].get()])):
        for perk in Perk.Overheal..Perk.LastStand:
          if page.runes[4].isSome() and page.runes[4].get() == perk: continue
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[4] = some perk
            if page.runes[5].isSome() and page.runes[5].get() == perk: page.runes[5] = none Perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if page.runes[5].isNone(): "Secondary 2" else: perkToString[page.runes[5].get()])):
        for perk in Perk.Overheal..Perk.LastStand:
          if page.runes[5].isSome() and page.runes[5].get() == perk: continue
          if page.runes[4].isSome() and page.runes[4].get() == perk: continue
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[5] = some perk
        igEndMenu()
    
    of PerkCategory.Domination:
      if igBeginMenu(cstring(if page.runes[4].isNone(): "Secondary 1" else: perkToString[page.runes[4].get()])):
        for perk in Perk.CheapShot..Perk.UltimateHunter:
          if page.runes[4].isSome() and page.runes[4].get() == perk: continue
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[4] = some perk
            if page.runes[5].isSome() and page.runes[5].get() == perk: page.runes[5] = none Perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if page.runes[5].isNone(): "Secondary 2" else: perkToString[page.runes[5].get()])):
        for perk in Perk.CheapShot..Perk.UltimateHunter:
          if page.runes[5].isSome() and page.runes[5].get() == perk: continue
          if page.runes[4].isSome() and page.runes[4].get() == perk: continue
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[5] = some perk
        igEndMenu()

    of PerkCategory.Sorcery:
      if igBeginMenu(cstring(if page.runes[4].isNone(): "Secondary 1" else: perkToString[page.runes[4].get()])):
        for perk in Perk.NullifyingOrb..Perk.GatheringStorm:
          if page.runes[4].isSome() and page.runes[4].get() == perk: continue
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[4] = some perk
            if page.runes[5].isSome() and page.runes[5].get() == perk: page.runes[5] = none Perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if page.runes[5].isNone(): "Secondary 2" else: perkToString[page.runes[5].get()])):
        for perk in Perk.NullifyingOrb..Perk.GatheringStorm:
          if page.runes[5].isSome() and page.runes[5].get() == perk: continue
          if page.runes[4].isSome() and page.runes[4].get() == perk: continue
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[5] = some perk
        igEndMenu()

    of PerkCategory.Resolve:
      if igBeginMenu(cstring(if page.runes[4].isNone(): "Secondary 1" else: perkToString[page.runes[4].get()])):
        for perk in Perk.Demolish..Perk.Unflinching:
          if page.runes[4].isSome() and page.runes[4].get() == perk: continue
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[4] = some perk
            if page.runes[5].isSome() and page.runes[5].get() == perk: page.runes[5] = none Perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if page.runes[5].isNone(): "Secondary 2" else: perkToString[page.runes[5].get()])):
        for perk in Perk.Demolish..Perk.Unflinching:
          if page.runes[5].isSome() and page.runes[5].get() == perk: continue
          if page.runes[4].isSome() and page.runes[4].get() == perk: continue
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[5] = some perk
        igEndMenu()
    
    of PerkCategory.Inspiration:
      if igBeginMenu(cstring(if page.runes[4].isNone(): "Secondary 1" else: perkToString[page.runes[4].get()])):
        for perk in Perk.HextechFlashtraption..Perk.TimeWarpTonic:
          if page.runes[4].isSome() and page.runes[4].get() == perk: continue
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[4] = some perk
            if page.runes[5].isSome() and page.runes[5].get() == perk: page.runes[5] = none Perk
        igEndMenu()

      igDummy(ImVec2(x: 0.0, y: 15.0))
      if igBeginMenu(cstring(if page.runes[5].isNone(): "Secondary 2" else: perkToString[page.runes[5].get()])):
        for perk in Perk.HextechFlashtraption..Perk.TimeWarpTonic:
          if page.runes[5].isSome() and page.runes[5].get() == perk: continue
          if page.runes[4].isSome() and page.runes[4].get() == perk: continue
          if igMenuItem(cstring(perkToString[perk])):
            page.runes[5] = some perk
        igEndMenu()

    igDummy(ImVec2(x: 0.0, y: 15.0))
    if igBeginMenu(cstring(if page.runes[6].isNone(): "Utility 1" else: fmt"1. {perkToString[page.runes[6].get()]}")):
      const perks = [Perk.Adaptive, Perk.AttackSpeed, Perk.CDRScaling]
      for perk in perks:
        if page.runes[6].isSome() and page.runes[6].get() == perk: continue
        if igMenuItem(cstring(perkToString[perk])):
          page.runes[6] = some perk
      igEndMenu()

    igDummy(ImVec2(x: 0.0, y: 10.0))
    if igBeginMenu(cstring(if page.runes[7].isNone(): "Utility 2" else: fmt"2. {perkToString[page.runes[7].get()]}")):
      const perks = [Perk.Adaptive, Perk.Armor, Perk.MagicRes]
      for perk in perks:
        if page.runes[7].isSome() and page.runes[7].get() == perk: continue
        if igMenuItem(cstring(perkToString[perk])):
          page.runes[7] = some perk
      igEndMenu()

    igDummy(ImVec2(x: 0.0, y: 10.0))
    if igBeginMenu(cstring(if page.runes[8].isNone(): "Utility 3" else: fmt"3. {perkToString[page.runes[8].get()]}")):
      const perks = [Perk.HealthScaling, Perk.Armor, Perk.MagicRes]
      for perk in perks:
        if page.runes[8].isSome() and page.runes[8].get() == perk: continue
        if igMenuItem(cstring(perkToString[perk])):
          page.runes[8] = some perk
      igEndMenu()

proc uiLauncher*(data: Launcher, ui: LauncherUI, window: Window) =

  let instance = data.current.get()
  let queue = instance.state.lobby.queue
  let me = getMeFromLobby(instance)


  let io = igGetIO()
  igSetNextWindowSize(io.displaySize)
  igSetNextWindowPos(ImVec2(x: 0, y: 0))
  uiWindow "Main", 8193.ImGuiWindowFlags:
    uiCols 3:
      igSetColumnOffset(1, 256)
      igSetColumnOffset(2, 1024)

      uiCol:
        uiAccounts(data)
      
      uiCol:
        uiChild "Game Menu", (0.0, 20.0), ImGuiWindowFlags.MenuBar:
          uiMenuBar:
            uiMenuItem "Profile": ui.show.profile = not ui.show.profile
            uiMenuItem "Runes": ui.show.runes = not ui.show.runes
            uiMenuItem "Inventory": ui.show.inventory = not ui.show.inventory
            uiMenuItem "Champions": ui.show.champions = not ui.show.champions
            uiMenuItem "Skins": ui.show.skins = not ui.show.skins
            uiMenuItem "Dodgelist": ui.show.dodgelist = not ui.show.dodgelist
            uiMenuItem "Debug": ui.show.debug = not ui.show.debug

        uiChild "Lobby", (0.0, 545.0):
          lobby(instance)
        
        uiChild "Selection":
          uiCols 4:
            igSetColumnOffset(1, 153.0)
            igSetColumnOffset(2, 238.0)
            igSetColumnOffset(3, 530.0)

            uiCol:
              uiColoredOnConButton "Blind", (64.0, 20.0), queue == Queue.Blind, activeQueueButtonColor:
                discard
              do: 
                discard

              igSameLine()

              uiColoredOnConButton "Draft", (64.0, 20.0), queue == Queue.Draft, activeQueueButtonColor:
                discard
              do: 
                discard

              uiEmpty (0.0, 5.0)

              uiColoredOnConButton "Ranked", (64.0, 20.0), queue == Queue.RankedSolo5x5, activeQueueButtonColor:
                discard
              do: 
                discard

              igSameLine()

              uiColoredOnConButton "Flex", (64.0, 20.0), queue == Queue.RankedFlexSr, activeQueueButtonColor:
                discard
              do: 
                discard

              uiEmpty (0.0, 5.0)
              igSeparatorEx(1.ImGuiSeparatorFlags)
              uiEmpty (0.0, 5.0)

              uiColoredOnConButton "ARAM", (64.0, 20.0), queue == Queue.Aram, activeQueueButtonColor:
                discard
              do: 
                discard

              igSameLine()

              uiColoredOnConButton "SPECIAL", (64.0, 20.0), false, activeQueueButtonColor:
                discard
              do: 
                discard

              uiEmpty (0.0, 5.0)
              igSeparatorEx(1.ImGuiSeparatorFlags)
              uiEmpty (0.0, 5.0)

              uiColoredOnConButton "Practice", (64.0, 20.0), queue == Queue.PracticeTool, activeQueueButtonColor:
                discard
              do: 
                discard

              igSameLine()

              uiColoredOnConButton "Intro", (64.0, 20.0), queue == Queue.BotsInto, activeQueueButtonColor:
                discard
              do: 
                discard

              uiEmpty (0.0, 5.0)

              uiColoredOnConButton "Beginner", (64.0, 20.0), queue == Queue.BotsBeginner, activeQueueButtonColor:
                discard
              do: 
                discard

              igSameLine()

              uiColoredOnConButton "Interm", (64.0, 20.0), queue == Queue.BotsIntermediate, activeQueueButtonColor:
                discard
              do: 
                discard

            uiCol:
              uiChild "Roles":
                if me.isNone():
                  igText("Defaults")
                  uiMenu "test": discard
                else:
                  let me = me.get()
                  igText("Select")
            
            uiCol:
              uiEmpty (5.0, 0.0)
              igSameLine()
              uiButton "Play", (256.0, 64.0): 
                discard

            uiColLast:
              uiMenu("test"):
                uiMenuItem("test"): discard
                uiMenuItem("test2"): discard
              uiEmpty (0.0, 5.0)
              uiMenu("test11"):
                uiMenuItem("test1"): discard
                uiMenuItem("test3"): discard
      
      uiColLast:
        uiChild "Friendlist":
          for i in 0..50:
            uiButton fmt"Friend {i}", (256.0 - 15, 42.0):
              echo fmt"{i}"

  uiWindow "Profile", 0.ImGuiWindowFlags, ui.show.profile:
    igText("Profile Page")
  
  uiWindow "Runes", 0.ImGuiWindowFlags, ui.show.runes:
    let pages = data.userData.runes.all
    let edit = data.userData.runes.edit
    if ui.runeError.isSome():
      uiColoredText(ui.runeError.get(), (0.905, 0.152, 0.305, 1.0))
    uiCols 3:
      igSetColumnOffset(1, 150)
      igSetColumnOffset(2, 350)
      uiCol:
        igText("Pages:")
        igInputText("", addr edit.name[0], edit.name.len().uint)
        igSameLine()
        uiButton "+":
          if canSaveRune(edit):
            let newPage = edit.finishRunePage()
            newPage.save()
            data.userData.runes.all = loadRunes()
            ui.runeError = none string
          else: 
            ui.runeError = some "Page Not Complete"
        
        uiEmpty (0.0, 6.0)
        for page in pages:
          uiButton page.name, (98.0, 15.0): 
            if isSameName(page, data.userData.runes.edit):
              data.userData.runes.edit = newEmptyEditPage()
            else: 
              data.userData.runes.edit = page.toEditPage()
          igSameLine()
          uiButton fmt"-##{page.name}":
            page.delete()
            data.userData.runes.all = loadRunes()
            logThreaded(lvlInfo, fmt"Deleted: Runepage: {page.name}")  
          uiEmpty (0.0, 2.0)

      uiCol: 
        uiChild "Page Primary":
          uiMenu (if edit.primary.isNone(): "Primary" else: perkCategoryToString[edit.primary.get()]):
            for category in perkCategoriesAll:
              if edit.primary.isSome() and edit.primary.get() == category: continue
              uiMenuItem(perkCategoryToString[category]):
                edit.primary = some category
                if edit.secondary.isSome() and edit.secondary.get() == category:
                  edit.secondary = none PerkCategory

          if edit.primary.isSome(): runeMenu(edit, true)
      uiColLast: 
        uiChild "Page Secondary":
          uiMenu (if edit.secondary.isNone(): "Secondary" else: perkCategoryToString[edit.secondary.get()]):
            for category in perkCategoriesAll:
              if edit.secondary.isSome() and edit.secondary.get() == category: continue
              if edit.primary.isSome() and edit.primary.get() == category: continue
              uiMenuItem(perkCategoryToString[category]):
                edit.secondary = some category
          if edit.secondary.isSome(): runeMenu(edit, false)

  uiWindow "Inventory", 0.ImGuiWindowFlags, ui.show.inventory:
    igText("Inventory Page")

  uiWindow "Champions", 0.ImGuiWindowFlags, ui.show.champions:
    igText("Champions Page")

  uiWindow "Skins", 0.ImGuiWindowFlags, ui.show.skins:
    igText("Skins Page")

  uiWindow "Dodgelist", 0.ImGuiWindowFlags, ui.show.dodgelist:
    igText("Dodgelist Page")

  uiWindow "Debug", 0.ImGuiWindowFlags, ui.show.debug:
    igText("Debug Page")
