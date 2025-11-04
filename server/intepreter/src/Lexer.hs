-- Lexical analysis for the naive lambda calculus.
module Lexer where

import Syntax
import Data.Char (isSpace)


data TokenType = Var | LPar | RPar | Lam | Dot | Space deriving (Enum)

-- Token = Token type + syntax symbol -> NO literal values
data Token = Token TokenTypes String

-- Produces a list of token in the submitted Lambda calculus program
tokenize :: String -> [Token]
tokenize [] [] = []
tokenize [] currentVar = (Token Var (reverse currentVar)) : []
tokenize ('\\' : end) currentVar = (Token Lam "\\") : tokenize end currentVar 
tokenize (' ' : end) [] = (Token Space " ") : tokenize end []
tokenize (' ' : end) currentVar = (Token Var currentVar) : (Token Space " ") : tokenize end []
tokenize ('(' : end) currentVar = (Token LPar "("): tokenize end currentVar
tokenize (')' : end) currentVar = (Token RPar ")"): tokenize end currentVar
tokenize ('.' : end) currentVar = (Token Dot "."): tokenize end
tokenize (x:end) currentVar
  | isAlpha x = tokenize end (x:currentVar)
