module Models exposing (JsMeasurement, JsSensor, Measurement, Model, Route(..), Sensor, Sponsor)

import Date exposing (Date)
import Dict exposing (Dict)
import Map
import Time


type alias Model =
    { route : Route
    , map : Map.Model
    , sensors : List Sensor
    , selectedSensor : Maybe Sensor
    , sponsors : Dict Int Sponsor
    , apiToken : String
    , now : Maybe Time.Time
    }


type Route
    = MapRoute
    | AboutRoute
    | NotFoundRoute


type alias Sensor =
    { id : Int
    , deviceName : String
    , caption : Maybe String
    , latitude : Float
    , longitude : Float
    , sponsorId : Maybe Int
    , createdAt : Date
    , updatedAt : Date
    , lastMeasurement : Maybe Measurement
    , historicMeasurements : Maybe (List Measurement)
    }


type alias Sponsor =
    { name : String
    , description : String
    , active : Bool
    }


type alias JsSensor =
    { id : Int
    , deviceName : String
    , caption : Maybe String
    , pos : Map.Pos
    , lastMeasurement : Maybe JsMeasurement
    }


type alias Measurement =
    { id : Int
    , sensorId : Maybe Int
    , temperature : Float
    , createdAt : Date
    }


type alias JsMeasurement =
    { temperature : Float
    }
