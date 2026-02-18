% Task 1
% Split
split([], [], []). % Base case

split([H|T], [H|Pos], Neg) :- H >= 0, split(T, Pos, Neg). % Head is positive

% Head is negative
split([H|T], Pos, [H|Neg]) :-
    H < 0,
    split(T, Pos, Neg).

% Split-cut
split_cut([], [], []).

split_cut([H|T], [H|Pos], Neg) :-
    H >= 0, !, % If H >= 0, don't check the next rule
    split_cut(T, Pos, Neg).

split_cut([H|T], Pos, [H|Neg]) :-
    split_cut(T, Pos, Neg).

% Task 2
% Facts
directTrain(guwahati, tezpur).
directTrain(nagaon, guwahati).
directTrain(lumding, nagaon).
directTrain(haflong, lumding).
directTrain(silchar, haflong).
directTrain(agartala, silchar).
directTrain(aizawl, agartala).

% Trains run both ways
connection(X, Y) :- directTrain(X, Y).
connection(X, Y) :- directTrain(Y, X).

my_member(X, [X|_]).
my_member(X, [_|L]) :- my_member(X, L).

my_append([], L, L).
my_append([X|L1], L2, [X|L3]) :- my_append(L1, L2, L3).

route(Start, End, Path) :-
    find_route(Start, End, [Start], Path).

% Base case: destination reached
find_route(End, End, Visited, Visited).

% Recurssion: using negation as failure to check visited cities.
find_route(Current, End, Visited, Path) :-
    connection(Current, Next),
    \+ my_member(Next, Visited), % \+: don't revisit towns
    my_append(Visited, [Next], NewVisited),
    find_route(Next, End, NewVisited, Path).

% Task 3
% In the original version, if we checked whether number_of_parents(adam, 2), this would return true as the first condition number_of_parents(adam, 0) would be false so it would move forward and check the second condition which would be true as it is number_of_parents(X, 2)

number_of_parents(adam, 0) :- !.
number_of_parents(eve, 0) :- !.

% We only allow this rule if X is not adam and not eve.
number_of_parents(X, 2) :-
    \+ X = adam,
    \+ X = eve.