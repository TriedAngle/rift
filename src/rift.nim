import std/[os, strutils, strformat, options]
import nimgl/imgui, nimgl/imgui/[impl_opengl, impl_glfw]
import nimgl/[opengl, glfw]
import glm

import riftlib/types/consts

import ./log
import ./gfx/window
import ./keys
import ./ui/[overlay, launcher]
import ./lcu/lcu



const accounts = @[
  Account(id: 34729342, name: "Your Little Meow", accountName: "your little meow", 
  solo: Rank(tier: Tier.Diamond, division: Division.IV), flex: Rank(tier: Tier.Gold, division: Division.III)),
  Account(id: 34729322, name: "No Cat Complex", accountName: "no cat complex", 
  solo: Rank(tier: Tier.Platinum, division: Division.IV), flex: Rank(tier: Tier.Unranked, division: Division.NA)),
  Account(id: 34725342, name: "S12 Player XD", accountName: "s12 player xd", 
  solo: Rank(tier: Tier.Gold, division: Division.IV), flex: Rank(tier: Tier.Unranked, division: Division.NA))
]

const friends = @[
  Account(id: 34729342, name: "Solobolo v2", accountName: "your little meow", 
  solo: Rank(tier: Tier.Diamond, division: Division.IV), flex: Rank(tier: Tier.Gold, division: Division.III)),
]

const availableSummoners = summonersNormalList

const lobby = Lobby(
  leader: 34729342.SummonerId,
  members: @[
    LobbyMember(
      id: 34729342.SummonerId, 
      name: "Your Little Meow", 
      accountName: "your little meow#EUW", 
      solo: Rank(tier: Tier.Diamond, division: Division.IV), 
      flex: Rank(tier: Tier.Gold, division: Division.III),
    ),
    LobbyMember(
      id: 34729322.SummonerId, 
      name: "No Cat Complex", 
      accountName: "no cat complex#EUW", 
      solo: Rank(tier: Tier.Platinum, division: Division.IV), 
      flex: Rank(tier: Tier.Unranked, division: Division.NA)
    ),
])


