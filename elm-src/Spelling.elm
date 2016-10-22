port module Spelling exposing (..)

import Html exposing (..)
import Html.App as App

import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String
import List exposing (..)
import Debug


main : Program Never
main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL

type alias Model =
  { word : String
  , suggestions : List String
  , tabs : List (List String)
  }

init : (Model, Cmd Msg)
init =
  (Model "" [] [], Cmd.none)


-- UPDATE

type Msg
  = Change String
  | Check
  | Suggest (List String)
  | Tabs (List (List String))


port check : String -> Cmd msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let _ = Debug.log "my message" Tabs
  in
  case msg of
    Change newWord ->
      ( Model newWord [] model.tabs, Cmd.none )

    Check ->
      ( model, check model.word )

    Suggest newSuggestions ->
      ( Model model.word newSuggestions model.tabs, Cmd.none )

    Tabs tabs ->
      ( Model model.word [] tabs, Cmd.none )


-- SUBSCRIPTIONS

port suggestions : (List String -> msg) -> Sub msg
port initialTabs : ( List (List String) -> msg ) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ suggestions Suggest
  , initialTabs Tabs
  ]



-- VIEW



view : Model -> Html Msg
view model =
  div [ class "pa5" ]
    [ input [ onInput Change ] []
    , button [ onClick Check ] [ text "Check" ]
    , div [] [ text (String.join ", " model.suggestions) ]
    , ul [ class "pa0"] (List.map toLi model.tabs)
    ]

toLi : List String -> Html msg
toLi s =
  li [ class "list pa2"] [ text (toString s ) ]
