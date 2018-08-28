module Messages exposing (Msg(..))

import Http
import Map
import Models
import Navigation exposing (Location)
import Time


type Msg
    = LocationChange Location
    | MapInitialized ()
    | MapDragged Map.Model
    | SensorsLoaded (Result Http.Error (List Models.Sensor))
    | SensorClicked (Maybe Models.JsSensor)
    | MeasurementsLoaded ( Int, Result Http.Error (List Models.Measurement) )
    | SponsorLoaded ( Int, Result Http.Error Models.Sponsor )
    | TimeUpdate Time.Time
