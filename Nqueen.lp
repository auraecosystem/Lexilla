#const n = 8.
row(1..n).
col(1..n).

% 1. Generator: Place exactly 1 queen in each row
1 { queen(R, C) : col(C) } 1 :- row(R).

% 2. Constraint: No two queens can share the same column
:- queen(R1, C), queen(R2, C), R1 != R2.

% 3. Constraint: No two queens can share the same diagonal
:- queen(R1, C1), queen(R2, C2), R1 < R2, R1 - C1 == R2 - C2.
:- queen(R1, C1), queen(R2, C2), R1 < R2, R1 + C1 == R2 + C2.

% Output display filter
#show queen/2.
