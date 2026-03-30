-- Lexical analysis for the naive lambda calculus.
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

module Lexer where

import Data.Aeson (FromJSON, ToJSON (..), object, parseJSON, toJSON, (.:), (.=))
import qualified Data.Aeson as Data.Aeson.Key
import Data.Char (isAlpha, isSpace)

data TokenType = Var | LPar | RPar | Lam | Dot | Space | End deriving (Enum, Show, Eq)

data Token = Token TokenType String deriving (Show, Eq)

-- JSON instances for API return values
instance ToJSON TokenType where
  toJSON Var = "variable"
  toJSON LPar = "left_par"
  toJSON RPar = "right_par"
  toJSON Lam = "lambda"
  toJSON Dot = "dot"
  toJSON Space = "space"
  toJSON End = "end"

instance FromJSON TokenType where
  parseJSON =
    Data.Aeson.Key.withText
      "TokenType"
      ( \case
          "variable" -> return Var
          "left_par" -> return LPar
          "right_par" -> return RPar
          "lambda" -> return Lam
          "dot" -> return Dot
          "space" -> return Space
          "end" -> return End
          _ -> fail "Invalid token type"
      )

instance ToJSON Token where
  toJSON (Token t s) =
    object
      [ "type" .= toJSON t,
        "value" .= s
      ]

instance FromJSON Token where
  parseJSON =
    Data.Aeson.Key.withObject
      "Token"
      ( \o -> do
          t <- o Data.Aeson.Key..: "type"
          s <- o Data.Aeson.Key..: "value"
          return (Token t s)
      )

-- Wrapper
lexLambda :: String -> [Token]
lexLambda s = preprocess s ++ [Token End "END"]

-- String preprocessing (spaces handling)
preprocess :: String -> [Token]
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
    -- needSpace Var Lam = True
    -- needSpace RPar Lam = True
    needSpace _ _ = False
removeUselessSpaces (t1 : rest) = t1 : removeUselessSpaces rest
