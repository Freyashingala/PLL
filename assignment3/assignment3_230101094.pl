:- use_module(library(clpfd)).

% index represents column and value represents row
n_queens(N, Qs) :- 
    length(Qs, N),  % list Qs with length N
    Qs ins 1..N,    % should be between 1 and N
    safe_queens(Qs).    % applying constraints

% base case
safe_queens([]).

% recursive step
safe_queens([Q|Qs]) :-
    safe_queens_(Qs, Q, 1), % check if Q attacks any other queens
    safe_queens(Qs).

% helper function to check diagonal and row attacks, D0 shows how far the queen that we are checking is from the current queen
safe_queens_([], _, _). % base case

% recursive step
safe_queens_([Q|Qs], Q0, D0) :-
    Q #\= Q0,   % both queens can't be in the same row ( #\= means Q and Q0 will never be equal, works even if values are not assigned yet)
    abs(Q0 - Q) #\= D0, % if same diagonal, difference between their rows and columns would be same
    D #= D0 + 1,    % increment distance +1
    safe_queens_(Qs, Q0, D).


% Approach 1 : creaating the whole board with random numbers and then checking if its valid
generate_and_test(N, Qs) :-
    length(Qs, N),
    maplist(between(1,N), Qs),  % assign number 1-N to every queen in the list
    n_queens(N, Qs).    % check if it's valid


% Approach 2 : set the constraints first and then assign values
early_pruning(N, Qs) :-
    n_queens(N, Qs),
    maplist(between(1,N), Qs).

% Approach 3 : set the constraints furst and then use labeling with the first fail strategy ( look into column with the least amount of valid points - if no placement of queen possible then the arrangement is invalid)
intelligent_search(N, Qs) :-
    n_queens(N, Qs),
    labeling([ff], Qs).