port module Spelling exposing (..)

import Html exposing (..)
import Html.App as App

import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List exposing (..)
import Dom exposing (..)
import Task exposing (..)
import String exposing (isEmpty)

-- import Debug
-- import Events exposing (..)

import Html.Events exposing (..)
import Json.Decode exposing (..)
import Events exposing (onKeyboardEvent)

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

type alias Model =
  { tabs : List TabsList
  , savedTabs : List TabsList
  , tabIndex : Int
  , render: Bool
  , username: String
  , password: String
  , loggedIn: String
  , logInFail: String
  , logInSuccess: String
  }


init : (Model, Cmd msg)
init =
  (Model [] [] 0 True "" "" "" "" "", Cmd.none )


-- UPDATE

type Msg
  = Tabs (List TabsList)
  | TabsSaved (List TabsList)
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
  | LogIn
  | UpdateUserName String
  | UpdatePassword String
  | SuccessLogIn String
  | FailLogIn String
  | NoOp

port close : Int -> Cmd msg
port save : TabsList -> Cmd msg
port activate : Int -> Cmd msg
port delete : String -> Cmd msg
port open : String -> Cmd msg
port logIn : (String, String) -> Cmd msg

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
      ({ model | tabs = List.map (setTabSaved tab) model.tabs }, save tab )
            -- ({ model | tab = List.map (setTitleAtID tab tab.index) model.posts , Effects.none )
      -- let
      --   newModel =
      --     update (tabs => tab => saved) (\saved -> True) model
      -- in
        -- (model, save tab)

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

    UpdateUserName val ->
      ({  model | username = val }, Cmd.none)

    UpdatePassword val ->
      ({  model | password = val }, Cmd.none)

    LogIn ->
        let
            data = (model.username, model.password)
        in
      (model, logIn data )

    SuccessLogIn message ->
      ({ model | logInSuccess = message }, Cmd.none)

    FailLogIn message ->
      ({model | logInFail = message }, Cmd.none)

    NoOp ->
      ( model, Cmd.none )

-- Update functions
-- wut is this anotactions
setTabSaved: { b | index : a } -> { c | index : a, saved : Bool } -> { c | index : a, saved : Bool }
setTabSaved tab tabs =
  if tab.index == tabs.index then
    { tabs | saved = True }
  else
    tabs

-- SUBSCRIPTIONS

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

isLoggedIn: Model -> Html Msg
isLoggedIn model =
  ( if String.isEmpty model.logInSuccess then login model else app model )



-- root view component
view : Model -> Html Msg
view model =
  div [ class "pa2 w-100 flex flex-column login-container "]
  [ div [ class "w-100 flex flex-column container " ] [ isLoggedIn model ] ]


-- Login Gatekeeper
login: Model -> Html Msg
login model =
  div [ class "pa2 w-100 flex flex-column" ]
  [ h1 [ class "pa2 tc white" ] [ text "Please Log In" ]
    , h2 [ class "pa2 tc white" ] [ text model.logInFail ]
    , input [ type' "text", placeholder "UserName", class "login-input", onInput UpdateUserName ] []
    , input [ type' "password", placeholder "Password", class "login-input", onInput UpdatePassword ] []
    , button [ onClick ( LogIn ), class "login-submit" ] [ text "Log In" ]
  ]


-- App parent
app : Model -> Html Msg
app model =
  div [] [
    div [ class "w-100 flex flex-row container self-center" ]  [
          div [ class ( "render-tabs pa2 w-50 flex justify-center" ++ ( if model.render then " active" else "" ))
          , onClick ShowCurrent ]  [ text "Current" ]
        , div [ class ( "render-tabs pa2 w-50 flex justify-center" ++ ( if model.render == False then " active" else "" ))
        , onClick ShowSaved ]  [ text "Saved" ]
      ]
    , div [ class "w-100 flex flex-column container " ]  [ renderList model ]
  ]


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
    , savedTab tab
    , button [ class "w-10 tc red ms-pt btn hover-style", onClick ( Close tab.tabID ), tabindex -1 ] [ text  "X" ]
    ]
  ]

savedTab : TabsList -> Html Msg
savedTab tab =
  if tab.saved then
    p [ class "w-20 tc saved" ] [ text  "saved"  ]
  else
    p [ class "w-20 ms-pt tc", onClick ( Save tab ) ] [ text  "save"  ]


-- Saved view below

savedTabsList : List TabsList -> Html Msg
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
    , div [ class "w-80", onClick ( Open saved.url ) ] [ text saved.title ]
    , button [ class "w-20 tc red ms-pt btn hover-style", onClick ( Delete saved.url ), tabindex -1 ] [ text  "X" ]
    ]
  ]
