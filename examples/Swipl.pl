?- [parser].
true.

?- run_example.

--- Abstract Syntax Tree ---

Fact:       atom(node,[1])
Fact:       atom(color,[red])
Rule:       atom(reachable,['Y']) :- [atom(edge,[1,'Y'])]
Constraint: :- [atom(edge,['X','Y']),atom(color,['X','C']),atom(color,['Y','C'])]
true.
