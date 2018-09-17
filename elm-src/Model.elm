module Model exposing (Model, TabsList)

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
    , render : Bool
    , username : String
    , password : String
    , loggedIn : String
    , logInFail : String
    , logInSuccess : String
    }
