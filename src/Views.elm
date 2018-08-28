module Views exposing (view)

import Css exposing (..)
import Css.Foreign as Foreign
import Css.Reset
import Dict
import Helpers exposing (formatTemperature)
import Html.Styled exposing (Html, a, div, footer, fromUnstyled, h1, h2, h3, h4, h5, h6, img, p, strong, text)
import Html.Styled.Attributes as Attr exposing (class, css, href, id, src)
import Messages exposing (..)
import Models exposing (Model, Route(..), Sensor, Sponsor)
import Routing
import Time exposing (Time)


{-| Root view.

Decide which view to render based on the current route.

-}
view : Model -> Html Msg
view model =
    case model.route of
        MapRoute ->
            mapView model

        AboutRoute ->
            aboutView

        NotFoundRoute ->
            notFoundView


{-| Wrap a list of HTML elements in a wrapper div with full height.
-}
page : String -> List (Html Msg) -> Html Msg
page subtitle elements =
    div
        [ css
            [ minHeight (vh 100)
            , displayFlex
            , flexDirection column
            ]
        ]
        (List.append
            [ Css.Reset.css
            , Foreign.global
                [ Foreign.body <| fontBody ++ [ fontSize (px 16) ]
                , Foreign.id "main" [ minHeight (vh 100) ]
                , Foreign.h1 <| fontHeading ++ [ fontSize (em 3.4), marginBottom (px 16) ]
                , Foreign.h2 <| fontHeading ++ [ fontSize (em 2.2), marginBottom (px 8) ]
                , Foreign.h3 <| fontHeading ++ [ fontSize (em 1.6), marginBottom (px 8) ]
                , Foreign.h4 <| fontHeading ++ [ fontSize (em 1.3) ]
                , Foreign.p [ lineHeight (em 1.5), marginBottom (px 8) ]
                , Foreign.strong [ fontWeight bold ]
                , Foreign.class "marker"
                    [ backgroundImage (url "/static/marker.svg")
                    , backgroundSize cover
                    , width (px 32)
                    , height (px 32)
                    , lineHeight (px 32)
                    , cursor pointer
                    , textAlign center
                    , verticalAlign middle
                    , fontWeight bold
                    , fontSize (px 16)
                    , Foreign.withClass "selected"
                        [ backgroundImage (url "/static/marker-selected.svg") ]
                    ]
                ]
            , div [ css [ width (pct 100), marginTop (px 16) ] ]
                [ h1 [ css [ textAlign center, marginBottom (px 4) ] ] [ text "Gfrör.li" ]
                , h2 [ css [ textAlign center ] ] [ text "Wassertemperaturen Schweiz" ]
                ]
            , p [ css [ textAlign center, margin2 (px 16) zero ] ]
                [ text subtitle ]
            ]
            elements
        )


{-| View: Not found
-}
notFoundView : Html Msg
notFoundView =
    page
        ""
        [ div [ css [ width (pct 100), textAlign center ] ]
            [ p
                [ css [ fontSize (em 12) ] ]
                [ text "404" ]
            , p
                [ css [ fontSize (em 1.2) ] ]
                [ text "Es tut uns leid, aber die gewünschte Seite wurde nicht gefunden." ]
            ]
        ]


{-| View: About
-}
aboutView : Html Msg
aboutView =
    page
        ""
        [ div
            [ css [ width (px 800), margin2 zero auto, textAlign center ] ]
            [ h2 [] [ text "About" ]
            , h3 [ css [ marginTop (px 16) ] ] [ text "Warum dieses Projekt?" ]
            , p [] [ text "Die Wassertemperatur ist für viele Menschen ein wichtiger Wert, zum Beispiel für Schwimmer, Taucher, Fischer und viele mehr. Aber bisher gab es keine verlässliche Methode, um Echtzeit-Temperaturinformationen in deiner Gegend zu erhalten." ]
            , p [] [ text "Es gibt heute bereits ein paar Wassertemperatur-Sensor-Netzwerke, aber meistens gibt es nur einen Sensor pro See, wodurch lokale Temperaturunterschiede (z.B. an einer Flussmündung) ignoriert werden. Viele Sensoren werden zudem nur ein mal pro Tag publiziert." ]
            , p [] [ text "Wir bauen ein Netzwerk von kostengünstigen Wassertemperatur-Sensoren mit sehr geringem Energieverbrauch auf.  Dies ermöglicht uns, die Wassertemperatur lokal zu messen und sie dir kostenlos in Quasi-Echtzeit anzuzeigen." ]
            , p []
                [ text "Der Quellcode dieser Webapp steht unter einer freien Lizenz und kann "
                , a [ href Routing.githubPath ] [ text "auf Github" ]
                , text " eingesehen und verbessert werden!"
                ]
            , h3 [ css [ marginTop (px 16) ] ] [ text "Wer hat diese Website entwickelt?" ]
            , p [] [ text "Diese Website, die Server-Infrastruktur wie auch die Sensor-Hardware werden vom Coredump Hackerspace in Rapperswil-Jona entwickelt." ]
            , p []
                [ text "Mehr Informationen über uns findest du auf unserer Website: "
                , a [ href Routing.coredumpPath ] [ text "www.coredump.ch" ]
                ]
            , h3 [ css [ marginTop (px 16) ] ] [ text "Wie kann ich selber so einen Sensor platzieren?" ]
            , p []
                [ text "Kontaktiere uns doch unter "
                , a [ href "mailto:gfroerli@coredump.ch" ] [ text "gfroerli@coredump.ch" ]
                , text "!"
                ]
            , a [ href Routing.mapPath, css [ display inlineBlock, marginTop (px 32) ] ] [ text "Zurück zur Karte" ]
            ]
        ]


