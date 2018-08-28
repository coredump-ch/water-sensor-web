module Charts exposing (temperatureChart)

import Date exposing (toTime)
import Html exposing (Html)
import LineChart
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Axis.Intersection as Intersection
import LineChart.Axis.Line as AxisLine
import LineChart.Axis.Range as Range
import LineChart.Axis.Ticks as Ticks
import LineChart.Axis.Title as Title
import LineChart.Colors as Colors
import LineChart.Container as Container
import LineChart.Dots as Dots
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Interpolation as Interpolation
import LineChart.Junk as Junk
import LineChart.Legends as Legends
import LineChart.Line as Line
import Models exposing (Measurement)
import Time exposing (Time)


type alias Point =
    { x : Float, y : Float }


temperatureChart : Maybe Time -> List Measurement -> Html msg
temperatureChart now measurements =
    let
        -- 1h offset / padding
        paddingMs =
            1 * 1000 * 3600

        range =
            case now of
                Just timestamp ->
                    Range.window
                        (timestamp - (1000 * 3600 * 24 * 3) - paddingMs)
                        (timestamp + paddingMs)

                Nothing ->
                    Range.padded 20 20

        -- We want to determine the number of ticks to show on the x axis
        -- depending on the amount of available data.
        -- Scale the number of ticks to ensure that the values are still readable.
        tickCount =
            case ( now, List.head measurements ) of
                ( Just timestamp, Just measurement ) ->
                    let
                        hoursOfData =
                            (timestamp - toTime measurement.createdAt)
                                |> Time.inHours
                    in
                    if hoursOfData > 60 then
                        5

                    else if hoursOfData > 48 then
                        4

                    else if hoursOfData > 36 then
                        3

                    else if hoursOfData > 24 then
                        2

                    else
                        1

                _ ->
                    0
    in
    LineChart.viewCustom
        { y =
            Axis.custom
                { title = Title.default ""
                , variable = Just << .temperature
                , pixels = 300
                , range = Range.padded 20 20
                , axisLine =
                    AxisLine.custom <|
                        \dataRange axisRange ->
                            { color = Colors.grayLight
                            , width = 3
                            , events = []
                            , start = dataRange.min
                            , end = dataRange.max
                            }
                , ticks = Ticks.default
                }
        , x =
            Axis.custom
                { title = Title.default ""
                , variable = Just << toTime << .createdAt
                , pixels = 500
                , range = range
                , axisLine = AxisLine.none
                , ticks = Ticks.time tickCount
                }
        , container =
            Container.custom
                { attributesHtml = []
                , attributesSvg = []
                , size = Container.relative
                , margin = Container.Margin 10 10 60 50
                , id = "line-chart-30d"
                }
        , interpolation = Interpolation.default
        , intersection = Intersection.default
        , legends = Legends.none
        , events = Events.default
        , junk = Junk.default
        , grid = Grid.lines 0.75 Colors.grayLight
        , area = Area.default
        , line = Line.wider 2
        , dots = Dots.custom (Dots.full 0)
        }
        [ LineChart.line Colors.blue Dots.circle "Temperature" measurements ]
