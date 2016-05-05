import TodoManager
import StartApp
import Signal
import Html
import Task
import Effects exposing (Never)

app : StartApp.App TodoManager.Model
app =
  StartApp.start
    { init = TodoManager.init
    , inputs = []
    , update = TodoManager.update
    , view = TodoManager.view
    } 

main : Signal.Signal Html.Html
main =
    app.html
    
port runner : Signal (Task.Task Never ())
port runner =
  app.tasks