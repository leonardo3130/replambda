module Main where

import Beta
import Lexer
import Parser
import Syntax
import Utils (prettyPrint)

main :: IO ()
main = do
  putStrLn "Lambda REPL server running..."

  let tokens = lexLambda "(\\x.x) (\\z.z)"

  -- see tokens
  print tokens

  -- see parsed AST
  print (prettyPrint (parseLambda tokens))

  -- see beta reduced AST
  print (prettyPrint (betaReduce (parseLambda tokens)))
