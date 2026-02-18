# Assignment 3

* **Name:** Freya Mitulbhai Shingala
* **Roll no.:** 230101094

## How to run?
1. Run the command "swipl assignment3_230101094.pl" in terminal
2. That will start the program in which you can put any query you like.


## Assumptions
1. **Symmetric Diagnal**: It is assumed that if queen A attacks queen B, then queen B would also attack queen A, so only 1 side is checked, i.e diagonal attacks are symmetric.
2. **No solution**: when there are no solutions (N=2 or N=3), the program will just output false.
3. **Only Queens**: No other pieces exist on the board except queens.

## Sample Queries
### generate_and_test
~~~
     ?- generate_and_test(3, Qs).
     false.

     ?- generate_and_test(5, Qs).
     Qs = [1, 3, 5, 2, 4] ;
     Qs = [1, 4, 2, 5, 3] ;
     Qs = [2, 4, 1, 3, 5] ;
     Qs = [2, 5, 3, 1, 4] ;
     Qs = [3, 1, 4, 2, 5] ;
     Qs = [3, 5, 2, 4, 1] ;
     Qs = [4, 1, 3, 5, 2] ;
     Qs = [4, 2, 5, 3, 1] ;
     Qs = [5, 2, 4, 1, 3] ;
     Qs = [5, 3, 1, 4, 2] ;
     false.

     ?- time(generate_and_test(5, Qs)).
     % 77,795 inferences, 0.000 CPU in 0.006 seconds (0% CPU, Infinite Lips)
     Qs = [1, 3, 5, 2, 4] ;
     % 27,220 inferences, 0.000 CPU in 0.004 seconds (0% CPU, Infinite Lips)
     Qs = [1, 4, 2, 5, 3] ;
     % 149,683 inferences, 0.016 CPU in 0.012 seconds (129% CPU, 9579712 Lips)
     Qs = [2, 4, 1, 3, 5] ;
     % 67,351 inferences, 0.000 CPU in 0.007 seconds (0% CPU, Infinite Lips)
     Qs = [2, 5, 3, 1, 4] ;
     % 64,477 inferences, 0.000 CPU in 0.006 seconds (0% CPU, Infinite Lips)
     Qs = [3, 1, 4, 2, 5] ;
     % 92,603 inferences, 0.016 CPU in 0.008 seconds (194% CPU, 5926592 Lips)
     Qs = [3, 5, 2, 4, 1] ;
     % 64,477 inferences, 0.016 CPU in 0.007 seconds (233% CPU, 4126528 Lips)
     Qs = [4, 1, 3, 5, 2] ;
     % 67,351 inferences, 0.000 CPU in 0.009 seconds (0% CPU, Infinite Lips)
     Qs = [4, 2, 5, 3, 1] ;
     % 149,683 inferences, 0.016 CPU in 0.012 seconds (130% CPU, 9579712 Lips)
     Qs = [5, 2, 4, 1, 3] ;
     % 27,219 inferences, 0.000 CPU in 0.002 seconds (0% CPU, Infinite Lips)
     Qs = [5, 3, 1, 4, 2] ;
     % 76,393 inferences, 0.000 CPU in 0.006 seconds (0% CPU, Infinite Lips)
     false.
~~~

### early_pruning
---
~~~
     ?- early_pruning(3, Qs).
     false.

     ?- early_pruning(5, Qs).
     Qs = [1, 3, 5, 2, 4] ;
     Qs = [1, 4, 2, 5, 3] ;
     Qs = [2, 4, 1, 3, 5] ;
     Qs = [2, 5, 3, 1, 4] ;
     Qs = [3, 1, 4, 2, 5] ;
     Qs = [3, 5, 2, 4, 1] ;
     Qs = [4, 1, 3, 5, 2] ;
     Qs = [4, 2, 5, 3, 1] ;
     Qs = [5, 2, 4, 1, 3] ;
     Qs = [5, 3, 1, 4, 2] ;
     false.

     ?- time(early_pruning(5, Qs)).
     % 3,973 inferences, 0.000 CPU in 0.001 seconds (0% CPU, Infinite Lips)
     Qs = [1, 3, 5, 2, 4] ;
     % 711 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
     Qs = [1, 4, 2, 5, 3] ;
     % 1,780 inferences, 0.000 CPU in 0.001 seconds (0% CPU, Infinite Lips)
     Qs = [2, 4, 1, 3, 5] ;
     % 1,068 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
     Qs = [2, 5, 3, 1, 4] ;
     % 1,188 inferences, 0.000 CPU in 0.001 seconds (0% CPU, Infinite Lips)
     Qs = [3, 1, 4, 2, 5] ;
     % 720 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
     Qs = [3, 5, 2, 4, 1] ;
     % 1,202 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
     Qs = [4, 1, 3, 5, 2] ;
     % 1,048 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
     Qs = [4, 2, 5, 3, 1] ;
     % 1,767 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
     Qs = [5, 2, 4, 1, 3] ;
     % 675 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
     Qs = [5, 3, 1, 4, 2] ;
     % 21 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
     false.
~~~
### intelligent_search
---
~~~
     ?- intelligent_search(3, Qs).
     false.

     ?- intelligent_search(5, Qs).
     Qs = [1, 3, 5, 2, 4] ;
     Qs = [1, 4, 2, 5, 3] ;
     Qs = [2, 4, 1, 3, 5] ;
     Qs = [2, 5, 3, 1, 4] ;
     Qs = [3, 1, 4, 2, 5] ;
     Qs = [3, 5, 2, 4, 1] ;
     Qs = [4, 1, 3, 5, 2] ;
     Qs = [4, 2, 5, 3, 1] ;
     Qs = [5, 2, 4, 1, 3] ;
     Qs = [5, 3, 1, 4, 2].

     ?- time(intelligent_search(5, Qs)).
     % 4,116 inferences, 0.000 CPU in 0.001 seconds (0% CPU, Infinite Lips)
     Qs = [1, 3, 5, 2, 4] ;
     % 796 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
     Qs = [1, 4, 2, 5, 3] ;
     % 1,923 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
     Qs = [2, 4, 1, 3, 5] ;
     % 1,163 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
     Qs = [2, 5, 3, 1, 4] ;
     % 1,323 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
     Qs = [3, 1, 4, 2, 5] ;
     % 718 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
     Qs = [3, 5, 2, 4, 1] ;
     % 1,397 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
     Qs = [4, 1, 3, 5, 2] ;
     % 1,072 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
     Qs = [4, 2, 5, 3, 1] ;
     % 1,908 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
     Qs = [5, 2, 4, 1, 3] ;
     % 695 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
     Qs = [5, 3, 1, 4, 2].
~~~

## AI/LLM Declaration
* **Tool name:** Gemini
* **Used it for:** Finding the query to compare time of execution for different methods
* **Verifying correctness:** generate_and_test has a higher output time than early_pruning, and early_pruning has a higher output time than intelligent_search

## External sources used
The youtube video that was attached in the assignment.