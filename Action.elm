module Action where

type Action 
    = UpdateInputText String
    | AddTodo
    | ChangeFilter Filter
    | ClearCompleted
    | StartEditingTodo Todo
    | EndEditingTodo Todo
    | ClearTodo Todo
    | LoadTodos
    | OnTodosLoaded (Result Http.Error String)
    | SaveTodos
    | UpdateIsTodoCompleted Todo Bool