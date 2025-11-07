module Main where

import Lexer
import Syntax
import Utils

main :: IO ()
main = do
  putStrLn "Lambda REPL server running..."

  let tokens = lexLambda "  qq  \\   xx    .   xx    xx    yy    "
  print (reverse tokens)
