import std/[times, options]
import riftlib/types/[consts, champions]

type
  RunePage* = ref object
    name*: string
    primary*: PerkCategory
    secondary*: PerkCategory
    runes*: array[9, Perk]

  RuneEditPage* = ref object
    name*: string
    primary*: Option[PerkCategory]
    secondary*: Option[PerkCategory]
    runes*: array[9, Option[Perk]]
  
  Rank* = object
    tier*: Tier
    division*: Division
    games: tuple[wins, losses: int]
    promo*: Option[tuple[wins, losses: int]]

  LoginAccount* = object
    loginName: string
    password: string

  Account* = object
    id*: SummonerId
    name*: string
    accountName*: string
    icon*: int64
    description*: string
    solo*: Rank
    flex*: Rank


  FriendList* = object
    id*: SummonerId
    name*: string
    accountName*: string
    solo*: Rank
    flex*: Rank
    chat*: string

  LobbyMember* = object
    id*: SummonerId
    name*: string
    accountName*: string
    solo*: Rank
    flex*: Rank
    position1*: Position
    position2*: Position
  
  ChampSelectMember* = object
    id*: SummonerId
    name*: string
    accountName*: string
    solo*: Rank
    flex*: Rank
    position*: Position
    pick*: Option[Champion]
    ban*: Option[Champion]

  ChampSelectMemberEnemy* = object
    position*: Position
    pick*: Option[Champion]
    ban*: Option[Champion]

  LobbyState* = enum
    lsBuilding
    lsReady
    lsSearching
    lsAccept
    lsDecline

  Lobby* = ref object
    timer*:float
    lolTimer*: float
    leader*: SummonerId
    members*: seq[LobbyMember]
    state*: LobbyState
    queue*: Queue

  ChampSelectState* = enum
    cssPrePick
    cssBan
    cssBanReveal
    cssPick
    cssWaitForStart

  ChampSelect* = ref object
    backUpLobby*: Lobby
    team*: seq[ChampSelectMember]
    enemy*: seq[ChampSelectMemberEnemy]
  
  IngameLobby* = ref object
    team*: seq[ChampSelectMember]
    enemy*: seq[ChampSelectMember]

  DodgeListEntry* = ref object
    updated*: DateTime
    id*: SummonerId
    name*: string
    reason*: string

  DodgeList* = ref object
    entries*: seq[DodgeListEntry]



