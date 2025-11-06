module Syntax where

-- grammar
data Term
  = Var String
  | Ab String Term
  | App Term Term
  deriving (Eq)

-- pretty-printing
instance Show Term where
  show (Var x) = x
  show (Ab x t) = "(\\" ++ x ++ ". " ++ show t ++ ")"
  show (App t1 t2) = "(" ++ show t1 ++ " " ++ show t2 ++ ")"

-- helper constructors
lam :: String -> Term -> Term
lam = Ab

app :: Term -> Term -> Term
app = App

var :: String -> Term
var = Var
