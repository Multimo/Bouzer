-- elm make elm-src/Main.elm --warn --output="js/elm.js"

--  command + option + t will open the popup menu

-- from there there will be multiple options:
-- save all their current tabs for later viewing
-- sort through them with fuzzy search
-- close tabs base on criteria

-- Click on the the tooling button which will show that it has been clicked and have a link to options page
-- it will gather all urls from all currentWindow and send it to the options page where they can be viewed as they have been stored
-- they can also be added and deleted and edited individually.

-- store them in firebase? or locally?


-- elmsrc/Main.elm
port module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (onInput, onClick)
import Html.Attributes exposing (..)


-- input ports
port jsToElm : (String -> msg) -> Sub msg

-- output ports
port elmToJs : String -> Cmd msg

type alias Flags = { jsToElm : String }



main =
    App.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }

init : (Model, Cmd Msg)
init =
  ( model, Cmd.none)

-- model

type alias Model =
    { todo: String
    , todos: List String
    }

model =
    { todo = ""
    , todos = []
    }

--update


type Msg
    = UpdateText String
    | AddItem
    | RemoveItem String


update msg model =
    case msg of
        UpdateText text ->
            { model | todo = text }

        AddItem ->
            { model | todos = model.todo :: model.todos}

        RemoveItem todo ->
            { model |
                todos =
                    List.filter (\t -> t /= todo) model.todos }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



--view

  todoItem todo =
      li []
          [ text todo
          , button [ onClick (RemoveItem todo) ][ text "X"]
          ]

  todoList todos =
      let
          children = List.map todoItem todos
      in
          ul [] children

  view model =
      div []
          [ input [ type' "text"
          , onInput UpdateText
          , value model.todo
          ] []
          , button [ onClick AddItem ] [ text "Add Todo"]
          , div [] [ text model.todo ]
          , todoList model.todos
          ]
