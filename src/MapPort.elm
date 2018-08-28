port module MapPort exposing (initializeMap, mapInitialized, mapMoved, moveMap, sensorClicked, sensorsLoaded)

import Map
import Models



-- Outgoing Port


port initializeMap : Map.Model -> Cmd msg


port moveMap : Map.Model -> Cmd msg


port sensorsLoaded : List Models.JsSensor -> Cmd msg



-- Incoming Port


port mapInitialized : (() -> msg) -> Sub msg


port mapMoved : (Map.Model -> msg) -> Sub msg


port sensorClicked : (Maybe Models.JsSensor -> msg) -> Sub msg
