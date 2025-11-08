module Main where

import Lexer
import Parser
import Syntax
import Utils (prettyPrint)

main :: IO ()
main = do
  putStrLn "Lambda REPL server running..."

  let tokens = lexLambda "    \\   xx     .      xx      xx   yy   sdfr   "

  print (prettyPrint (parseLambda tokens))
