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

-- Praser using Pratt parsing algorith, see https://en.wikipedia.org/wiki/Operator-precedence_parser#Pratt_parsing for more

-- Lambda calculus recursive descent parser
-- parse :: [Token] -> AST

infixBindingPower :: Token -> (Int, Int)
infixBindingPower (Token Lam _) = (5, 6)
infixBindingPower (Token Space _) = (10, 9) -- Space is the application 'operator'
