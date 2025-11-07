-- Lexical analysis for the naive lambda calculus.
module Parser where

import Lexer

newtype Variable = Variable String
  deriving (Show)

data AST
  = NodeVar Variable
  | Application AST AST
  | Abstraction AST AST -- first AST is a variable node
  deriving (Show)

-- constructors
var :: Variable -> AST
var = NodeVar

app :: AST -> AST -> AST
app = Application

abstr :: AST -> AST -> AST
abstr = Abstraction

-- Praser using Pratt parsing algorith, see https://en.wikipedia.org/wiki/Operator-precedence_parser#Pratt_parsing for more
parserLoop :: AST -> [Token] -> Int -> AST
parserLoop left (h : rest) bp
  | Token Lam _ <- h = if lbp < bp then left else abstr left (parseExpression rest rbp)
  | Token Space _ <- h = if lbp < bp then left else app left (parseExpression rest rbp)
  | Token End _ <- h = left -- end
  | Token Var _ <- h = error "var"
  | Token Dot _ <- h = error "dot"
  | otherwise = error "Bad token"
  where
    (lbp, rbp) = infixBindingPower h

handleFirstToken :: Token -> AST
handleFirstToken (Token Var v) = var (Variable v)
handleFirstToken _ = error "Bad token"

parseExpression :: [Token] -> Int -> AST
parseExpression (h : rest) bp
  | Token Var _ <- h = parserLoop (handleFirstToken h) rest bp
  | otherwise = error "Unexpected Token"

-- Main parsing function
parseLambda :: [Token] -> AST
parseLambda tokens = parseExpression tokens 0

-- Decide binding power (important for precedence and operator associativity)
infixBindingPower :: Token -> (Int, Int)
infixBindingPower (Token Lam _) = (5, 6)
infixBindingPower (Token Space _) = (8, 7) -- Space is the application 'operator'
infixBindingPower _ = error "Invalid operator"
