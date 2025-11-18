-- Beta reduction on AST
module Beta where

import Parser
import Utils

-- function that performs beta reduction on an AST
betaReduce :: AST -> AST
betaReduce (Application (Abstraction (NodeVar v) t2) t1) = substitute v t1 t2
betaReduce (Application t1 t2) = Application (betaReduce t1) (betaReduce t2)
betaReduce (Abstraction (NodeVar v) t) = Abstraction (NodeVar v) (betaReduce t)
betaReduce varnode@(NodeVar _) = varnode

-- performs one step of beta reduction (when possible)
betaStep :: AST -> Maybe AST
betaStep ast =
  case ast of
    Application (Abstraction (NodeVar v) t2) t1 -> Just (substitute v t1 t2)
    Application t1 t2 ->
      case betaStep t1 of
        Just t1' -> Just (Application t1' t2)
        Nothing ->
          -- only when no reduction in t1, try t2 --> one step only
          case betaStep t2 of
            Just t2' -> Just (Application t1 t2')
            Nothing -> Nothing
    Abstraction var@(NodeVar v) t ->
      case betaStep t of
        Just t' -> Just (Abstraction var t')
        Nothing -> Nothing
    NodeVar _ -> Nothing

-- performs step by step beta reduction, return list of AST
betaStepByStep :: Maybe AST -> [AST]
betaStepByStep t =
  case t of
    Nothing -> []
    Just t' ->
      case betaStep t' of
        Just t'' -> t'' : betaStepByStep (Just t'')
        Nothing -> []
