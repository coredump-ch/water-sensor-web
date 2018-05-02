module Charts exposing (temperatureChart)

import Color
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
    in
        LineChart.viewCustom
            { y = Axis.default 300 "°C" .temperature
            , x =
                Axis.custom
                    { title = Title.default ""
                    , variable = Just << toTime << .createdAt
                    , pixels = 450
                    , range = range
                    , axisLine = AxisLine.full Colors.black
                    , ticks = Ticks.time 5
                    }
            , container = Container.responsive "line-chart-1"
            , interpolation = Interpolation.default
            , intersection = Intersection.default
            , legends = Legends.none
            , events = Events.default
            , junk = Junk.default
            , grid = Grid.default
            , area = Area.default
            , line = Line.wider 3
            , dots = Dots.custom (Dots.full 0)
            }
            [ LineChart.line Color.red Dots.circle "Foo" measurements ]