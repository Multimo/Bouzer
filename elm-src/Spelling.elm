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

-- TODO: SETUP saved tabs read from firebase.
-- TODO: update currentTabs on saved click
-- TODO: autofocus on load tabindex 0? SORT OF DONE?
-- TODO: create view for saved data in saved tabs DONE
-- TODO: delete saved tabs on click


onKeyboardEvent: TabsList -> Attribute Msg
onKeyboardEvent tab =
    let
        tagger code =
            if code == 13 || code == 37 then
              Activate tab.tabID
            else if code == 8 || code == 39 then
              Close tab.tabID
            else if code == 38 || code == 9 then
              CycleUp
            else if code == 40 then
              CycleDown
            else if code == 9 then
              Save tab
            else
              NoOp
    in
        on "keydown" (Json.Decode.map tagger keyCode)


-- focusCmd : ListTab String -> Cmd Msg
-- focusCmd tabindex direction =
--   let
--         focus ( toString ( Model.tabIndex ) )
--             |> Task.perform (\error -> NoOp ) (\() -> NoOp)
--
--   in


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
  , saved : Bool
  , favIconUrl : String
  }

type alias SavedList =
  { active : Bool
  , favIconUrl : String
  , index : Int
  , saved : Bool
  , tabID : Int
  , title : String
  , url : String
  }


type alias Model =
  { tabs : List TabsList
  , savedTabs : List SavedList
  , tabIndex : Int
  , render: Bool
  }

init : (Model, Cmd msg)
init =
  (Model [] [] 0 True, Cmd.none )


-- UPDATE

type Msg
  = Tabs (List TabsList)
  | TabsSaved (List SavedList)
  | Close Int
  | Activate Int
  | CycleUp
  | CycleDown
  | Save TabsList
  | Delete String
  | Open String
  | Focus Int
  | ShowCurrent
  | ShowSaved
  | NoOp

port close : Int -> Cmd msg
port save : TabsList -> Cmd msg
port activate : Int -> Cmd msg
port delete : String -> Cmd msg
port open : String -> Cmd msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tabs val ->
      ({ model | tabs = val }, Cmd.none )

    TabsSaved val ->
      ({ model | savedTabs = val }, Cmd.none )

    Close tabId ->
      ( model, close tabId )

    Activate tabId ->
      ( model, activate tabId )

    Save tab ->
      ( model , save tab )

    Delete val ->
      ( model , delete val )

    Open val ->
      ( model , open val )

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

    Focus index ->
        let
            cmd =
                focus ( toString ( model.tabIndex ) )
                    |> Task.perform (\error -> NoOp ) (\() -> NoOp)
        in
        (model , cmd )

    ShowCurrent ->
        ({ model | render = True }, Cmd.none )

    ShowSaved ->
        ({ model | render = False }, Cmd.none )

    NoOp ->
      ( model, Cmd.none )




-- SUBSCRIPTIONS

port initialTabs : ( List TabsList -> msg ) -> Sub msg
port savedTabs : ( List SavedList -> msg ) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ initialTabs Tabs
  , savedTabs TabsSaved
  ]



-- VIEW
isFirst: number -> Bool
isFirst index =
    if index == 0 then
      True
    else
      False

renderList: Model -> Html Msg
renderList model =
  ( if model.render == True then tabsList model.tabs else savedTabsList model.savedTabs )

view : Model -> Html Msg
view model =
  div [ class "pa2 w-100 flex flex-column container bg-lightest-blue"]
  [ div [ class "w-100 flex flex-row container self-center bg-lightest-blue" ]  [
        div [ class "pa2 w-50 flex self-center justify-center bg-lightest-blue", onClick ShowCurrent ]  [ text "Current" ]
      , div [ class "pa2 w-50 flex self-center justify-center bg-lightest-blue", onClick ShowSaved ]  [ text "Saved" ]
    ]
  , div [ class "pa2 w-100 flex flex-column container bg-lightest-blue" ]  [ renderList model ]
  , div [] [ text ( toString model ) ]
  ]


    --input [ class "w-60 self-center ma1 br3", tabindex -1 ] []
    -- , button [ class "w-40 self-center ma1 br3", tabindex -1 ] [ text "Check" ]

-- Active tabs view below

tabsList : List TabsList -> Html Msg
tabsList tabs =
    ul [ class "pa0 flex-column flex self-center w-100" ]
    ( List.map toLi tabs )


toLi : TabsList -> Html Msg
toLi tab =
    div [ onKeyboardEvent tab
    , tabindex 1
    , autofocus (isFirst tab.index)
    , class ( "tabsli hover-style focus-style" ++ ( if tab.active then " active" else "" ) )
    , id ( toString tab.index )  ] [
    li [ class "list flex flex-row pa3 w-100 items-center"]
    [ img [ src tab.favIconUrl, height 25, width 25, class "pl2 pr2" ] [ ]
    , div [ class "w-60", onClick ( Activate tab.tabID ) ] [ text tab.title ]
    , p [ class "w-20 ms-pt tc", onClick ( Save tab ) ] [ text  "save"  ]
    , button [ class "w-10 tc red ms-pt btn hover-style", onClick ( Close tab.tabID ), tabindex -1 ] [ text  "X" ]
    ]
  ]

-- Saved view below

savedTabsList : List SavedList -> Html Msg
savedTabsList savedTabs =
    ul [ class "pa0 flex-column flex self-center w-100" ]
    ( List.map toSavedLi savedTabs )


toSavedLi : TabsList -> Html Msg
toSavedLi saved =
    div [ onKeyboardEvent saved
    , tabindex 1
    , autofocus (isFirst saved.index)
    , class ( "tabsli hover-style focus-style" )
    , id ( toString saved.index )  ] [
    li [ class "list flex flex-row pa3 w-100 items-center"]
    [ img [ src saved.favIconUrl, height 25, width 25, class "pl2 pr2" ] [ ]
    , div [ class "w-60", onClick ( Open saved.url ) ] [ text saved.title ]
    , button [ class "w-40 tc red ms-pt btn hover-style", onClick ( Delete saved.title ), tabindex -1 ] [ text  "X" ]
    ]
  ]
