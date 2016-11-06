port module Spelling exposing (..)

import Html exposing (..)
import Html.App as App

import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List exposing (..)
import Dom exposing (..)
import Task exposing (..)

-- import Debug
-- import Events exposing (..)

import Html.Events exposing (..)
import Json.Decode exposing (..)

onKeyboardEvent: Int -> Attribute Msg
onKeyboardEvent tabID =
    let
        tagger code =
            if code == 13 || code == 37 then
              Activate tabID
            else if code == 8 || code == 39 then
              Close tabID
            else if code == 38 || code == 9 then
              CycleUp
            else if code == 40 then
              CycleDown
            else
              NoOp
    in
        on "keydown" (Json.Decode.map tagger keyCode)



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
  , index : Int
  , active : Bool
  , tabID : Int
  , favIconUrl : String
  }


type alias Model =
  { word : String
  , suggestions : List String
  , tabs : List TabsList
  , tabIndex : Int
  }

init : (Model, Cmd Msg)
init =
  (Model "" [] [] 0, Cmd.none)


-- UPDATE

type Msg
  = Tabs (List TabsList)
  | Close Int
  | Activate Int
  | CycleUp
  | CycleDown
  | NoOp



port close : Int -> Cmd msg
port activate : Int -> Cmd msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tabs val ->
      ({ model | tabs = val }, Cmd.none )

    Close tabId ->
      ( model, close tabId )

    Activate tabId ->
      ( model, activate tabId )

    CycleUp ->
      let
          cmd =
              focus ( toString ( model.tabIndex - 1 ) )
                |> Task.perform (\error -> NoOp ) (\() -> NoOp)
      in
          ({ model | tabIndex = ( model.tabIndex - 1 ) }, cmd )

    CycleDown ->
      let
          cmd =
              focus ( toString ( model.tabIndex + 1 ) )
                  |> Task.perform (\error -> NoOp ) (\() -> NoOp)
      in
          ({ model | tabIndex = ( model.tabIndex + 1 ) }, cmd )

    NoOp ->
      ( model, Cmd.none )




-- SUBSCRIPTIONS

-- port suggestions : (List String -> msg) -> Sub msg
port initialTabs : ( List TabsList -> msg ) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ initialTabs Tabs
  ]



-- VIEW
isFirst: number -> Bool
isFirst index =
    if index == 0 then
      True
    else
      False


view : Model -> Html Msg
view model =
  div [ class "pa2 w-100 flex flex-column container bg-lightest-blue" ]
    [ input [ class "w-60 self-center ma1 br3", tabindex -1 ] []
    , button [ class "w-40 self-center ma1 br3", tabindex -1 ] [ text "Check" ]
    , tabsList model
    ]

tabsList : Model -> Html Msg
tabsList model =
    ul [ class "pa0 flex-column flex self-center w-100" ]
    ( List.map toLi model.tabs )

toLi : TabsList -> Html Msg
toLi tab =
    div [  onClick ( Activate tab.tabID )
    , onKeyboardEvent tab.tabID
    , tabindex 1
    , autofocus (isFirst tab.index)
    , class ( "grow tabsli " ++ ( if tab.active then "bg-washed-green" else "bg-washed-blue" ) )
    , id ( toString tab.index )  ] [
    li [ class "list flex flex-row pa2 w-100 items-center"]
    [ img [ src tab.favIconUrl, height 25, width 25, class "pl2 pr2" ] [ ]
    , div [ class "w-60" ] [ text tab.title ]
    , div [ class "w-20 bg-light-silver red", onClick ( Close tab.tabID ) ] [ text  "X" ]
    , div [ class "w-10", onClick ( Activate tab.tabID ) ] [ text  "0"  ]
    ]
  ]
