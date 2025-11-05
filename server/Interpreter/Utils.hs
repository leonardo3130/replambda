--   Defines utility functions used across the whole interpreter codebase
module Utils where

import Data.Char (isSpace)

-- Trim whitespaces
trim :: String -> String
trim = f . f -- . Is the function composition operator, it combines 2 functions in a single one
  where
    f = reverse . dropWhile isSpace -- Function "dropWhile" return a suffix that start with an element that doesn't satisfy the condition
