module TodoManager.Ressources where

type alias Todo =
    { text : String
    , id : Int
    , isCompleted : Bool
    }

type Filter = All | Completed | Active 