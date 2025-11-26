{-# LANGUAGE OverloadedStrings #-}

module Main where

import Beta
import Control.Monad.IO.Class (liftIO)
import Lexer
import Network.Wai.Middleware.Cors
import Parser
import Syntax
import Utils (prettyPrint, prettyPrintList)
import Web.Scotty

main :: IO ()
-- main = do
--   let tokens = lexLambda "(\\x.x  x) zz"
--       parsedAST = parseLambda tokens
--       reducedAST = last (betaStepByStep (Just parsedAST))
-- putStrLn (prettyPrint reducedAST)

main = scotty 3000 $ do
  middleware $ cors (const $ Just viteCorsPolicy)

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

viteCorsPolicy :: CorsResourcePolicy
viteCorsPolicy =
  simpleCorsResourcePolicy
    { corsOrigins = Just (["http://localhost:5173"], True),
      corsMethods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
      corsRequestHeaders = ["Content-Type", "Authorization"]
    }
