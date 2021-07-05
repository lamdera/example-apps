module Backend exposing (Model, app)

import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import Set exposing (Set, map)
import Task
import Types exposing (..)


app =
    Lamdera.backend
        { init = init
        , update = update
        , subscriptions = subscriptions
        , updateFromFrontend = updateFromFrontend
        }


type alias Model =
    BackendModel


init : ( Model, Cmd BackendMsg )
init =
    ( { messages = [] }, Cmd.none )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        -- A new client has joined! Send them history, and let everyone know
        ClientConnected sessionId clientId ->
            ( model
            , Cmd.batch
                [ broadcast (MessageReceived (Joined clientId))
                , sendToFrontend clientId (HistoryReceived model.messages)
                ]
            )

        -- A client has disconnected, let everyone know
        ClientDisconnected sessionId clientId ->
            ( model, broadcast (MessageReceived (Left clientId)) )

        BNoop ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        -- A client has sent us a new message! Add it to our messages list, and broadcast it to everyone.
        MsgSubmitted text ->
            ( { model | messages = Message clientId text :: model.messages }
            , broadcast (MessageReceived (Message clientId text))
            )


subscriptions model =
    Sub.batch
        [ Lamdera.onConnect ClientConnected
        , Lamdera.onDisconnect ClientDisconnected
        ]
