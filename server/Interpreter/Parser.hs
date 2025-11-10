-- Lexical analysis for the naive lambda calculus.
module Parser where

import Lexer

newtype Variable = Variable String
  deriving (Show, Eq)

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

-- Parser using Pratt parsing algorithm, see https://en.wikipedia.org/wiki/Operator-precedence_parser#Pratt_parsing for more
parserLoop :: AST -> [Token] -> Int -> (AST, [Token])
parserLoop left all@(h : rest) bp =
  case h of
    Token Space _ ->
      let (lbp, rbp) = bindingPower h
       in if lbp < bp
            then (left, all)
            else
              let (rhs, rest') = parseExpression rest rbp
               in parserLoop (app left rhs) rest' bp
    Token Dot _ -> (left, all) -- ridondante
    _ -> (left, all)

parseExpression :: [Token] -> Int -> (AST, [Token])
parseExpression [] _ = error "Unexpected end of input"
parseExpression (t : ts) bp =
  let (lhs, restAfterLhs) = case t of
        Token Var v -> (var (Variable v), ts)
        Token Lam _ -> case ts of
          (Token Var v : Token Dot _ : rest) ->
            let (body, rest') = parseExpression rest 0
             in (abstr (var (Variable v)) body, rest')
          _ -> error "Malformed lambda abstraction"
        _ -> error ("Unexpected token: " ++ show t)
   in parserLoop lhs restAfterLhs bp

-- Main parsing function
parseLambda :: [Token] -> AST
parseLambda tokens = fst (parseExpression tokens 0)

-- Decide binding power (important for precedence and operator associativity)
bindingPower :: Token -> (Int, Int)
bindingPower (Token Lam _) = (6, 5)
bindingPower (Token Space _) = (7, 8) -- Space is the application 'operator'
bindingPower _ = error "Invalid operator"
