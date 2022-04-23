import std/[options, os, strformat, strutils, tables]

import riftlib/types/consts
import ./types
import ./widgets/runes
import ./utils

type
  StateKind* = enum
    skNothing
    skPlanning
    skSearching
    skChampSelect
    skIngame
    skPostGame

  State* = ref object
    case kind*: StateKind
    of skNothing: discard
    of skPlanning, skSearching: 
      lobby*: Lobby
    of skChampSelect:
      champSelect*: ChampSelect
    of skIngame:
      inagme*: IngameLobby
    of skPostGame: discard

  LocalSettings* = ref object
    defaultQueue*: Option[Queue]
    defaultRunepage*: Option[string]
    defaultSummoners*: tuple[primary, secondary: Option[SummonerSpell]]
    defaultRoles*: tuple[primary, secondary: Option[Position]]

  UserData* = ref object
    runes*: tuple[current: RunePage, all: seq[RunePage], edit: RuneEditPage]
    localSettings*: Table[SummonerId, LocalSettings]
    dodgeList*: DodgeList

  Instance* = ref object
    id: SummonerId
    me*: Account
    state*: State
    friendList*: FriendList
    
  Launcher* = ref object
    userData*: UserData
    current*: Option[Instance]
    accounts*: seq[Account]
    instances*: Table[SummonerId, Instance]

  LauncherUI* = ref object
    show*: tuple[profile, runes, inventory, champions, skins, dodgelist, debug: bool]
    selectedQueue*: bool
    runeError*: Option[string] 



proc newLauncher*(): (Launcher, LauncherUI) =
  let data = Launcher()
  let ui = LauncherUI()

  data.userData = UserData(
    runes: (current: RunePage(), all: loadRunes(), edit: newEmptyEditPage()), 
    localSettings: initTable[SummonerId, LocalSettings](),
  )

  (data, ui)

proc newMockUpLauncher*(): (Launcher, LauncherUI) =
  var (data, ui) = newLauncher()
  let accounts = [
    Account(id: 34729342, name: "Your Little Meow", accountName: "your little meow", 
    solo: Rank(tier: Tier.Diamond, division: Division.IV), flex: Rank(tier: Tier.Gold, division: Division.III)),
    Account(id: 34729322, name: "No Cat Complex", accountName: "no cat complex", 
    solo: Rank(tier: Tier.Platinum, division: Division.IV), flex: Rank(tier: Tier.Unranked, division: Division.NA)),
    Account(id: 34725342, name: "S12 Player XD", accountName: "s12 player xd", 
    solo: Rank(tier: Tier.Gold, division: Division.IV), flex: Rank(tier: Tier.Unranked, division: Division.NA))
  ]

  for account in accounts:
    data.accounts.add account

  let instance = Instance(
    id: 34729342.SummonerId,
    me:Account(id: 34729342, name: "Your Little Meow", accountName: "your little meow", 
      solo: Rank(tier: Tier.Diamond, division: Division.IV), flex: Rank(tier: Tier.Gold, division: Division.III)),
    state: State(
      kind: skPlanning, 
      lobby: Lobby(
        leader: 34729342.SummonerId,
        members: @[
          LobbyMember(
            id: 34729342.SummonerId, 
            name: "Your Little Meow", 
            accountName: "your little meow#EUW", 
            solo: Rank(tier: Tier.Diamond, division: Division.IV), 
            flex: Rank(tier: Tier.Gold, division: Division.III),
            position1: Position.Middle,
            position2: Position.Utility
          ),
          LobbyMember(
            id: 34729322.SummonerId, 
            name: "No Cat Complex", 
            accountName: "no cat complex#EUW", 
            solo: Rank(tier: Tier.Platinum, division: Division.IV), 
            flex: Rank(tier: Tier.Unranked, division: Division.NA),
            position1: Position.Jungle,
            position2: Position.Unselected
          ),
        ],
        queue: Queue.RankedSolo5x5
      )
    )
  )

  data.instances[data.accounts[0].id] = instance
  data.current = some instance
  
  ui.selectedQueue = true
  

  result = (data, ui)


proc getMeFromLobby*(instance: Instance): Option[LobbyMember] =
  if instance.state.kind != skPlanning and instance.state.kind != skSearching:
    return none LobbyMember

  for member in instance.state.lobby.members:
    if member.id == instance.id:
      return some member

proc saveStr*(settings: Table[SummonerId, LocalSettings]): string =
  for id, setting in settings.pairs():
    result.add fmt"""
[Settings.LocalSettings.{id}]
defaultQueue = "{setting.defaultQueue}"
defaultRunepage = "{setting.defaultRunepage}"
defaultSummoners = {{
  primary = "{setting.defaultSummoners.primary}",
  secondary = "{setting.defaultSummoners.secondary}"
}}
defaultRoles = {{
  primary = "{setting.defaultRoles.primary}",
  secondary = "{setting.defaultRoles.secondary}"
}}
"""

proc saveStr*(list: DodgeList): string =
  result.add "[Dodgelist]\n"
  for entry in list.entries:
    result.add fmt"""
[Dodgelist.{entry.id}]
updated = "{entry.updated}"
name = "{entry.name}"
reason = "{entry.reason}"
"""


proc saveStr*(ui: LauncherUI): string =
  result.add fmt"""
[Settings.UI]
show = {{
  profile = {ui.show.profile},
  runes = {ui.show.runes},
  inventory = {ui.show.inventory},
  champions = {ui.show.champions},
  skins = {ui.show.skins},
  dodgelist = {ui.show.dodgeList},
  debug = {ui.show.debug},
}}
"""

proc saveState*(data: Launcher, ui: LauncherUI) =
  let uiStr = ui.saveStr()
  let localStr = data.userData.localSettings.saveStr()
  let dodgeStr = data.userData.dodgeList.saveStr()

  var settings: string
  settings.add "[Settings]\n"
  settings.add uiStr
  settings.add localStr

  saveData("settings.toml", settings)
  saveData("dodgelist.toml", dodgeStr)