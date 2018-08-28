module Api exposing (apiTimeout, floatAsStringDecoder, getHeaders, getUrl, loadSensorMeasurements, loadSensors, loadSponsor, measurementDecoder, sensorDecoder, sponsorDecoder, toJsMeasurement, toJsSensor)

import Date
import Date.Format
import Http
import Json.Decode as Decode
import Json.Decode.Extra as DecodeExtra
import Json.Decode.Pipeline as Pipeline
import Map
import Messages exposing (..)
import Models exposing (JsMeasurement, JsSensor, Measurement, Sensor, Sponsor)
import Time



-- AUTHENTICATION


getHeaders : String -> List Http.Header
getHeaders apiToken =
    [ Http.header "Authorization" ("Bearer " ++ apiToken) ]



-- DECODERS


sensorDecoder : Decode.Decoder Sensor
sensorDecoder =
    Pipeline.decode Sensor
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "device_name" Decode.string
        |> Pipeline.required "caption" (Decode.nullable Decode.string)
        |> Pipeline.required "latitude" Decode.float
        |> Pipeline.required "longitude" Decode.float
        |> Pipeline.required "sponsor_id" (Decode.nullable Decode.int)
        |> Pipeline.required "created_at" DecodeExtra.date
        |> Pipeline.required "updated_at" DecodeExtra.date
        |> Pipeline.optional "last_measurement" (Decode.nullable measurementDecoder) Nothing
        |> Pipeline.hardcoded Nothing


sponsorDecoder : Decode.Decoder Sponsor
sponsorDecoder =
    Pipeline.decode Sponsor
        |> Pipeline.required "name" Decode.string
        |> Pipeline.optional "description" Decode.string ""
        |> Pipeline.optional "active" Decode.bool False


{-| Parse a string as float. Fail if parsing does not succeed.
-}
floatAsStringDecoder : Decode.Decoder Float
floatAsStringDecoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case String.toFloat str of
                    Ok parsed ->
                        Decode.succeed parsed

                    Err e ->
                        Decode.fail "Could not parse string value as float"
            )


measurementDecoder : Decode.Decoder Measurement
measurementDecoder =
    Pipeline.decode Measurement
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "sensor_id" (Decode.nullable Decode.int)
        |> Pipeline.required "temperature" floatAsStringDecoder
        |> Pipeline.required "created_at" DecodeExtra.date



-- HELPERS


toJsSensor : Sensor -> JsSensor
toJsSensor sensor =
    JsSensor
        sensor.id
        sensor.deviceName
        sensor.caption
        (Map.Pos
            sensor.latitude
            sensor.longitude
        )
        (Maybe.map toJsMeasurement sensor.lastMeasurement)


toJsMeasurement : Measurement -> JsMeasurement
toJsMeasurement measurement =
    JsMeasurement
        measurement.temperature



-- API REQUESTS


apiTimeout : Time.Time
apiTimeout =
    30 * Time.second


getUrl : String -> String
getUrl path =
    "https://watertemp-api.coredump.ch/api/" ++ path


loadSensors : String -> Cmd Msg
loadSensors apiToken =
    let
        url =
            getUrl "sensors"

        request =
            Http.request
                { method = "GET"
                , headers = getHeaders apiToken
                , url = url
                , body = Http.emptyBody
                , expect = Http.expectJson (Decode.list sensorDecoder)
                , timeout = Just apiTimeout
                , withCredentials = False
                }
    in
    Http.send SensorsLoaded request


loadSensorMeasurements : String -> Time.Time -> Int -> Int -> Cmd Msg
loadSensorMeasurements apiToken now sensorId secondsAgo =
    let
        createdAfter =
            Date.fromTime <| now - (toFloat secondsAgo * Time.second)

        url =
            getUrl "measurements?sensor_id="
                ++ toString sensorId
                ++ "&created_after="
                ++ Date.Format.formatISO8601 createdAfter

        request =
            Http.request
                { method = "GET"
                , headers = getHeaders apiToken
                , url = url
                , body = Http.emptyBody
                , expect = Http.expectJson (Decode.list measurementDecoder)
                , timeout = Just apiTimeout
                , withCredentials = False
                }
    in
    Http.send (\res -> MeasurementsLoaded ( sensorId, res )) request


loadSponsor : String -> Int -> Cmd Msg
loadSponsor apiToken sponsorId =
    let
        url =
            getUrl "sponsors/" ++ toString sponsorId

        request =
            Http.request
                { method = "GET"
                , headers = getHeaders apiToken
                , url = url
                , body = Http.emptyBody
                , expect = Http.expectJson sponsorDecoder
                , timeout = Just apiTimeout
                , withCredentials = False
                }
    in
    Http.send (\res -> SponsorLoaded ( sponsorId, res )) request
