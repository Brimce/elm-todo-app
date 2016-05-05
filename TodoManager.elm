module TodoManager where

import Html exposing (..)
import Html.Attributes exposing (style, id, value, hidden, disabled)
import Html.Events exposing (onClick, on, targetValue, keyCode)
import Html.Lazy exposing (lazy, lazy2, lazy3)
import Signal exposing (Address)
import Json.Decode as Json
import String
import Effects exposing (Effects, Never)
import Http
import Task
import Json.Decode as JsonD exposing ((:=))
import Json.Encode as JsonE

--model
type alias Model =
    { todos : List Todo
    , currentTodo : Maybe Todo
    , currentFilter : Filter
    , textInput : String    
    }
    
type alias Todo =
    { text : String
    , id : Int
    , isCompleted : Bool
    }
    
type Filter = All | Completed | Active

initModel : Model
initModel = 
    { todos = []--sampleTodos
    , currentTodo = Nothing
    , currentFilter = All
    , textInput = ""    
    }
  
init : (Model, Effects Action)
init =
    (initModel, loadTodosFx)
      
--sampleTodos =
--    [(Todo "Regarder un film" 0 False),(Todo "Regarder un autre film" 1 True)]
 

isTodoTextValid : String -> Bool
isTodoTextValid s =
      String.length s |> (<) 3
    
addTodo : String -> List Todo -> List Todo
addTodo textTodo todos =
    let 
        maxId = List.maximum <| List.map (\todo -> todo.id) todos
        newId = 
            case maxId of
                Maybe.Nothing -> 0
                Just i -> i + 1      
    in 
    --todos ++ [(Todo textTodo newId False)]
    --todos ++ [(Todo ( (++) (textTodo ++ " ")  <| toString <| isTodoTextValid textTodo) newId False)]
    if isTodoTextValid textTodo then
        todos ++ [(Todo textTodo newId False)]
    else
        todos
        
addTodo2 : Model -> Model
addTodo2 model =
    let 
        maxId = List.maximum <| List.map (\todo -> todo.id) model.todos
        newId = 
            case maxId of
                Maybe.Nothing -> 0
                Just i -> i + 1      
    in 
    --todos ++ [(Todo textTodo newId False)]
    --todos ++ [(Todo ( (++) (textTodo ++ " ")  <| toString <| isTodoTextValid textTodo) newId False)]
    if isTodoTextValid model.textInput then
        {model 
            | todos = model.todos ++ [(Todo model.textInput newId False)]
            , textInput = ""}
        
    else
        model
        
updateTodo : Todo -> Model -> Model
updateTodo todo model =
    let 
        updateTodo = \t -> if(t.id == todo.id) then {t | text = todo.text, isCompleted = todo.isCompleted} else t     
    in 
        {model | todos = List.map updateTodo model.todos}
  
filtreTodo : Filter -> Todo -> Bool
filtreTodo f todo =
    case f of
        All
            -> True
        Completed
            -> todo.isCompleted
        Active
            -> not todo.isCompleted
--update
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

update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
 case action of
    LoadTodos 
        -> (model ,loadTodosFx)
    
    OnTodosLoaded result 
        -> case result of
            Result.Ok todos
                -> ({model 
                        | todos = todos} 
                   , Effects.none)
            Result.Err err
                ->  ({model 
                        | todos = [], textInput = toString err} 
                   , Effects.none)
                   
    ChangeFilter f
        -> ({model 
              | currentFilter = f},Effects.none)
   
    UpdateInputText text
        -> ({model 
              | textInput = text },Effects.none)
    
    AddTodo
        -> (addTodo2 model,Effects.none)
   
    UpdateIsTodoCompleted todo newValue
        -> (updateTodo (Todo todo.text todo.id newValue) model ,Effects.none)
    _ 
        -> (model,Effects.none)
    
--view

view : Address Action -> Model -> Html
view address model =
    div 
        [ id "briceTodoApp"]
        [ (lazy2 headerTodoList address model.textInput)
        , ul 
           [id "todoList"]
           (List.filter (filtreTodo model.currentFilter) model.todos |> List.map (\todo -> li [id <| toString todo.id][createTodoItem address todo]))
        , (lazy2 footer address model)
        ]

headerTodoList : Address Action -> String -> Html
headerTodoList address textNewTodo =
   div
        [id "addTodoForm"]
        [
            input 
                [ value textNewTodo
                , on "input" targetValue (Signal.message address << UpdateInputText)
                , onEnter address (AddTodo)
                ]
                []
            , button
                [onClick address AddTodo
                , disabled(not <| isTodoTextValid textNewTodo)
                ]
                [text "Ajouter"]
            , Html.label
                []
                [text textNewTodo]
        ]

createTodoItem : Address Action -> Todo -> Html
createTodoItem address todo =
    div
        []
        [text (todo.text ++ " " ++ toString todo.id)
        , text (", a faire ? " ++ toString (not todo.isCompleted))
        , button 
            [onClick address (UpdateIsTodoCompleted todo (not todo.isCompleted))]
            [text (if todo.isCompleted then "Marquer 'non fait'" else "Marquer 'fait'")]
        ]

sectionFiltres : Address Action -> Html
sectionFiltres address =
    ul
        []
        [ li [][button [onClick address (ChangeFilter All)][text "Tous"]]
        , li [][button [onClick address (ChangeFilter Completed)][text "Termines"]]
        , li [][button [onClick address (ChangeFilter Active)][text "A faire"]]  
        ]
 
footer : Address Action -> Model -> Html
footer address model =
    let
         nbTotal = List.length model.todos
         nbActives = List.filter (\t->not t.isCompleted) model.todos |> List.length
         textFinal = 
            if nbActives == 0 then "Bravo, vs pouvez ne plus rien faire !"
            else if nbActives == 1 then "Un dernier effort...il n'en reste plus qu'une !"
            else (toString nbActives) ++"/"++(toString nbTotal)++" taches restantes"
    in     
        div
            []
            [ (lazy sectionFiltres address)
            , text <| textFinal
            ]
          
onEnter : Address a -> a -> Attribute
onEnter address value =
    on "keydown"
      (Json.customDecoder keyCode is13)
      (\_ -> Signal.message address value)


is13 : Int -> Result String ()
is13 code =
  if code == 13 then Ok () else Err "not the right key code"
  
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
    JsonD.list todoDecoder

todoDecoder : JsonD.Decoder (Todo)        
todoDecoder =
    JsonD.object3 Todo
        ("text" := JsonD.string)
        ("id" := JsonD.int)
        ("isCompleted" := JsonD.bool)