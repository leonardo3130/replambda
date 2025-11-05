-- Lexical analysis for the naive lambda calculus.
module Parser where

import Lexer
import Syntax

newtype Var = Var String

data AST
  = NodeVar Var
  | Application AST AST
  | Abstraction Var AST

-- deriving (Show, Eq)

-- Lambda calculus recursive descent parser
-- parse :: [Token] -> AST