proc main() =
  initLogging()
  registerLoggers("main")
  logThreaded(lvlInfo, "Starting Rift")

  # logThreaded(lvlDebug, "send Launcher Event: Close")
  # launcherChannel.send(LauncherEvent(isEvent: true, kind: LauncherEventKind.close))

  logThreaded(lvlDebug, "end of main")
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

  let io = igGetIO()

  var showProfile: bool
  var showRunes: bool
  var showInventory: bool
  var showChampions: bool
  var showSkins: bool
  var showDodgelist: bool
  var showDebugMenu: bool
  
  var runePageNameNew = newString(40)
  var runePageNameEdit = none string
  var currentRunePrimary = none PerkCategory
  var currentRuneSecondary = none PerkCategory
  var selectedRunes = newSeq[Option[Perk]](9)
  
  var selectedRole1 = none Position
  var selectedRole2 = none Position

  var selectedSummoner1 = none SummonerSpell
  var selectedSummoner2 = none SummonerSpell

  var selectedQueue = none Queue

  # let _ = findProcessId()
  window.run(proc() =
    igSetNextWindowSize(io.displaySize)
    igSetNextWindowPos(ImVec2(x: 0, y: 0))
    igBegin("Main", flags=8193.ImGuiWindowFlags)

    igColumns(3)
    igSetColumnOffset(1, 256)
    igSetColumnOffset(2, 1024)
    block:
      lAccounts(accounts)
    
    igNextColumn()
    block: # width: 768
      igBeginChild("Game Menu", flags=ImGuiWindowFlags.MenuBar)
      if igBeginMenuBar():
        if igMenuItem("Profile"): showProfile = not showProfile
        if igMenuItem("Runes"): showRunes = not showRunes
        if igMenuItem("Inventory"): showInventory = not showInventory
        if igMenuItem("Champions"): showChampions = not showChampions
        if igMenuItem("Skins"): showSkins = not showSkins
        if igMenuItem("Dodgelist"): showDodgelist = not showDodgelist
        if igMenuItem("Debug"): showDebugMenu = not showDebugMenu
        igEndMenuBar()

        igBeginChild("Lobby", ImVec2(x: 0.0, y: 545.0))
        lobby(selectedQueue, lobby)
        igEndChild()

        igBeginChild("Selections")
        igColumns(4)
        igSetColumnOffset(1, 153.0)
        igSetColumnOffset(2, 238.0)
        igSetColumnOffset(3, 530.0)
        block:
          if selectedQueue.isSome() and selectedQueue.get() == Queue.Blind:
            igPushStyleColor(ImGuiCol.Button, ImVec4(x: 0.502f, y: 0.075f, z: 0.256f, w: 1.0))
            if igButton("Blind", ImVec2(x: 64, y: 20)):
              selectedQueue = none Queue
            igPopStyleColor(1)
          else:
            if igButton("Blind", ImVec2(x: 64, y: 20)): 
              selectedQueue = some Queue.Blind
          
          igSameLine()
          if selectedQueue.isSome() and selectedQueue.get() == Queue.Draft:
            igPushStyleColor(ImGuiCol.Button, ImVec4(x: 0.502f, y: 0.075f, z: 0.256f, w: 1.0))
            if igButton("Draft", ImVec2(x: 64, y: 20)):
              selectedQueue = none Queue
            igPopStyleColor(1)
          else:
            if igButton("Draft", ImVec2(x: 64, y: 20)): 
              selectedQueue = some Queue.Draft

          igDummy(ImVec2(x: 0.0, y: 5.0))

          if selectedQueue.isSome() and selectedQueue.get() == Queue.RankedSolo5x5:
            igPushStyleColor(ImGuiCol.Button, ImVec4(x: 0.502f, y: 0.075f, z: 0.256f, w: 1.0))
            if igButton("Ranked", ImVec2(x: 64, y: 20)):
              selectedQueue = none Queue
            igPopStyleColor(1)
          else:
            if igButton("Ranked", ImVec2(x: 64, y: 20)): 
              selectedQueue = some Queue.RankedSolo5x5

          igSameLine()
          if selectedQueue.isSome() and selectedQueue.get() == Queue.RankedFlexSr:
            igPushStyleColor(ImGuiCol.Button, ImVec4(x: 0.502f, y: 0.075f, z: 0.256f, w: 1.0))
            if igButton("Flex", ImVec2(x: 64, y: 20)):
              selectedQueue = none Queue
            igPopStyleColor(1)
          else:
            if igButton("Flex", ImVec2(x: 64, y: 20)): 
              selectedQueue = some Queue.RankedFlexSr

          igDummy(ImVec2(x: 0.0, y: 5.0))
          igSeparatorEx(1.ImGuiSeparatorFlags)
          igDummy(ImVec2(x: 0.0, y: 5.0))

          if selectedQueue.isSome() and selectedQueue.get() == Queue.Aram:
            igPushStyleColor(ImGuiCol.Button, ImVec4(x: 0.502f, y: 0.075f, z: 0.256f, w: 1.0))
            if igButton("ARAM", ImVec2(x: 64, y: 20)):
              selectedQueue = none Queue
            igPopStyleColor(1)
          else:
            if igButton("ARAM", ImVec2(x: 64, y: 20)): 
              selectedQueue = some Queue.Aram
          igSameLine()
          if igButton("Special", ImVec2(x: 64, y: 20)): discard

          igDummy(ImVec2(x: 0.0, y: 5.0))
          igSeparatorEx(1.ImGuiSeparatorFlags)
          igDummy(ImVec2(x: 0.0, y: 5.0))

          if igButton("Practice", ImVec2(x: 64, y: 20)): discard
          igSameLine()
          if igButton("Intro", ImVec2(x: 64, y: 20)): discard

          igDummy(ImVec2(x: 0.0, y: 5.0))

          if igButton("Beginner", ImVec2(x: 64, y: 20)): discard
          igSameLine()
          if igButton("Interm.", ImVec2(x: 64, y: 20)): discard

        igNextColumn()
        block:
          igBeginChild("Roles")
          if igBeginMenu(cstring(if selectedRole1.isSome(): positionToString[selectedRole1.get()] else: "Role 1")):
            for role in positionsAll:
              if igMenuItem(cstring(positionToString[role])):
                selectedRole1 = some role
                if selectedRole2.isSome() and selectedRole2.get() == role: 
                  selectedRole2 = none Position
            igEndMenu()
          igDummy(ImVec2(x: 0.0, y: 5.0))
          if igBeginMenu(cstring(if selectedRole2.isSome(): positionToString[selectedRole2.get()] else: "Role 2")):
            for role in positionsAll:
              if selectedRole1.isSome() and selectedRole1.get() == role: continue
              if igMenuItem(cstring(positionToString[role])):
                selectedRole2 = some role
            igEndMenu()
          igEndChild()
        igNextColumn()
        block:
          igDummy(ImVec2(x: 10.0, y: 0.0))
          igSameLine()
          if igButton("Play", ImVec2(x: 256, y: 64)): discard

        igNextColumn()
        block:
          if igBeginMenu(cstring(if selectedSummoner1.isSome(): summonerToString[selectedSummoner1.get()] else: "Select 1. Summoner")):
            for summoner in availableSummoners:
              if igMenuItem(cstring(summonerToString[summoner])):
                selectedSummoner1 = some summoner
                if selectedSummoner2.isSome() and selectedSummoner2.get() == summoner: 
                  selectedSummoner2 = none SummonerSpell
            igEndMenu()
          igDummy(ImVec2(x: 0.0, y: 5.0))
          if igBeginMenu(cstring(if selectedSummoner2.isSome(): summonerToString[selectedSummoner2.get()] else: "Select 2. Summoner")):
            for summoner in availableSummoners:
              if selectedSummoner1.isSome() and selectedSummoner1.get() == summoner: continue
              if igMenuItem(cstring(summonerToString[summoner])):
                selectedSummoner2 = some summoner
            igEndMenu()
        igEndColumns()
        igEndChild()
      igEndChild()
    igNextColumn()
    block:
      igBeginChild("FriendList")
      for i in 0..50:
        if igButton(cstring(fmt"Friend {i}"), ImVec2(x: 256 - 15, y: 42)):
          echo fmt"{i}"
      igEndChild()
    igEndColumns()
    igEnd()
    if showProfile:
      igBegin("Profile")
      igEnd()

    if showRunes:
      igBegin("Runes")
      igColumns(3)
      igSetColumnOffset(1, 128)
      block:
        igText("Pages:")
        igInputText("", runePageNameNew[0].addr, runePageNameNew.len().uint)
        igSameLine()
        if igButton("+"):
          echo "added: ", runePageNameNew
          runePageNameNew = newString(40)
      igNextColumn()
      block:
        igBeginChild("Page Primary")
        if igBeginMenu(cstring(if currentRunePrimary.isNone(): "Primary" else: perkCategoryToString[currentRunePrimary.get()])):
          for category in perkCategoriesAll:
            if currentRunePrimary.isSome() and currentRunePrimary.get() == category: continue
            if igMenuItem(cstring(perkCategoryToString[category])):
              currentRunePrimary = some category
              if currentRuneSecondary.isSome() and currentRuneSecondary.get() == category:
                currentRuneSecondary = none PerkCategory
          igEndMenu()
        if currentRunePrimary.isSome():
          runeMenu(currentRunePrimary.get(), selectedRunes, true)
        igEndChild()

      igNextColumn()
      block:
        igBeginChild("Page Secondary")
        if igBeginMenu(cstring(if currentRuneSecondary.isNone(): "Secondary" else: perkCategoryToString[currentRuneSecondary.get()])):
          for category in perkCategoriesAll:
            if currentRuneSecondary.isSome() and currentRuneSecondary.get() == category: continue
            if currentRunePrimary.isSome() and currentRunePrimary.get() == category: continue
            if igMenuItem(cstring(perkCategoryToString[category])):
              currentRuneSecondary = some category
          igEndMenu()
        if currentRuneSecondary.isSome():
          runeMenu(currentRuneSecondary.get(), selectedRunes, false)
        igEndChild()
      
      igEndColumns()
      igEnd()

    if showInventory:
      igBegin("Inventory")
      igEnd()

    if showChampions:
      igBegin("Champions")
      igText("Not implemented yet")
      igEnd()

    if showSkins:
      igBegin("Skins")
      igText("Not implemented yet")
      igEnd()

    if showDodgelist:
      igBegin("Dodge List")
      igText("Not implemented yet")
      igEnd()

    if showDebugMenu:
      igBegin("Debug Menu")
      igText("Not implemented yet")
      igEnd()
  )


main()