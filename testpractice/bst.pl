bst_insert(Value, nil, node(nil, Value, nil)).
bst_insert(Value, node(Left, Root, Right), node(NewLeft, Root, Right)) :- Value<Root , !, bst_insert(Value, Left, NewLeft).
bst_insert(Value, node(Left, Root, Right), node(Left, Root, NewRight)) :- Value>Root, !, bst_insert(Value, Right, NewRight).
bst_insert(Value, node(Left, Value, Right), node(Left, Value, Right)).

bst_search(Value, node(_, Value, _)).
bst_search(Value, node(Left, Root, _)) :- X<Root, !, bst_search(Value, Left).
bst_search(Value, node(_, Root, Right)) :- X>Root, !, bst_search(Value, Right).

bst_inorder(nil, []).
bst_inorder(node(Left, Root, Right), Sorted) :- bst_inorder(Left, LeftList), bst_inorder(Right, RightList), append(LeftList, [Root|RightList], Sorted).