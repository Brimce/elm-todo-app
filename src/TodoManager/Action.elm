module TodoManager.Action where

import TodoManager.Ressources exposing (..)
import Http

type Action 
    = UpdateInputText String
    | AddTodo
    | ChangeFilter Filter
    | ClearCompleted
    | StartEditingTodo Todo
    | EndEditingTodo Todo
    | ClearTodo Todo
    | LoadTodos
    | OnTodosLoaded (Result Http.Error (List Todo))
    | SaveTodos
    | UpdateIsTodoCompleted Todo Bool