pluralize : String -> String -> Int -> String
pluralize singular plural quantity =
    if quantity == 1 then
        singular

    else
        plural


{-| View: Map
-}
mapView : Model -> Html Msg
mapView model =
    page
        ("Finde die aktuelle und historische Wassertemperatur an "
            ++ (model.sensors |> List.length |> toString)
            ++ pluralize " Standort" " Standorten" (model.sensors |> List.length)
            ++ " rund um den Zürichsee!"
        )
        [ div [ css [ position absolute, top (px 8), right (px 8) ] ]
            [ a
                [ href "https://play.google.com/apps/testing/ch.coredump.watertemp.zh" ]
                [ img [ src "/static/google-play-badge.png" ] [] ]
            ]
        , div
            [ id "wrapper"
            , css
                [ position relative
                , width (pct 100)
                , flexGrow (num 1)
                , displayFlex
                , flexDirection row
                , alignItems stretch
                ]
            ]
            [ div
                [ id "mapContainer"
                , css
                    [ position relative
                    , flexGrow (num 1)
                    ]
                ]
                [ div
                    [ id "map"
                    , css
                        [ position absolute
                        , top zero
                        , bottom zero
                        , left zero
                        , right zero
                        ]
                    ]
                    []
                ]
            , div
                [ id "sidebar"
                , css
                    [ flexBasis (pct 20)
                    , padding (px 16)
                    , backgroundColor (hex "#F7F7F7")
                    ]
                ]
                (sidebarContents model)
            ]
        , footer
            [ css
                [ fontSize (em 0.8)
                , textAlign center
                , padding2 (px 8) zero
                ]
            ]
            [ text "© 2017–2018 Coredump Rapperswil-Jona"
            , text " | "
            , a [ href Routing.aboutPath ] [ text "About" ]
            , text " | "
            , a [ href Routing.githubPath ] [ text "Code on Github" ]
            ]
        ]


sidebarContents : Model -> List (Html Msg)
sidebarContents model =
    [ h2
        [ css [ marginBottom (em 0.5) ] ]
        [ text <| Maybe.withDefault "Details" (Maybe.map .deviceName model.selectedSensor) ]
    , Maybe.withDefault
        (p [] [ text "Klicke auf einen Sensor, um mehr über ihn zu erfahren." ])
        (Maybe.map
            (\sensor ->
                sensorDescription model.now
                    sensor
                    (Maybe.andThen
                        (\sponsorId -> Dict.get sponsorId model.sponsors)
                        sensor.sponsorId
                    )
            )
            model.selectedSensor
        )

    --(Maybe.map (\s -> sensorDescription model.now s) model.selectedSensor)
    ]


sensorDescription : Maybe Time -> Sensor -> Maybe Sponsor -> Html Msg
sensorDescription now sensor sponsor =
    div []
        [ Maybe.withDefault
            -- Fallback if there is no caption
            (p
                [ css [ fontStyle italic ] ]
                [ text "Keine Beschreibung" ]
            )
            -- Extract and show caption
            (Maybe.map
                (\s ->
                    p
                        [ css [ fontStyle normal ] ]
                        [ text s ]
                )
                sensor.caption
            )
        , h3 [] [ text "Letzte Messung" ]
        , Maybe.withDefault
            -- Fallback if there is no measurement
            (p
                [ css [ fontStyle italic ] ]
                [ text "Keine Messung" ]
            )
            -- Extract and show last measurement
            (Maybe.map
                (\measurement ->
                    p
                        [ css [ fontStyle normal ] ]
                        [ text (measurement.temperature |> toString |> formatTemperature) ]
                )
                sensor.lastMeasurement
            )
        , h3 [] [ text "Temperaturverlauf (3 Tage)" ]
        , Maybe.withDefault
            -- Fallback if there are no historic measurements
            (p
                [ css [ fontStyle italic ] ]
                [ text "Temperaturverlauf wird geladen..." ]
            )
            -- Extract and show historic measurements
            (Maybe.map
                (\measurements ->
                    case measurements of
                        [] ->
                            p
                                [ css [ fontStyle italic ] ]
                                [ text "No recent measurements" ]

                )
                sensor.historicMeasurements
            )
        , h3 [] [ text "Sponsor" ]
        , Maybe.withDefault
            (p
                [ css [ fontStyle italic ] ]
                [ text "Sponsor wird geladen..." ]
            )
            (Maybe.map
                (\sponsor ->
                    div []
                        [ p
                            [ css [ fontStyle italic ] ]
                            [ text sponsor.name ]
                        , p
                            []
                            [ text sponsor.description ]
                        ]
                )
                sponsor
            )
        ]


{-| Font related styling rules for the entire body
-}
fontBody : List Style
fontBody =
    [ fontFamilies [ "Montserrat", .value sansSerif ]
    , color (rgb 50 50 50)
    ]


{-| Font related styling rules for all headings
-}
fontHeading : List Style
fontHeading =
    [ fontFamilies [ "Barlow Semi Condensed", .value sansSerif ]
    , color (rgb 50 50 50)
    ]
