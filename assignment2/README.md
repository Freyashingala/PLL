# Assignment 2

* **Name:** Freya Mitulbhai Shingala
* **Roll no.:** 230101094

## How to run?
1. Run the command "swipl assignment2_230101094.pl" in terminal
2. That will start the program in which you can put any query you like.


## Assumptions
### Task 1
---
1. **Numerical Data**: It is assumed that the input list contains only numbers. 
2. **Zero as Positive**: $0$ is treated as a positive number.

### Task 2
---
1. **Bi-directional Travel**: If a direct train exists from town A to town B, the reverse journey (B to A) is also valid.

2. **Simple Paths**: By using negation as failure, we assume the user only wants simple paths (the train cannot visit the same town twice in a single route).

3. **Ordering**: The route list should be returned in chronological order (Start to End).

### Task 3
---
1. **Default Parentage**: Everybody else in has exactly 2 parents, regardless of whether they are defined in the database or not.

## Sample Queries
### Task 1
---
Split:
~~~
     ?- split([3,-1,0,5,-2],[3,0,5],[ -1,-2]).
     true .

     ?- split([3,-1,0,5,-2],X,Y).
     X = [3, 0, 5],
     Y = [-1, -2] ;
     false.

     ?- split([3,-1,0,5,-2],X,[-1,-2]).
     X = [3, 0, 5] ;
     false.
~~~
Split-cut:
~~~
     ?- split_cut([3,-1,0,5,-2],[3,0,5],[ -1,-2]).
     true.

     ?- split_cut([3,-1,0,5,-2],X,Y).
     X = [3, 0, 5],
     Y = [-1, -2].

     ?- split_cut([3,-1,0,5,-2],X,[-1,-2]).
     X = [3, 0, 5].
~~~
### Task 2:
---
~~~
     ?- route(aizawl, guwahati, R).
     R = [aizawl, agartala, silchar, haflong, lumding, nagaon, guwahati] ;
     false.

     ?- route(silchar, guwahati, R).
     R = [silchar, haflong, lumding, nagaon, guwahati] ;
     false.

     ?- route(tezpur, tezpur, R).
     R = [tezpur] ;
     false.
~~~
### Task 3:
---
~~~
     ?- number_of_parents(adam,2).
     false.

     ?- number_of_parents(eve,2).
     false.

     ?- number_of_parents(adam,X).
     X = 0.

     ?- number_of_parents(ab,X).
     X = 2.
~~~

## AI/LLM Declaration
* Tool name: Gemini
* Used it for: Generating queries to test edge cases.
* Verifying correctness: I put those queries to test on my program to test is the answers were correct.