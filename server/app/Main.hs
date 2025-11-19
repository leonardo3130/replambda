{-# LANGUAGE OverloadedStrings #-}

module Main where

import Beta
import Lexer
import Parser
import Syntax
import Utils (prettyPrint, prettyPrintList)
import Web.Scotty

main :: IO ()
main = scotty 3000 $ do
  post "/full-reduce" $ do
    expr <- jsonData :: ActionM String
    let tokens = lexLambda expr
        parsedAST = parseLambda tokens
        reducedAST = last (betaStepByStep (Just parsedAST))
    json reducedAST

  post "/parse" $ do
    expr <- jsonData :: ActionM String
    let tokens = lexLambda expr
        parsedAST = parseLambda tokens
    json parsedAST

  post "/tokens" $ do
    expr <- jsonData :: ActionM String
    let tokens = lexLambda expr
    json tokens

  post "/reduce-once" $ do
    expr <- jsonData :: ActionM String
    let tokens = lexLambda expr
        parsedAST = parseLambda tokens
        reducedAST = betaStep parsedAST
    case reducedAST of
      Just ast -> json ast
      Nothing -> json ("No reduction possible" :: String)

  post "/reduce-steps" $ do
    expr <- jsonData :: ActionM String
    let tokens = lexLambda expr
        parsedAST = parseLambda tokens
        reducedASTs = betaStepByStep (Just parsedAST)
    json reducedASTs
