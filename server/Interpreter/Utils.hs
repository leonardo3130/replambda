--   Defines utility functions used across the whole interpreter codebase
module Utils where

import Data.Char (isSpace)
import Data.List (nub)
import Lexer
import Parser

-- AST better printing
prettyPrint :: AST -> String
prettyPrint ast = case ast of
  NodeVar (Variable v) -> v
  Application f x ->
    let fStr = case f of
          Application _ _ -> "(" ++ prettyPrint f ++ ")"
          Abstraction _ _ -> "(" ++ prettyPrint f ++ ")"
          _ -> prettyPrint f
        xStr = case x of
          Application _ _ -> "(" ++ prettyPrint x ++ ")"
          Abstraction _ _ -> "(" ++ prettyPrint x ++ ")"
          _ -> prettyPrint x
     in fStr ++ " " ++ xStr
  Abstraction (NodeVar (Variable v)) body ->
    "\\" ++ v ++ ". (" ++ prettyPrint body ++ ")"
  Abstraction _ _ -> error "Abstraction must have a variable as first AST"

-- Check if variable is in list
contains :: (Eq a) => [a] -> a -> Bool
contains [] _ = False
contains (h : rest) t = (t == h) || contains rest t

-- Concat 2 lists and remove duplicates
concatUnique :: (Eq a) => [a] -> [a] -> [a]
concatUnique xs ys = nub (xs ++ ys)

-- Calculation of Free Variables
freeVars :: AST -> [Variable]
freeVars (NodeVar v) = [v]
freeVars (Application f a) = concatUnique (freeVars f) (freeVars a)
freeVars (Abstraction (NodeVar v) body) = filter (/= v) (freeVars body) -- filter out abstraction variable

-- Generate a fresh variable name
freshVar :: Variable -> [Variable] -> Variable
freshVar (Variable v) used =
  head $ filter (`notElem` used) candidates -- head (filter (`notElem` used) candidates)
  where
    candidates = map (Variable . (v ++) . show) [1 ..]

-- substitue a variable with an AST inside an AST
substitute :: Variable -> AST -> AST -> AST
substitute x n varnode@(NodeVar v)
  | v == x = n
  | otherwise = varnode
substitute x n (Application t1 t2) = Application (substitute x n t1) (substitute x n t2)
substitute x n ab@(Abstraction varnode@(NodeVar v) t2)
  | v == x = ab -- do not substitute inside the abstraction if the variable is bound here
  | otherwise = ab'
  where
    fvN = freeVars n
    fvT2 = freeVars t2
    -- check if variable capture would occur
    ab' =
      if contains fvN v
        then
          let usedVars = concatUnique fvN fvT2 ++ [v, x]
              vFresh = freshVar v usedVars
              t2Renamed = substitute v (NodeVar vFresh) t2
           in Abstraction (NodeVar vFresh) (substitute x n t2Renamed)
        else Abstraction varnode (substitute x n t2)
substitute _ _ _ = error "Abstraction must have a variable as first AST"
