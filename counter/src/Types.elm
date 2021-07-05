module Types exposing (..)

import Lamdera exposing (ClientId, SessionId)
import Set exposing (Set)


type alias BackendModel =
    { counter : Int
    }


type alias FrontendModel =
    { counter : Int
    , clientId : String
    }


type FrontendMsg
    = Increment
    | Decrement
    | FNoop


type ToBackend
    = CounterIncremented
    | CounterDecremented


type BackendMsg
    = ClientConnected SessionId ClientId
    | Noop


type ToFrontend
    = CounterNewValue Int String
