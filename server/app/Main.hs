module Main where

import Beta
import Lexer
import Parser
import Syntax
import Utils (prettyPrint, prettyPrintList)

main :: IO ()
main = do
  putStrLn "Lambda REPL server running..."

  let tokens = lexLambda "(\\x.x) ((\\z.z) (\\y.y))"

  -- see tokens
  print tokens

  -- see parsed AST
  print (prettyPrint (parseLambda tokens))

  -- see beta reduced AST
  print (prettyPrintList (betaStepByStep (Just (parseLambda tokens))))
