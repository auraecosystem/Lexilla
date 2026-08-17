% Nodes & Edges
node(1..4).
edge(1,2; 2,3; 3,4; 4,1).
color(red; green; blue).

% Generator: Each node gets exactly one color
1 { color_of(X, C) : color(C) } 1 :- node(X).

% Constraint: Neighboring nodes cannot share a color
:- edge(X, Y), color_of(X, C), color_of(Y, C).

% Output Display Filter
#show color_of/2.
