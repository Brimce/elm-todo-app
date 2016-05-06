import TodoManager.Main
import StartApp
import Signal
import Html exposing (Html, div, text)
import Task
import Effects exposing (Never)


app : StartApp.App TodoManager.Main.Model
app =
  StartApp.start
    { init = TodoManager.Main.init
    , inputs = []
    , update = TodoManager.Main.update
    , view = TodoManager.Main.view
    } 

main : Signal.Signal Html.Html
main =
    app.html
    
port runner : Signal (Task.Task Never ())
port runner =
  app.tasks