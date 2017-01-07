port module Spelling exposing (..)


import Html.App as App

import Messages exposing (..)
import Views exposing (..)
import Model exposing (..)

-- TODO: SETUP saved tabs read from firebase. DONE
-- TODO: update currentTabs on saved click DONE
-- TODO: autofocus on load tabindex 0? SORT OF DONE?
-- TODO: create view for saved data in saved tabs DONE
-- TODO: delete saved tabs on click DONE

-- TODO: Login page. create user and db ref && forgot password? & logout?
-- TODO: if saved and is open in current tabs saved == true (on init?)
-- TODO: Break Elm into components and Clean up shitty code
-- TODO: Drag and Drop the possition of the tabs? updates index and position
-- TODO: Better navigation via keyboard, possible config for inputs?


main : Program Never
main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



init : (Model, Cmd msg)
init =
  (Model [] [] 0 True "" "" "" "" "", Cmd.none )



-- Ports in
port initialTabs : ( List TabsList -> msg ) -> Sub msg
port savedTabs : ( List TabsList -> msg ) -> Sub msg
port logInSuccess : ( String -> msg ) -> Sub msg
port logInFail : ( String -> msg ) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ initialTabs Tabs
  , savedTabs TabsSaved
  , logInSuccess SuccessLogIn
  , logInFail FailLogIn
  ]
