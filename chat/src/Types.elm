module Types exposing (..)

import Lamdera exposing (ClientId, SessionId)


type alias FrontendModel =
    { messages : List ChatMsg, messageFieldContent : String }


type alias BackendModel =
    { messages : List ChatMsg }


type FrontendMsg
    = MessageFieldChanged String
    | MessageSubmitted
    | Noop


type ToBackend
    = MsgSubmitted String


type BackendMsg
    = ClientConnected SessionId ClientId
    | ClientDisconnected SessionId ClientId
    | BNoop


type ToFrontend
    = HistoryReceived (List ChatMsg)
    | MessageReceived ChatMsg


type ChatMsg
    = Joined ClientId
    | Left ClientId
    | Message ClientId String
