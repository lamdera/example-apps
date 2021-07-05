module Frontend exposing (Model, app)

import Browser.Dom as Dom
import Debug exposing (toString)
import Html exposing (Html, button, div, input, text)
import Html.Attributes exposing (autofocus, id, placeholder, style, type_, value)
import Html.Events exposing (keyCode, on, onClick, onInput)
import Json.Decode as D
import Lamdera
import Task
import Types exposing (..)


{-| Lamdera applications define 'app' instead of 'main'.

Lamdera.frontend is the same as Browser.application with the
additional update function; updateFromBackend.

-}
app =
    Lamdera.frontend
        { init = \_ _ -> init
        , update = update
        , updateFromBackend = updateFromBackend
        , view =
            \model ->
                { title = "Lamdera chat demo"
                , body = [ view model ]
                }
        , subscriptions = \m -> Sub.none
        , onUrlChange = \_ -> Noop
        , onUrlRequest = \_ -> Noop
        }


type alias Model =
    FrontendModel


init : ( Model, Cmd FrontendMsg )
init =
    ( { messages = [], messageFieldContent = "" }, Cmd.none )


{-| This is the normal frontend update function. It handles all messages that can occur on the frontend.
-}
update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        -- User has changed the contents of the message field
        MessageFieldChanged s ->
            ( { model | messageFieldContent = s }, Cmd.none )

        -- User has hit the Send button
        MessageSubmitted ->
            ( { model | messageFieldContent = "", messages = model.messages }
            , Cmd.batch
                [ Lamdera.sendToBackend (MsgSubmitted model.messageFieldContent)
                , focusMessageInput
                , scrollChatToBottom
                ]
            )

        -- Empty msg that does no operations
        Noop ->
            ( model, Cmd.none )


{-| This is the added update function. It handles all messages that can arrive from the backend.
-}
updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        HistoryReceived messages ->
            ( { model | messages = messages }, Cmd.batch [ scrollChatToBottom ] )

        MessageReceived message ->
            ( { model | messages = message :: model.messages }, Cmd.batch [ scrollChatToBottom ] )


view : Model -> Html FrontendMsg
view model =
    div (style "padding" "10px" :: fontStyles)
        [ model.messages
            |> List.reverse
            |> List.map viewMessage
            |> div
                [ id "message-box"
                , style "height" "400px"
                , style "overflow" "auto"
                , style "margin-bottom" "15px"
                ]
        , chatInput model MessageFieldChanged
        , button (onClick MessageSubmitted :: fontStyles) [ text "Send" ]
        ]


chatInput : Model -> (String -> FrontendMsg) -> Html FrontendMsg
chatInput model msg =
    input
        ([ id "message-input"
         , type_ "text"
         , onInput msg
         , onEnter MessageSubmitted
         , placeholder model.messageFieldContent
         , value model.messageFieldContent
         , style "width" "300px"
         , autofocus True
         ]
            ++ fontStyles
        )
        []


viewMessage : ChatMsg -> Html msg
viewMessage msg =
    case msg of
        Joined clientId ->
            div [ style "font-style" "italic" ] [ text <| String.left 6 clientId ++ " joined the chat" ]

        Left clientId ->
            div [ style "font-style" "italic" ] [ text <| String.left 6 clientId ++ " left the chat" ]

        Message clientId message ->
            div [] [ text <| "[" ++ String.left 6 clientId ++ "]: " ++ message ]


fontStyles : List (Html.Attribute msg)
fontStyles =
    [ style "font-family" "Helvetica", style "font-size" "14px", style "line-height" "1.5" ]


scrollChatToBottom : Cmd FrontendMsg
scrollChatToBottom =
    Dom.getViewportOf "message-box"
        |> Task.andThen (\info -> Dom.setViewportOf "message-box" 0 info.scene.height)
        |> Task.attempt (\_ -> Noop)


focusMessageInput : Cmd FrontendMsg
focusMessageInput =
    Task.attempt (always Noop) (Dom.focus "message-input")


onEnter : FrontendMsg -> Html.Attribute FrontendMsg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                D.succeed msg

            else
                D.fail "not ENTER"
    in
    on "keydown" (keyCode |> D.andThen isEnter)
