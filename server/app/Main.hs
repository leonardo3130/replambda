module Main where

import Lexer
import Parser
import Syntax

main :: IO ()
main = do
  putStrLn "Lambda REPL server running..."

  let tokens = lexLambda "   xx  \\        .      xx      xx   yy   sdfr   "
  print tokens

  print (parseLambda tokens)
