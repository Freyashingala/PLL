module Assignment_5 where

-- | A simple polymorphic Min Heap
data MinHeap a = Empty | Node a (MinHeap a) (MinHeap a)
    deriving (Show, Eq)


-- | Check whether the heap is empty.
--
-- >>> isEmpty Empty
-- True
--
-- >>> isEmpty (Node 5 Empty Empty)
-- False
--
isEmpty :: MinHeap a -> Bool
isEmpty Empty = True
isEmpty _ = False



-- | Compute the total number of elements in the heap.
--
-- >>> size Empty
-- 0
--
-- >>> size (Node 5 (Node 3 Empty Empty) Empty)
-- 2
--
-- >>> size (Node 5 (Empty) Empty)
-- 1
--
size :: MinHeap a -> Int
size Empty = 0
size (Node _ left right) = 1 + size left + size right


-- | Return the minimum element (root) of the heap.
--   Assume the heap is not empty.
--
-- >>> findMin (Node 2 Empty Empty)
-- 2
--
-- >>> findMin (Node 1 (Node 3 Empty Empty) Empty)
-- 1
--
findMin :: MinHeap a -> a
findMin (Node val _ _) = val
findMin Empty = error "empty heap"


-- | Convert the heap into a list using preorder traversal.
--
-- >>> heapToList (Node 1 (Node 2 Empty Empty) (Node 3 Empty Empty))
-- [1,2,3]
--
heapToList :: MinHeap a -> [a]
heapToList Empty = []
heapToList (Node val left right) = val : heapToList left ++ heapToList right


-- | Check whether a heap satisfies the min-heap property.
--   A node must be less than or equal to its children.
--
-- >>> isHeap (Node 1 (Node 2 Empty Empty) (Node 3 Empty Empty))
-- True
--
-- >>> isHeap (Node 5 (Node 2 Empty Empty) Empty)
-- False
--
isHeap :: Ord a => MinHeap a -> Bool
isHeap Empty = True
isHeap (Node val left right) = 
    check val left && check val right && isHeap left && isHeap right
  where
    check _ Empty = True
    check v (Node childVal _ _) = v <= childVal


-- | Helper function to merge two heaps.
merge :: Ord a => MinHeap a -> MinHeap a -> MinHeap a
merge Empty h = h
merge h Empty = h
merge h1@(Node v1 l1 r1) h2@(Node v2 l2 r2)
    | v1 <= v2  = Node v1 (merge r1 h2) l1
    | otherwise = Node v2 (merge r2 h1) l2


-- | Insert an element into the heap while maintaining heap property.
--
-- >>> insertHeap 2 (Node 5 Empty Empty)
-- Node 2 (Node 5 Empty Empty) Empty
--
insertHeap :: Ord a => a -> MinHeap a -> MinHeap a
insertHeap val heap = merge (Node val Empty Empty) heap


-- | Delete the minimum element (root) from the heap.
--
-- >>> deleteMin (Node 1 (Node 2 Empty Empty) (Node 3 Empty Empty))
-- Node 2 (Node 3 Empty Empty) Empty
--

deleteMin :: Ord a => MinHeap a -> MinHeap a
deleteMin Empty = Empty
deleteMin (Node _ left right) = merge left right


-- | Return all even elements from the heap using list comprehension.
--
-- >>> evenHeap (Node 1 (Node 2 Empty Empty) (Node 4 Empty Empty))
-- [2,4]
--
evenHeap :: MinHeap Int -> [Int]
evenHeap heap = [x | x <- heapToList heap, even x]


-- | Apply a function to every element in the heap.
--
-- >>> mapHeap (*2) (Node 1 Empty Empty)
-- Node 2 Empty Empty
--

-- >>> mapHeap (*2) (Node 1 (Node 4 Empty Empty) Empty)
-- Node 2 (Node 8 Empty Empty) Empty
--
mapHeap :: (a -> a) -> MinHeap a -> MinHeap a
mapHeap _ Empty = Empty
mapHeap f (Node val left right) = Node (f val) (mapHeap f left) (mapHeap f right)


-- | Process the heap by extracting even elements and squaring them.
--
-- >>> processHeap (Node 2 (Node 3 Empty Empty) (Node 4 Empty Empty))
-- [4,16]
--
processHeap :: MinHeap Int -> [Int]
processHeap heap = [x * x | x <- heapToList heap, even x]


-- | Interactive program:
--   Reads numbers, builds heap, and prints results
--
main :: IO ()
main = do
    putStrLn "Enter numbers separated by spaces to build a MinHeap:"
    input <- getLine
    let numbers = map read (words input) :: [Int]
        heap = foldr insertHeap Empty numbers
        
    putStrLn "\n--- Heap Analysis ---"
    putStrLn $ "Built Heap: " ++ show heap
    putStrLn $ "Heap Size: " ++ show (size heap)
    if not (isEmpty heap) 
        then putStrLn $ "Minimum Element: " ++ show (findMin heap)
        else putStrLn "Minimum Element: None (Empty Heap)"
    putStrLn $ "Is valid MinHeap? " ++ show (isHeap heap)
    putStrLn $ "Elements (Preorder): " ++ show (heapToList heap)
    putStrLn $ "Even Elements: " ++ show (evenHeap heap)
    putStrLn $ "Processed Heap (Evens Squared): " ++ show (processHeap heap)