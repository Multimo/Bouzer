port module Spelling exposing (..)

import Html exposing (..)
import Html.App as App

import Html.Attributes exposing (..)
import Html.Events exposing (..)
-- import String
import List exposing (..)
-- import Debug

import Html.Events exposing (..)
import Json.Decode exposing (..)

onEnter: a -> Attribute a
onEnter msg =
    onKeyUp [ ( 13, msg ) ]

onRightArrow: a -> Attribute a
onRightArrow msg =
    onKeyUp [ ( 39, msg ) ]

onLeftArrow: a -> Attribute a
onLeftArrow msg =
    onKeyUp [ ( 37, msg ) ]

onUpArrow: a -> Attribute a
onUpArrow msg =
    onKeyUp [ ( 38, msg ) ]

onDownArrow: a -> Attribute a
onDownArrow msg =
    onKeyUp [ ( 40, msg ) ]




onEnterOrLeft enter escape =
    onKeyUp [ ( 13, enter ), ( 27, escape ) ]


onKeyUp options =
    let
        filter optionsToCheck code =
            case optionsToCheck of
                [] ->
                    Err "key code is not in the list"

                ( c, msg ) :: rest ->
                    if (c == code) then
                        Ok msg
                    else
                        filter rest code

        keyCodes =
            customDecoder keyCode (filter options)
    in
        on "keyup" keyCodes



main : Program Never
main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL

type alias TabsList =
  { url : String
  , title : String
  , active : Bool
  , tabID : Int
  , favIconUrl : String
  }


type alias Model =
  { word : String
  , suggestions : List String
  , tabs : List TabsList
  }

init : (Model, Cmd Msg)
init =
  (Model "" [] [], Cmd.none)


-- UPDATE

type Msg
  = Change String
  | Check
  | Suggest (List String)
  | Tabs (List TabsList)
  | Close Int
  | Activate Int


port check : String -> Cmd msg
port close : Int -> Cmd msg
port activate : Int -> Cmd msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Change newWord ->
      ( Model newWord [] model.tabs, Cmd.none )

    Check ->
      ( model, check model.word )

    Suggest newSuggestions ->
      ( Model model.word newSuggestions model.tabs, Cmd.none )

    Tabs tabs ->
        ( Model model.word model.suggestions tabs, Cmd.none )

    Close tabId ->
      ( model, close tabId )

    Activate tabId ->
      ( model, activate tabId )
-- SUBSCRIPTIONS

port suggestions : (List String -> msg) -> Sub msg
port initialTabs : ( List TabsList -> msg ) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ suggestions Suggest
  , initialTabs Tabs
  ]



-- VIEW




-- view : Model -> Html msg
view model =
  div [ class "pa2 w-100 flex flex-column container bg-lightest-blue" ]
    [ input [ class "w-60 self-center ma1 br3", onInput Change ] []
    , button [ class "w-40 self-center ma1 br3", onSubmit Check ] [ text "Check" ]
    , tabsList model
    ]

-- tabsList : Model -> Html msg
tabsList model =
    ul [ class "pa0 flex-column flex self-center w-100" ]
    ( List.map toLi model.tabs )


-- toLi : Model -> Html msg
toLi tab =
    a [ onRightArrow ( Close tab.tabID ), onLeftArrow ( Activate tab.tabID ), tabindex 1, class "grow" ] [
    li [ class ( "list flex flex-row pa2 w-100 items-center " ++ ( if tab.active then "bg-washed-green" else "bg-lightest-blue" ) ) ]
    [ img [ src tab.favIconUrl, height 25, width 25, class "pl2 pr2" ] [ ]
    , div [ class "w-60" ] [ text tab.title ]
    , div [ class "w-20 red", onClick ( Close tab.tabID ) ] [ text  "X" ]
    , div [ class "w-10", onClick ( Activate tab.tabID ) ] [ text  "0"  ]
    ]
  ]
