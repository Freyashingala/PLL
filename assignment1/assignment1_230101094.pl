% Task 1
flatten([], []).    % Base case

% Recurssion, if Head is a list
flatten([H|T], FlatList) :- is_list(H), % check if head is a list
     !, % don't backtrack from here as this rule is only for if head is a list
     flatten(H, FlatH), % if yes, flatten head list
     flatten(T, FlatT), % flatten the tail list after head
     append(FlatH, FlatT, FlatList). % join the flattened lists together

flatten([H|T], [H|FlatT]) :- flatten(T, FlatT). % if head is not a list then just flatten the tail part


% Task 2

% the facts
means(0, zero).
means(1, one).
means(2, two).
means(3, three).
means(4, four).
means(5, five).
means(6, six).
means(7, seven).
means(8, eight).
means(9, nine).

translate([], []).  % base case

translate([Num|TailNum], [Word|TailWord]) :- means(Num, Word), translate(TailNum, TailWord).   % first look up the current word, and then recursively look through the list for the other elements


% Task 3
% the numbers represent the priority order so 
:- op(903, xfx, was).   % "was" has the lowest priority
:- op(902, xfy, of).   % "of" has the middle priority
:- op(901, fx, the).   % "the" has the highest priority

joe was the head of the department. % the fact


% Task 4
subsum([], 0, []).  % base case (sum is 0 in empty list)
subsum([H|T], Sum, [H|Part]) :- subsum(T, RestSum, Part), Sum is RestSum + H.   % including the head in the subsum solution, recursively go ahead and check if the rest of the sum matches the sublist
subsum([_|T], Sum, Part) :- subsum(T, Sum, Part). % not including the head in the subsum


% Task 5
my_between(Low, High, Low) :- Low =< High.   % base case (lower bound as the answer)
my_between(Low, High, X) :- Low < High, Next is Low + 1, my_between(Next, High, X).  % ensure not passing the limit, and keep moving to the next number, and recursively next to high