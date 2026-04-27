sumList :: [Int] -> Int
sumList [] = 0
sumList [x] = x
sumList (x:xs) = x + sumList xs

evenList :: [Int] -> [Int]
evenList [] = []
evenList (x:xs) 
     | even x  = x : evenList xs
     | otherwise = evenList xs

lastEl :: [Int] -> Int
lastEl [x] = x
lastEl (x:xs) = lastEl xs

cons :: [Int] -> [Int]
cons [] = []
cons [x] = [x]
cons (x:x2:xs)
     | x==x2 = cons (x2:xs)
     | otherwise    = x : cons (x2:xs)

data Tree a = Empty | Node a (Tree a) (Tree a) deriving (Show, Eq)