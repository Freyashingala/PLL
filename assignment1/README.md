Name: Freya Mitulbhai Shingala
Roll no.: 230101094

How to run?
1. Run the command "swipl assignment1_230101094.pl" in terminal
2. That will start the program in which you can put any query you like.

Assumptions:
Task 1- flatten/2
     Uses a built in predicate is_list/1 to detect sublists
     Order of elements is preserved after flattening
     ! is used to prevent unnecessary backtracking

Task 2- translate/2
     Input contains only digits 0-9
     Each number needs to have a fact associated to it

Task 3- operators
     the precedence structure: joe was (the (head of (the department)))
     "the" is the prefix(fx), "of" is the right asssosiative (xfy), "was" is non associatove (xfx).
     903 has lesser precedence than 902, and 902 has lesser precendence than 901

Task 4- subsum/3
     order of elements in the sublist is same as main list
     Used "is" to calculate the sum of individual values

Task 5- my_between/3
     Low and high are integers
     Generates numbers in ascending order
     Low and High bounds are inclusive

(Referenced to the book Programming in Prolog)