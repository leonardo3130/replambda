module Main where

import Lexer
import Parser
import Syntax
import Utils (prettyPrint)

main :: IO ()
main = do
  putStrLn "Lambda REPL server running..."

  let tokens = lexLambda "\\x. x x \\y. y y"

  print tokens

  print (prettyPrint (parseLambda tokens))
