-- Beta reduction on AST
module Beta where

import Parser
import Utils

betaStep :: AST -> Maybe AST
betaStep ast =
  case ast of
    Application (Abstraction (NodeVar v) t2) t1 -> Just $ substitute v t1 t2
    Application t1 t2 ->
      case betaStep t1 of
        Just t1' -> Just $ Application t1' t2
        Nothing ->
          -- only when no reduction in t1, try t2 --> one step only
          case betaStep t2 of
            Just t2' -> Just $ Application t1 t2'
            Nothing -> Nothing
    Abstraction var@(NodeVar v) t ->
      case betaStep t of
        Just t' -> Just $ Abstraction var t'
        Nothing -> Nothing
    NodeVar _ -> Nothing

-- performs step by step beta reduction, return list of AST
betaStepByStep :: Maybe AST -> [AST]
betaStepByStep t =
  case t of
    Nothing -> []
    Just t' ->
      case betaStep t' of
        Just t'' -> if t' == t'' then [] else t'' : betaStepByStep (Just t'')
        Nothing -> []
