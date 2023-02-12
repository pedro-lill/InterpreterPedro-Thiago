module Interpreter where

import Lexer
import Parser
import TypeChecker


subst :: String -> Expr -> Expr -> Expr 
subst x n b@(Var v) = if v == x then 
                        n 
                      else 
                        b 
subst x n (Lam v t b) = Lam v t (subst x n b)
subst x n (App e1 e2) = App (subst x n e1) (subst x n e2)
subst x n (Add e1 e2) = Add (subst x n e1) (subst x n e2)
subst x n (Or e1 e2) = Or (subst x n e1) (subst x n e2)
-- subs sub
subst x n (Sub e1 e2) = Sub (subst x n e1) (subst x n e2)
-- subst mul
subst x n (Mul e1 e2) = Mul (subst x n e1) (subst x n e2)
--subst pair
subst x n (Pair e1 e2) = Pair (subst x n e1) (subst x n e2)
-- subst first
subst x n (First e) = First (subst x n e)
--subst second
subst x n (Second e) = Second (subst x n e)
-- subst or
subst x n (And e1 e2) = And (subst x n e1) (subst x n e2)
-- subst not
subst x n (Not e) = Not (subst x n e)
-- subst let
subst x n (Let v e1 e2) = Let v (subst x n e1) (subst x n e2)
subst x n (Eq e1 e2) = Eq (subst x n e1) (subst x n e2)
-- subst in
subst x n (In e1 e2) = In (subst x n e1) (subst x n e2)
subst x n (If e e1 e2) = If (subst x n e) (subst x n e1) (subst x n e2)
subst x n (Paren e) = Paren (subst x n e)
subst x n e = e 

isvalue :: Expr -> Bool 
isvalue BTrue = True
isvalue BFalse = True
isvalue (Num _) = True
isvalue (Lam _ _ _) = True 
isvalue _ = False 

step :: Expr -> Maybe Expr      
-- step add
step (Add (Num n1) (Num n2)) = Just (Num (n1 + n2))
step (Add (Num n1) e2) = case step e2 of 
                           Just e2' -> Just (Add (Num n1) e2')
                           _        -> Nothing
step (Add e1 e2) = case step e1 of 
                     Just e1' -> Just (Add e1' e2)
                     _        -> Nothing
-- step sub
step (Sub (Num n1) (Num n2)) = Just (Num (n1 - n2))
step (Sub (Num n1) e2) = case step e2 of 
                           Just e2' -> Just (Sub (Num n1) e2')
                           _        -> Nothing
step (Sub e1 e2) = case step e1 of
                      Just e1' -> Just (Sub e1' e2)
                      _        -> Nothing
-- step mul
step (Mul (Num n1) (Num n2)) = Just (Num (n1 * n2))
step (Mul (Num n1) e2) = case step e2 of 
                           Just e2' -> Just (Mul (Num n1) e2')
                           _        -> Nothing
step (Mul e1 e2) = case step e1 of
                      Just e1' -> Just (Mul e1' e2)
                      _        -> Nothing
-- step or
step (Or BTrue _) = Just BTrue
step (Or BFalse e2) = Just e2
step (Or e1 e2) = case step e1 of 
                     Just e1' -> Just (Or e1' e2)
                     _        -> Nothing
-- step and
step (And BTrue e2) = Just e2 
step (And BFalse _) = Just BFalse 
step (And e1 e2) = case step e1 of 
                     Just e1' -> Just (And e1' e2)
                     _        -> Nothing
-- step maior
step (Maior (Num n1) (Num n2)) = if (n1 > n2) then 
                                   Just BTrue 
                                 else 
                                   Just BFalse
step (Maior (Num n1) e2) = case step e2 of
                              Just e2' -> Just (Maior (Num n1) e2')
                              _        -> Nothing
-- step maiorIgual
step (MaiorIgual (Num n1) (Num n2)) = if (n1 >= n2) then 
                                   Just BTrue 
                                 else 
                                   Just BFalse
step (MaiorIgual (Num n1) e2) = case step e2 of
                              Just e2' -> Just (MaiorIgual (Num n1) e2')
                              _        -> Nothing
-- step pair
step (Pair e1 e2) | isvalue e1 && isvalue e2 = Just (Pair e1 e2)
step (Pair e1 e2) | isvalue e1 = case step e2 of
                                   Just e2' -> Just (Pair e1 e2')
                                   _ -> Nothing
step (Pair e1 e2) = case step e1 of
                      Just e1' -> Just (Pair e1' e2)
                      _ -> Nothing
step (First e) = case step e of
                    Just (Pair e1 _) -> Just e1
                    _ -> Nothing
step (Second e) = case step e of
                      Just (Pair _ e2) -> Just e2
                      _ -> Nothing
-- step in
step (In e1 e2) = case step e1 of 
                    Just e1' -> Just (In e1' e2)
                    _        -> Nothing
-- step not
step (Not BTrue) = Just BFalse
step (Not BFalse) = Just BTrue
step (Not e1) = case step e1 of
                 Just e1' -> Just (Not e1')
                 _        -> Nothing
-- step if
step (If BTrue e1 _) = Just e1 
step (If BFalse _ e2) = Just e2 
step (If e e1 e2) = case step e of 
                      Just e' -> Just (If e' e1 e2)
                      _       -> Nothing
step (App e1@(Lam x t b) e2) | isvalue e2 = Just (subst x e2 b)
                             | otherwise = case step e2 of 
                                             Just e2' -> Just (App e1 e2')
                                             _        -> Nothing 
step (App e1 e2) = case step e1 of 
                     Just e1' -> Just (App e1' e2)
                     _        -> Nothing
-- desenvolvendo step let
step (Let x e1 e2)
  | isvalue e1 = Just (subst x e1 e2)
  | otherwise = do
      e1' <- step e1
      return (Let x e1' e2)
step (Paren e) = Just e
-- step equals
step (Eq e1 e2) | isvalue e1 && isvalue e2 = if (e1 == e2) then
                                               Just BTrue 
                                             else 
                                               Just BFalse 
                | isvalue e1 = case step e2 of 
                                 Just e2' -> Just (Eq e1 e2')
                                 _        -> Nothing
                | otherwise = case step e1 of 
                                Just e1' -> Just (Eq e1' e2)
                                _        -> Nothing 
step e = Just e 

eval :: Expr -> Expr 
eval e | isvalue e = e 
       | otherwise = case step e of 
                       Just e' -> eval e'
                       _       -> error "Interpreter error!"
