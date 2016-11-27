module LensSpec exposing (all)

import ElmTest exposing (suite, equals, Test)
import Check exposing (that, is, for, claim, check)
import Check.Test exposing (test, assert)
import Check.Producer exposing (Producer, tuple, string, list, char, int)
import Random exposing (initialSeed)
import Random.Int
import Random.Char
import Random.String
import Random.Extra exposing (constant, merge)
import Shrink
import String
import Char
import Result
import Monocle.Iso exposing (Iso)
import Monocle.Prism exposing (Prism)
import Monocle.Lens exposing (Lens, compose, modify, zip, modifyAndMerge)
import Maybe exposing (Maybe)


all : Test
all =
    suite
        "A Lens specification"
        [ test_lens_property_identity
        , test_lens_property_identity_reverse
        , test_lens_method_compose
        , test_lens_method_modify
        , test_lens_method_zip
        , test_lens_method_modifyAndMerge
        ]


count : Int
count =
    100


seed : Random.Seed
seed =
    initialSeed 21882980


type StreetType
    = Street
    | Avenue


type Country
    = US
    | UK
    | FI
    | PL
    | DE


type alias Address =
    { streetName : String
    , streetType : StreetType
    , floor : Maybe Int
    , town : String
    , region : Maybe String
    , postcode : String
    , country : Country
    }


type alias Place =
    { name : String
    , description : String
    , address : Address
    }


addressShrinker : Shrink.Shrinker Address
addressShrinker { streetName, streetType, floor, town, region, postcode, country } =
    Address
        `Shrink.map` Shrink.string streetName
        `Shrink.andMap` Shrink.noShrink streetType
        `Shrink.andMap` Shrink.noShrink floor
        `Shrink.andMap` Shrink.string town
        `Shrink.andMap` Shrink.noShrink region
        `Shrink.andMap` Shrink.noShrink postcode
        `Shrink.andMap` Shrink.noShrink country


placeShrinker : Shrink.Shrinker Place
placeShrinker { name, description, address } =
    Place
        `Shrink.map` Shrink.string name
        `Shrink.andMap` Shrink.string description
        `Shrink.andMap` addressShrinker address


addresses : Producer Address
addresses =
    let
        address name town postcode = { streetName = name, streetType = Street, floor = Nothing, town = town, region = Nothing, postcode = postcode, country = US }

        generator = Random.map3 address Random.String.anyEnglishWord Random.String.anyEnglishWord (Random.String.word 5 Random.Char.numberForm)
    in
        Check.Producer generator addressShrinker


places : Producer Place
places =
    let
        generator = Random.map3 Place Random.String.anyEnglishWord Random.String.anyEnglishWord addresses.generator
    in
        Check.Producer generator placeShrinker


addressStreetNameLens : Lens Address String
addressStreetNameLens =
    let
        get a = a.streetName

        set sn a = { a | streetName = sn }
    in
        Lens get set


placeAddressLens : Lens Place Address
placeAddressLens =
    let
        get p = p.address

        set a p = { p | address = a }
    in
        Lens get set


test_lens_property_identity =
    let
        lens = addressStreetNameLens

        actual x = lens.set (lens.get x) x

        expected x = x

        investigator = addresses
    in
        test "For all a: A, (set (get a) a) == a" actual expected investigator count seed


test_lens_property_identity_reverse =
    let
        lens = addressStreetNameLens

        actual ( x, a ) = lens.get (lens.set x a)

        expected ( x, _ ) = x

        investigator = Check.Producer.tuple ( string, addresses )
    in
        test "For all a: A, get (set a a) == a" actual expected investigator count seed


test_lens_method_compose =
    let
        lens = placeAddressLens `compose` addressStreetNameLens

        actual ( sn, p ) = lens.get (lens.set sn p)

        expected ( sn, _ ) = sn

        investigator = Check.Producer.tuple ( string, places )
    in
        test "Lens.compose" actual expected investigator count seed


test_lens_method_modify =
    let
        f sn = String.reverse sn

        lens = placeAddressLens `compose` addressStreetNameLens

        actual p = p |> (modify lens f)

        expected p = lens.set (String.reverse (lens.get p)) p

        investigator = places
    in
        test "Lens.modify" actual expected investigator count seed


test_lens_method_zip =
    let
        address = Address "test" Street Nothing "test" Nothing "test" US

        place = Place "test" "test" address

        lens = placeAddressLens `zip` addressStreetNameLens

        actual x = lens.get (lens.set x ( place, address ))

        expected x = x

        investigator = Check.Producer.tuple ( addresses, string )
    in
        test "Lens.zip" actual expected investigator count seed


test_lens_method_modifyAndMerge =
    let
        lens = placeAddressLens `compose` addressStreetNameLens

        fx a = ( String.reverse a, String.length a )

        merge a b = a + b

        modifiedFx = modifyAndMerge lens fx merge

        actual p = modifiedFx p

        expected ( place, n ) = ( (lens.set (String.reverse (lens.get place)) place), n + (String.length (lens.get place)) )

        investigator = Check.Producer.tuple ( places, int )
    in
        test "Lens.modifyAndMerge" actual expected investigator count seed
