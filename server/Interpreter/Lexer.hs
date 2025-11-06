-- Lexical analysis for the naive lambda calculus.
module Lexer where

import Data.Char (isAlpha, isSpace)

-- import Syntax

data TokenType = Var | LPar | RPar | Lam | Dot | Space deriving (Enum, Show, Eq)

data Token = Token TokenType String deriving (Show, Eq)

-- Wrapper
lexLambda :: String -> [Token]
lexLambda s = removeSpaces (tokenize s [])

-- Produces a list of token in the submitted Lambda calculus program
tokenize :: String -> String -> [Token]
tokenize [] [] = []
tokenize [] currentVar = [Token Var (reverse currentVar)]
tokenize ('\\' : end) [] = Token Lam "\\" : tokenize end []
tokenize ('\\' : end) currentVar = Token Var (reverse currentVar) : Token Lam "\\" : tokenize end []
tokenize (' ' : end) [] = Token Space " " : tokenize end []
tokenize (' ' : end) currentVar = Token Var (reverse currentVar) : Token Space " " : tokenize end []
tokenize ('(' : end) [] = Token LPar "(" : tokenize end []
tokenize ('(' : end) currentVar = Token Var (reverse currentVar) : Token LPar "(" : tokenize end []
tokenize (')' : end) [] = Token RPar ")" : tokenize end []
tokenize (')' : end) currentVar = Token Var (reverse currentVar) : Token RPar ")" : tokenize end []
tokenize ('.' : end) [] = Token Dot "." : tokenize end []
tokenize ('.' : end) currentVar = Token Var (reverse currentVar) : Token Dot "." : tokenize end []
tokenize (x : end) currentVar
  | isAlpha x = tokenize end (x : currentVar)
  | otherwise =
      if null currentVar
        then tokenize end []
        else Token Var (reverse currentVar) : tokenize end []

-- Remove reduntant spaces (we need space since we allowed variables with multiple chars, if we didn't have space variable "aa" would be an application)
removeSpaces :: [Token] -> [Token]
removeSpaces [] = []
removeSpaces (Token Space _ : Token Space _ : end) = Token Space " " : removeSpaces end
removeSpaces (head : end) = head : removeSpaces end
