module Events exposing (onKeyboardEvent)

import Json.Decode exposing (..)
import Spelling exposing (..)
import Messages exposing (..)

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
            else if code == 9 || code == 83 then
              Save tab
            else if code == 48 then
              ShowSaved
            else if code == 49 then
              ShowCurrent
            else
              NoOp
    in
        on "keydown" (Json.Decode.map tagger keyCode)
