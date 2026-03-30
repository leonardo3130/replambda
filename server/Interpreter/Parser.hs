-- Parser for the naive lambda calculus.
{-# LANGUAGE OverloadedStrings #-}

module Parser where

import Data.Aeson (FromJSON, ToJSON (..), object, parseJSON, toJSON, (.:), (.=))
import qualified Data.Aeson as Data.Aeson.Key
import Lexer

newtype Variable = Variable String
  deriving (Show, Eq)

data AST
  = NodeVar Variable
  | Application AST AST
  | Abstraction AST AST -- first AST is a variable node
  deriving (Show, Eq)

-- JSON instances for API return values
instance ToJSON Variable where
  toJSON (Variable v) = toJSON v

instance FromJSON Variable where
  parseJSON v = do
    x <- parseJSON v
    return (Variable x)

instance ToJSON AST where
  toJSON (NodeVar v) =
    object
      [ "operation" .= ("var" :: String),
        "var" .= v
      ]
  toJSON (Application t1 t2) =
    object
      [ "operation" .= ("app" :: String),
        "body" .= t1,
        "argument" .= t2
      ]
  toJSON (Abstraction (NodeVar (Variable v)) t) =
    object
      [ "operation" .= ("lam" :: String),
        "lam_var"
          .= object
            [ "operation" .= ("var" :: String),
              "var" .= v
            ],
        "body" .= t
      ]

instance FromJSON AST where
  parseJSON =
    Data.Aeson.Key.withObject
      "AST"
      ( \o -> do
          op <- o Data.Aeson.Key..: "operation"
          case (op :: String) of
            "var" -> do
              v <- o Data.Aeson.Key..: "var"
              return (NodeVar v)
            "app" -> do
              t1 <- o Data.Aeson.Key..: "body"
              t2 <- o Data.Aeson.Key..: "argument"
              return (Application t1 t2)
            "lam" -> do
              v <- o Data.Aeson.Key..: "lam_var"
              t <- o Data.Aeson.Key..: "body"
              return (Abstraction (NodeVar (Variable v)) t)
            _ -> fail "Unknown operation"
      )

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
        Token LPar _ ->
          let (expr, rest') = parseExpression ts 0
           in case rest' of
                (Token RPar _ : rest'') -> (expr, rest'')
                _ -> error "Expected closing parenthesis"
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
