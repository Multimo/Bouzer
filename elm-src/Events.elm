module Events exposing (..)

import Html.Events exposing (..)
import Html exposing (Attribute)
import Json.Decode exposing (..)

onEnter: msg -> Attribute msg
onEnter msg =
    onKeyUp [ ( 13, msg ) ]

onRightArrow: msg -> Attribute msg
onRightArrow msg =
    onKeyUp [ ( 39, msg ) ]

onLeftArrow: msg -> Attribute msg
onLeftArrow msg =
    onKeyUp [ ( 37, msg ) ]

onUpArrow: msg -> Attribute msg
onUpArrow msg =
    onKeyUp [ ( 38, msg ) ]

onDownArrow: msg -> Attribute msg
onDownArrow msg =
    onKeyUp [ ( 40, msg ) ]

onEnterOrLeft: msg -> Attribute msg
onEnterOrLeft msg =
    onKeyUp [ ( 13, msg ), ( 37, msg ) ]

onBackOrRight: msg -> Attribute msg
onBackOrRight msg =
    onKeyUp [ ( 39, msg ), ( 8, msg ) ]


-- -- onKeyboardEvent : keyCode -> Attribute msg
-- onKeyboardEvent payload =
--     let
--         tagger code =
--             if code == 13 || code == 37 then
--               Activate payload
--             else if code == 8 || code == 39 then
--               Close payload
--             else
--               NoOp
--     in
--         on "keydown" (Json.map tagger keyCode)


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
