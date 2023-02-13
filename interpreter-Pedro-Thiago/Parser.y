{
module Parser where 

import Lexer 
}

%name parser 
%tokentype { Token }
%error { parseError }

%token
    num         { TokenNum $$ }
    '+'         { TokenAdd }
    '-'         { TokenSub }
    '='         { TokenIgual }
    '*'         { TokenMul }
    "||"        { TokenOr }
    "&&"        { TokenAnd }
    "=="        { TokenEq }
    ">"         { TokenMaior }
    ">="        { TokenMaiorIgual }
    true        { TokenTrue }
    false       { TokenFalse }
    Not         { TokenNot}                     --ok
    if          { TokenIf }
    then        { TokenThen }
    Pair        { TokenPair }
    first       { TokenFirst }
    second      { TokenSecond }
    let         { TokenLet }
    else        { TokenElse }
    var         { TokenVar $$ }
    '\\'        { TokenLam }
    ':'         { TokenColon }
    "->"        { TokenArrow }
    '('         { TokenLParen }
    ')'         { TokenRParen }
    ','         { TokenVirgula }
    in          { TokenIn }
    Bool        { TokenBoolean }
    Number      { TokenNumber }

%nonassoc if then else
%right in
%left '+' '-'
%left '*'
%left "&&" "||"
%left ">"
%left ">="
%left ","
%left "=="
%left '='

%% 

Exp     : num                        { Num $1 }
        | var                        { Var $1 }
        | false                      { BFalse }
        | true                       { BTrue }
        | Exp ',' Exp                { Virgula $1 $3 }
        | Exp '+' Exp                { Add $1 $3 }
        | Exp '-' Exp                { Sub $1 $3 }
        | Exp '*' Exp                { Mul $1 $3 }
        | Exp '=' Exp                { Igual $1 $3 }
        | Exp in Exp                 { In $1 $3 }      --ok
        | Exp "&&" Exp               { And $1 $3 }
        | '(' Exp ',' Exp ')'        { Pair $2 $4 }
        | first  Exp                 { First $2 }
        | second Exp                 { Second $2 }
        | Exp "||" Exp               { Or $1 $3 }
        | Not Exp                    { Not $2 }         --ok
        | Exp ">" Exp                { Maior $1 $3 }
        | Exp ">=" Exp               { MaiorIgual $1 $3 }
        | if Exp then Exp else Exp   { If $2 $4 $6 }
        | '\\' var ':' Type "->" Exp { Lam $2 $4 $6 }
        | let var '=' Exp in Exp     { Let $2 $4 $6 }
        | Exp Exp                    { App $1 $2 }
        | '(' Exp ')'                { Paren $2 }
        | Exp "==" Exp               { Eq $1 $3 }

Type    : Bool                       { TBool }
        | Number                     { TNum }
        | '(' Type "->" Type ')'     { TFun $2 $4 }
        | '(' Type ',' Type ')'      { TPair $2 $4 }
{ 

parseError :: [Token] -> a 
parseError _ = error "Syntax error!"

}