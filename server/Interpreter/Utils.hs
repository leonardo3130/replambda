--   Defines utility functions used across the whole interpreter codebase
module Utils where

import Data.Char (isSpace)
import Parser

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
    "\\" ++ v ++ ". " ++ prettyPrint body
  Abstraction _ _ -> error "Abstraction must have a variable as first AST"
