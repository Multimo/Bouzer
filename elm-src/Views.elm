module Views exposing (..)

import Events exposing (onKeyboardEvent)
import Messages exposing (..)
import Model exposing (..)
import String exposing (isEmpty)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


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
  [ div [ class "w-100 flex flex-column container " ] [ isLoggedIn model ]
  ]


-- Login Gatekeeper
login: Model -> Html Msg
login model =
  div [ class "pa2 w-100 flex flex-column" ]
  [ h1 [ class "pa2 tc white" ] [ text "Please Log In" ]
    , h2 [ class "pa2 tc white login-error" ] [ text model.logInFail ]
    , input [ type' "text", placeholder "UserName", class "login-input", onInput UpdateUserName ] []
    , input [ type' "password", placeholder "Password", class "login-input", onInput UpdatePassword ] []
    , button [ onClick ( LogIn ), class "login-submit" ] [ text "Log In" ]
    -- , h2 [ class "pa2 tc white", onClick ( ShowCreateUserView ) ] [text "Create a User"]
    , createUserView model
    , button [ onClick ( GoogleLogIn ), class "login-submit" ] [ text "Google" ]
  ]

  -- Create User view
createUserView: Model -> Html Msg
createUserView model =
    div [ class "pa2 w-100 flex flex-column" ]
    [ h2 [ class "pa2 tc white" ] [ text "Create a User" ]
      , input [ type' "text", placeholder "UserName", class "login-input", onInput UpdateUserName ] []
      , input [ type' "password", placeholder "Password", class "login-input", onInput UpdatePassword ] []
      , button [ onClick ( CreateUser ), class "login-submit" ] [ text "Create" ]
  ]


--   -- Login error message
-- loginError: Model -> Html Msg
-- loginError  =  h2 [ class "pa2 tc white" ] [ text "Please Log In" ]



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
