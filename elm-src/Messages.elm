port module Messages exposing (..)

-- Dependencies
import Model exposing (..)
import Dom exposing (..)
import Task exposing (..)

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
  | LogOut
  | GoogleLogIn
  | CreateUser
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
port createUser : (String, String) -> Cmd msg
port logOut :  (String, String) -> Cmd msg

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

    LogOut ->
        let
            data = (model.username, model.password)
        in
      ({ model | logInSuccess = "" }, logOut data )

    GoogleLogIn ->
      (model, Cmd.none)

    CreateUser ->
        let
            data = (model.username, model.password)
        in
      (model, createUser data )


    SuccessLogIn message ->
      ({ model | logInSuccess = message }, Cmd.none)

    FailLogIn message ->
      ({model | logInFail = message }, Cmd.none)

    NoOp ->
      ( model, Cmd.none )



-- Update functions helpers
-- wut is this anotactions
setTabSaved: { b | index : a } -> { c | index : a, saved : Bool } -> { c | index : a, saved : Bool }
setTabSaved tab tabs =
  if tab.index == tabs.index then
    { tabs | saved = True }
  else
    tabs
