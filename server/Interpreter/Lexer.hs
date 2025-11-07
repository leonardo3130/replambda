-- Lexical analysis for the naive lambda calculus.
module Lexer where

import Data.Char (isAlpha, isSpace)

data TokenType = Var | LPar | RPar | Lam | Dot | Space | End deriving (Enum, Show, Eq)

data Token = Token TokenType String deriving (Show, Eq)

-- Wrapper
lexLambda :: String -> [Token]
lexLambda = reverse . removeUselessSpaces . removeRedundantSpaces . reverse . removeRedundantSpaces . reverse . (`tokenize` [])

-- Produces a list of token in the submitted Lambda calculus program
tokenize :: String -> String -> [Token]
tokenize [] [] = [Token End "END"]
tokenize [] currentVar = Token Var (reverse currentVar) : [Token End "END"]
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

-- Remove redundant spaces (we need space since we allowed variables with multiple chars, if we didn't have space variable "aa" would be an application)
removeRedundantSpaces :: [Token] -> [Token]
removeRedundantSpaces [] = []
removeRedundantSpaces (Token Space _ : Token Space _ : end) = Token Space " " : removeRedundantSpaces end
removeRedundantSpaces (head : end) = head : removeRedundantSpaces end

-- Remove non-application spaces, keep only those spaces who are relevant for application
removeUselessSpaces :: [Token] -> [Token]
removeUselessSpaces [] = []
removeUselessSpaces [t] = [t]
removeUselessSpaces (t1@(Token k1 s1) : Token Space _ : t2@(Token k2 s2) : rest) -- t1@... is called argument capture --> give name to matched value
  | needSpace k1 k2 = t1 : Token Space " " : t2 : removeUselessSpaces rest
  | otherwise = t1 : removeUselessSpaces (t2 : rest)
  where
    needSpace RPar LPar = True
    needSpace RPar Var = True
    needSpace Var LPar = True
    needSpace Var Var = True
    needSpace _ _ = False
removeUselessSpaces (t@(Token Space _) : ts) = removeUselessSpaces ts
removeUselessSpaces (t : ts) = t : removeUselessSpaces ts
