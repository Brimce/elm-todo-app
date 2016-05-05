import TodoManager exposing (update, view, initModel)
import StartApp.Simple exposing (start)


main =
  start
    { model = initModel
    , update = update
    , view = view
    }