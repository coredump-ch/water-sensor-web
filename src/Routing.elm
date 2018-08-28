module Routing exposing
    ( aboutPath
    , coredumpPath
    , githubPath
    , mapPath
    , parseLocation
    )

import Models exposing (Route(..))
import Navigation exposing (Location)
import UrlParser exposing (Parser, map, oneOf, parseHash, s, top)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map MapRoute top
        , map AboutRoute (s "about")
        ]


parseLocation : Location -> Route
parseLocation location =
    case parseHash matchers location of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


mapPath : String
mapPath =
    "#/"


aboutPath : String
aboutPath =
    "#/about"


githubPath : String
githubPath =
    "https://github.com/coredump-ch/water-sensor-web"


coredumpPath : String
coredumpPath =
    "https://coredump.ch/"
