module TodoManager.Api where

import Http
import Effects
import Task
import Json.Decode as JsonD exposing ((:=))
import Json.Encode as JsonE

import TodoManager.Ressources exposing (..)
import TodoManager.Action exposing (..)

    
-- API
httpTask : Task.Task Http.Error (List Todo)
httpTask =
    Http.get todosDecoder "http://localhost:4000/todos"
 
loadTodosFx : Effects.Effects Action
loadTodosFx =
    httpTask 
        |> Task.toResult
        |> Task.map OnTodosLoaded
        |> Effects.task
  
todosDecoder : JsonD.Decoder (List Todo)
todosDecoder =
    let todoDecoder = JsonD.object3 Todo
                                ("text" := JsonD.string)
                                ("id" := JsonD.int)
                                ("isCompleted" := JsonD.bool)
    in JsonD.list todoDecoder