module TypeChecker where 

import Lexer
import Parser

-- aqui definimos o tipo das expressoes.


type Ctx = [(String, Ty)]

typeof :: Ctx -> Expr -> Maybe Ty
typeof ctx BTrue = Just TBool 
typeof ctx BFalse = Just TBool 
typeof ctx (Num _) = Just TNum
-- a funcao comeca com a expressao "do" , porque ele permite a execução de uma sequencia de acoes
-- e depois retorne o resultado.
typeof ctx (Pair e1 e2) = do
  ty1 <- typeof ctx e1
  ty2 <- typeof ctx e2
  Just (TPair ty1 ty2)
typeof ctx (First e) = case typeof ctx e of 
                         Just (TPair t1 t2) -> Just t1
                         _                  -> Nothing
typeof ctx (Second e) = case typeof ctx e of 
                          Just (TPair t1 t2) -> Just t2
                          _                  -> Nothing
typeof ctx (Add e1 e2) = case (typeof ctx e1, typeof ctx e2) of 
                           (Just TNum, Just TNum) -> Just TNum
                           _                       -> Nothing 
typeof ctx (And e1 e2) = case (typeof ctx e1, typeof ctx  e2) of 
                           (Just TBool, Just TBool) -> Just TBool 
                           _                         -> Nothing
typeof ctx (Or e1 e2) = case (typeof ctx e1, typeof ctx  e2) of
                          (Just TBool, Just TBool) -> Just TBool 
                          _                        -> Nothing
-- primeiro verificamos o tipo de e1 eadicionamos ele ao contexto 
-- de verificacao de tipos com o (v, t1) e depois verificamos o tipo de e2, com ((v, t1):ctx)) e2
typeof ctx (Let v e1 e2) = case typeof ctx e1 of 
                             Just t1 -> typeof ((v, t1):ctx) e2
                             _       -> Nothing
typeof ctx (Not e1) = case typeof ctx e1 of 
                       Just TBool -> Just TBool 
                       _          -> Nothing
typeof ctx (Sub e1 e2) = case (typeof ctx e1, typeof ctx e2) of 
                           (Just TNum, Just TNum) -> Just TNum
                           _                       -> Nothing
typeof ctx (Mul e1 e2) = case (typeof ctx e1, typeof ctx e2) of
                            (Just TNum, Just TNum) -> Just TNum
                            _                       -> Nothing
typeof ctx (Maior e1 e2) = case (typeof ctx e1, typeof ctx e2) of 
                             (Just TNum, Just TNum) -> Just TBool
                             _                      -> Nothing             
typeof ctx (MaiorIgual e1 e2) = case (typeof ctx e1, typeof ctx e2) of 
                                  (Just TNum, Just TNum) -> Just TBool
                                  _                      -> Nothing
typeof ctx (In e1 e2) = case (typeof ctx e1, typeof ctx e2) of
                          (Just TNum, Just TNum) -> Just TBool
                          _                       -> Nothing
typeof ctx (Igual e1 e2) = case (typeof ctx e1, typeof ctx e2) of 
                             (Just TNum, Just TNum) -> Just TBool
                             _                      -> Nothing
typeof ctx (If e1 e2 e3) = case typeof ctx e1 of 
      Just TBool -> case (typeof ctx e2, typeof ctx e3) of 
                      (Just t1, Just t2) -> if t1 == t2 then
                                              Just t1 
                                            else 
                                              Nothing
                      _                  -> Nothing 
      _          -> Nothing
typeof ctx (Var v) = lookup v ctx 
typeof ctx (Lam v t1 b) = let Just t2 = typeof ((v, t1):ctx) b 
                            in Just (TFun t1 t2)
typeof ctx (App t1 t2) = case (typeof ctx t1, typeof ctx t2) of 
                           (Just (TFun t11 t12), Just t2) -> if (t11 == t2) then 
                                                               Just t12 
                                                             else 
                                                               Nothing
                           _                              -> Nothing 
typeof ctx (Eq e1 e2) = case (typeof ctx e1, typeof ctx e2) of 
                          (Just t1, Just t2) -> if t1 == t2 then
                                                  Just TBool
                                                else 
                                                  Nothing
                          _                  -> Nothing
typeof ctx (Paren e) = typeof ctx e 


typecheck :: Expr -> Expr 
typecheck e = case typeof [] e of 
                Just _ -> e 
                _      -> error "Type error"