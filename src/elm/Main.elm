module Main exposing (Flags, init, main, subscriptions, update)

import Api
import Browser
import Browser.Navigation as Nav
import Dict
import List.Extra exposing (find)
import Map
import MapPort
import Maybe.Extra
import Messages exposing (..)
import Models exposing (Model)
import Routing exposing (toRoute)
import Task
import Time exposing (posixToMillis)
import Url
import Views exposing (view)


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }


type alias Flags =
    { apiToken : String
    }



-- MODEL


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        map =
            Map.init

        currentRoute =
            toRoute url
    in
    ( { key = key
      , route = currentRoute
      , map = map
      , sensors = []
      , selectedSensor = Nothing
      , sponsors = Dict.empty
      , apiToken = flags.apiToken
      , now = Nothing
      }
    , Cmd.batch
        [ MapPort.initializeMap map
        , Task.perform TimeUpdate Time.now
        ]
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TimeUpdate newTime ->
            ( { model | now = Just newTime }, Cmd.none )

        LinkClicked urlRequest ->
            ( model, Cmd.none )

        UrlChanged url ->
            ( model, Cmd.none )

        --        UrlChanged url ->
        --            let
        --                -- Determine the new route by parsing the location
        --                newRoute =
        --                    parseLocation location
        --
        --                -- Determine any side effects (e.g. map init) caused by the location change
        --                cmd =
        --                    case newRoute of
        --                        MapRoute ->
        --                            -- Re-initialize map
        --                            MapPort.initializeMap model.map
        --
        --                        AboutRoute ->
        --                            Cmd.none
        --
        --                        NotFoundRoute ->
        --                            Cmd.none
        --            in
        --            ( { model | route = newRoute }, cmd )
        MapInitialized _ ->
            ( model, Api.loadSensors model.apiToken )

        SensorsLoaded (Ok sensors) ->
            ( { model | selectedSensor = Nothing, sensors = sensors }
            , List.map Api.toJsSensor sensors
                |> MapPort.sensorsLoaded
            )

        SensorsLoaded (Err error) ->
            --let
            --    _ =
            --        -- TODO
            --        Debug.log "Error while fetching data" error
            --in
            ( model, Cmd.none )

        SponsorLoaded ( sponsorId, Ok sponsor ) ->
            let
                updatedSponsors =
                    Dict.insert sponsorId sponsor model.sponsors
            in
            ( { model | sponsors = updatedSponsors }, Cmd.none )

        SponsorLoaded ( sponsorId, Err error ) ->
            --let
            --    _ =
            --        -- TODO
            --        Debug.log "Error while fetching sponsor" error
            --in
            ( model, Cmd.none )

        MeasurementsLoaded ( sensorId, Ok measurements ) ->
            let
                -- Get selected sensor if the sensor id in the received
                -- measurements matches its id.
                sensor =
                    Maybe.Extra.filter (\s -> s.id == sensorId) model.selectedSensor

                updatedModel =
                    case sensor of
                        Just s ->
                            let
                                sortedMeasurements =
                                    List.sortBy (.createdAt >> posixToMillis) measurements

                                updatedSensor =
                                    { s | historicMeasurements = Just sortedMeasurements }
                            in
                            { model | selectedSensor = Just updatedSensor }

                        Nothing ->
                            model
            in
            ( updatedModel, Cmd.none )

        MeasurementsLoaded ( sensorId, Err error ) ->
            --let
            --    _ =
            --        -- TODO
            --        Debug.log ("Error while fetching measurements for sensor " ++ String.fromInt sensorId) error
            --in
            ( model, Cmd.none )

        MapDragged pos ->
            let
                oldMap =
                    model.map

                newMap =
                    { oldMap
                        | lat = pos.lat
                        , lng = pos.lng
                        , zoom = pos.zoom
                    }
            in
            ( { model | map = newMap }, Cmd.none )

        SensorClicked (Just jsSensor) ->
            let
                selectedSensor =
                    find (\sensor -> sensor.id == jsSensor.id)
                        model.sensors

                cmdMeasurements =
                    case ( model.now, selectedSensor ) of
                        ( Just now, Just sensor ) ->
                            Api.loadSensorMeasurements
                                model.apiToken
                                now
                                sensor.id
                                (3600 * 24 * 3)

                        _ ->
                            Cmd.none

                cmdSponsor =
                    case Maybe.map .sponsorId selectedSensor of
                        Just (Just sponsorId) ->
                            Api.loadSponsor model.apiToken sponsorId

                        _ ->
                            Cmd.none

                cmd =
                    Cmd.batch [ cmdMeasurements, cmdSponsor ]
            in
            ( { model | selectedSensor = selectedSensor }, cmd )

        SensorClicked Nothing ->
            ( { model | selectedSensor = Nothing }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ MapPort.mapInitialized MapInitialized
        , MapPort.mapMoved MapDragged
        , MapPort.sensorClicked SensorClicked
        , Time.every (10 * 1000) TimeUpdate
        ]