module Lexer where 

import Data.Char 

data Ty = TBool
        | TNum
        | TFun Ty Ty
        | TPair Ty Ty
        deriving (Show, Eq)

data Expr = BTrue
          | BFalse
          | Num Int 
          | Add Expr Expr
          | Sub Expr Expr 
          | Mul Expr Expr
          | Or Expr Expr
          | And Expr Expr
          | Eq Expr Expr
          | In Expr Expr
          | Not Expr        --ok
          | Virgula Expr Expr
          | Maior Expr Expr
          | MaiorIgual Expr Expr
          | Igual Expr Expr
          | If Expr Expr Expr 
          | Var String
          | Let String Expr Expr        --ok
          | Lam String Ty Expr 
          | App Expr Expr 
          | Paren Expr
          | Pair Expr Expr 
          | First Expr
          | Second Expr
          deriving (Show, Eq)

data Token = TokenTrue 
           | TokenFalse 
           | TokenNum Int 
           | TokenAdd 
           | TokenSub
           | TokenMul
           | TokenOr
           | TokenAnd
           | TokenNot           --ok
           | TokenMaior           
           | TokenLet           
           | TokenMaiorIgual
           | TokenPair
           | TokenFirst
           | TokenSecond
           | TokenVirgula
           | TokenIf 
           | TokenThen
           | TokenElse 
           | TokenVar String 
           | TokenLam
           | TokenColon
           | TokenArrow 
           | TokenLParen
           | TokenRParen
           | TokenBoolean
           | TokenNumber
           | TokenIgual
           | TokenEq
           | TokenIn
           deriving Show 

isToken :: Char -> Bool
isToken c = elem c "->&|="

lexer :: String -> [Token]
lexer [] = [] 
lexer ('=':cs) = TokenIgual : lexer cs
lexer ('+':cs) = TokenAdd : lexer cs
lexer ('*':cs) = TokenMul : lexer cs
lexer ('\\':cs) = TokenLam : lexer cs
lexer (':':cs) = TokenColon : lexer cs
lexer (',':cs) = TokenVirgula : lexer cs
lexer ('(':cs) = TokenLParen : lexer cs
lexer (')':cs) = TokenRParen : lexer cs
lexer (c:cs) | isSpace c = lexer cs 
             | isDigit c = lexNum (c:cs)
             | isAlpha c = lexKW (c:cs)
             | isToken c = lexSymbol (c:cs)
lexer _ = error "Lexical error: caracter inválido! ++ show cs"

lexNum :: String -> [Token]
lexNum cs = case span isDigit cs of 
        (num, rest) -> TokenNum (read num) : lexer rest 


lexKW :: String -> [Token]
lexKW cs = case span isAlpha cs of 
             ("true", rest)  -> TokenTrue : lexer rest 
             ("false", rest) -> TokenFalse : lexer rest 
             ("if", rest)    -> TokenIf : lexer rest 
             ("then", rest)  -> TokenThen : lexer rest 
             ("else", rest)  -> TokenElse : lexer rest           --ok
             ("Bool", rest)  -> TokenBoolean : lexer rest
             ("not", rest)  -> TokenNot : lexer rest 
             ("Number", rest)  -> TokenNumber : lexer rest 
             ("let", rest) -> TokenLet : lexer rest
             ("in", rest) -> TokenIn : lexer rest
             ("pair", rest) -> TokenPair : lexer rest
             ("first", rest) -> TokenFirst : lexer rest
             ("second", rest) -> TokenSecond : lexer rest
             (var, rest)     -> TokenVar var : lexer rest 

lexSymbol :: String -> [Token]
lexSymbol cs = case span isToken cs of
                   ("->", rest) -> TokenArrow  : lexer rest
                   ("-", rest) -> TokenSub  : lexer rest
                   ("&&", rest) -> TokenAnd    : lexer rest
                   ("||", rest) -> TokenOr     : lexer rest
                   ("==", rest) -> TokenEq     : lexer rest
                   (">", rest)  -> TokenMaior  : lexer rest
                   (">=", rest) -> TokenMaiorIgual : lexer rest
                   _ -> error "Lexical error: símbolo inválido!"