last(H, [H]).
last(H, [_|T]) :- last(H, T).

reverse([], []).
reverse([H|T], List) :- reverse(T, Tail), append(Tail, [H], List).

istree(nil).
istree(node(Left, Root, Right)) :- istree(Left), istree(Right).

count_leaves(node(nil, Root, nil), 1).
count_leaves(node(Left, _, Right), Count) :- count_leaves(Left, LeftC), count_leaves(Right, RightC), Count is LeftC+RightC.

xinList(X, [X|_]).
xinList(X, [_|T]) :- xinList(X, T).

compress([], []).
compress([X], [X]).
compress([X,X|T], Result) :- compress([X|T], Result).
compress([X,Y|T], [X|Result]) :- X\=Y, compress([Y|T], Result).

collect_leaves(nil, []).
collect_leaves(node(nil,X,nil), [X]).
collect_leaves(node(Left, X, Right), List) :- (Left \= nil ; Right \= nil), collect_leaves(Left, LeftList), collect_leaves(Right, RightList), append(LeftList, RightList, List).