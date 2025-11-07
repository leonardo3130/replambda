-- Lexical analysis for the naive lambda calculus.
module Lexer where

import Data.Char (isAlpha, isSpace)

data TokenType = Var | LPar | RPar | Lam | Dot | Space | End deriving (Enum, Show, Eq)

data Token = Token TokenType String deriving (Show, Eq)

-- Wrapper
lexLambda :: String -> [Token]
lexLambda s = reverse (Token End "END" : preprocess s)

-- String preprocessing (spaces handling)
preprocess :: String -> [Token]
-- preprocess = reverse . removeUselessSpaces . removeRedundantSpaces . reverse . removeRedundantSpaces . (`tokenize` [])
preprocess = removeUselessSpaces . collapseSpaces . reverse . removeRedundantSpaces . reverse . removeRedundantSpaces . (`tokenize` [])

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

-- Remove redundant spaces (we need space since we allowed variables with multiple chars, if we didn't have space variable "aa" would be an application)
removeRedundantSpaces :: [Token] -> [Token]
removeRedundantSpaces (Token Space _ : rest) = removeRedundantSpaces rest
removeRedundantSpaces t = t

collapseSpaces :: [Token] -> [Token]
collapseSpaces [] = []
collapseSpaces ((Token Space _) : (Token Space _) : rest) = collapseSpaces (Token Space " " : rest)
collapseSpaces (h : rest) = h : collapseSpaces rest

-- Remove non-application spaces, keep only those spaces who are relevant for application
removeUselessSpaces :: [Token] -> [Token]
removeUselessSpaces [] = []
removeUselessSpaces [t] = [t]
removeUselessSpaces [t1, t2] = [t1, t2]
removeUselessSpaces (t1@(Token k1 s1) : t2@(Token Space _) : t3@(Token k3 s3) : rest) -- t1@... is called argument capture --> give name to matched value
  | needSpace k1 k3 = t1 : t2 : t3 : removeUselessSpaces rest
  | otherwise = t1 : removeUselessSpaces (t3 : rest)
  where
    needSpace RPar LPar = True
    needSpace RPar Var = True
    needSpace Var LPar = True
    needSpace Var Var = True
    needSpace _ _ = False
removeUselessSpaces (t1 : rest) = t1 : removeUselessSpaces rest
