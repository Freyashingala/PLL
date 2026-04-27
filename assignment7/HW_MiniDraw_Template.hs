{-# OPTIONS_GHC -Wno-unused-top-binds #-}
-- HW_MiniDraw.hs
-- Name: Freya Mitulbhai Shingala
-- Student ID: 230101094

module HW_MiniDraw where

import Data.Monoid

-- =====================
-- BASIC TYPES
-- =====================

type Program = [Cmd]
type Point = (Int, Int)
type Scene = [(Shape, Point)]

data Expr
  = Val Int
  | Add Expr Expr
  | Mul Expr Expr
  deriving (Eq, Show)

data Shape
  = Circle Expr
  | Rect Expr Expr
  deriving (Eq, Show)

data Cmd
  = Draw Shape
  | Move Expr Expr
  deriving (Eq, Show)

-- =====================
-- PART 1: Expressions
-- =====================

-- | >>> evalExpr (Add (Val 2) (Mul (Val 3) (Val 4)))
-- 14
evalExpr :: Expr -> Int
evalExpr (Val n)     = n
evalExpr (Add e1 e2) = evalExpr e1 + evalExpr e2
evalExpr (Mul e1 e2) = evalExpr e1 * evalExpr e2

-- =====================
-- PART 2: Functor
-- =====================

data AnnShape a
  = ACircle a Int
  | ARect a Int Int
  deriving (Eq, Show)

instance Functor AnnShape where
  fmap f (ACircle a r)   = ACircle (f a) r
  fmap f (ARect a w h)   = ARect (f a) w h

-- =====================
-- PART 3: Applicative Validation
-- =====================

data Validation e a
  = Failure e
  | Success a
  deriving (Eq, Show)

instance Functor (Validation e) where
  fmap _ (Failure e) = Failure e
  fmap f (Success a) = Success (f a)

instance Monoid e => Applicative (Validation e) where
  pure = Success
  Failure e1 <*> Failure e2 = Failure (e1 <> e2)
  Failure e1 <*> Success _  = Failure e1
  Success _  <*> Failure e2 = Failure e2
  Success f  <*> Success a  = Success (f a)

-- | >>> validateExpr (Val 5)
-- Success 5
validateExpr :: Expr -> Validation [String] Int
validateExpr e =
  let v = evalExpr e 
  in if v > 0 
     then Success v 
     else Failure ["Value must be positive, but got " ++ show v]

validateShape :: Shape -> Validation [String] Shape
validateShape (Circle r) = (\_ -> Circle r) <$> validateExpr r
validateShape (Rect w h) = (\_ _ -> Rect w h) <$> validateExpr w <*> validateExpr h

-- =====================
-- PART 4: Monad Execution
-- =====================

type Exec a = Point -> Either String (a, Point, Scene)

runCmd :: Cmd -> Exec ()
runCmd (Move x y) pt = Right ((), (evalExpr x, evalExpr y), [])
runCmd (Draw s) pt = 
  case validateShape s of
    Success _    -> Right ((), pt, [(s, pt)])
    Failure errs -> Left (unlines errs)

-- | >>> runProgram [Draw (Circle (Val 5))]
-- Right [(Circle (Val 5),(0,0))]
runProgram :: Program -> Either String Scene
runProgram cmds = go cmds (0,0) []
  where
    go [] _ accScene = Right accScene
    go (c:cs) pt accScene = 
      case runCmd c pt of
        Left err -> Left err
        Right ((), newPt, newScene) -> go cs newPt (accScene ++ newScene)

-- =====================
-- PART 5: Monoid Logging
-- =====================

newtype Log = Log [String]
  deriving (Eq, Show)

instance Semigroup Log where
  Log l1 <> Log l2 = Log (l1 ++ l2)

instance Monoid Log where
  mempty = Log []

-- =====================
-- PART 6: Optimization
-- =====================

optimizeExpr :: Expr -> Expr
optimizeExpr = Val . evalExpr

optimizeCmd :: Cmd -> Cmd
optimizeCmd (Draw (Circle r)) = Draw (Circle (optimizeExpr r))
optimizeCmd (Draw (Rect w h)) = Draw (Rect (optimizeExpr w) (optimizeExpr h))
optimizeCmd (Move x y) = Move (optimizeExpr x) (optimizeExpr y)

optimizeProg :: Program -> Program
optimizeProg = map optimizeCmd

-- =====================
-- SAMPLE PROGRAM
-- =====================

example :: Program
example =
  [ Draw (Circle (Val 5))
  ,
 Move (Val 10) (Val 20)
  ,
 Draw (Rect (Val 4) (Val 6))
  ]
