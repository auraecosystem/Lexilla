:- module(parser, [parse_asp/2, run_example/0]).

%% parse_asp(+InputString, -AST)
%  Parses a modern ASP/Clingo program string into an Abstract Syntax Tree (AST).
parse_asp(String, AST) :-
    string_codes(String, Codes),
    phrase(asp_program(AST), Codes).

% ------------------------------------------------------------------------------
% DCG Grammar Rules
% ------------------------------------------------------------------------------

% Program: zero or more statements separated by whitespace/comments
asp_program([Stmt|Rest]) -->
    ws, statement(Stmt), !, asp_program(Rest).
asp_program([]) --> ws.

% Statements: Rules, Constraints, or Facts
statement(rule(Head, Body)) -->
    head_expr(Head), ws, ":-", ws, body_expr(Body), ws, ".".
statement(constraint(Body)) -->
    ":-", ws, body_expr(Body), ws, ".".
statement(fact(Head)) -->
    head_expr(Head), ws, ".".

% ------------------------------------------------------------------------------
% Heads & Choice Aggregates
% ------------------------------------------------------------------------------

head_expr(choice(Min, Elements, Max)) -->
    choice_bound(Min), ws, "{", ws, choice_elements(Elements), ws, "}", ws, choice_bound(Max), !.
head_expr(Atom) -->
    atom_expr(Atom).

choice_bound(Val) --> number_term(Val), !.
choice_bound(Var) --> var_ident(Var), !.
choice_bound(inf) --> [].

choice_elements([E|Rest]) -->
    choice_element(E), ws, ";", !, ws, choice_elements(Rest).
choice_elements([E|Rest]) -->
    choice_element(E), ws, ",", !, ws, choice_elements(Rest).
choice_elements([E]) -->
    choice_element(E).

% Choice Element with conditional literals (e.g., assign(X, C) : color(C))
choice_element(elem(Head, Cond)) -->
    literal_expr(Head), ws, ":", !, ws, body_expr(Cond).
choice_element(elem(Head, [])) -->
    literal_expr(Head).

% ------------------------------------------------------------------------------
% Body Expressions & Literals
% ------------------------------------------------------------------------------

body_expr([E|Rest]) -->
    body_element(E), ws, ",", !, ws, body_expr(Rest).
body_expr([E]) -->
    body_element(E).

% Body Element: Comparison or Literal
body_element(comp(Op, T1, T2)) -->
    arith_expr(T1), ws, comp_op(Op), ws, arith_expr(T2), !.
body_element(Lit) -->
    literal_expr(Lit).

% Literals (Positive or Default Negation)
literal_expr(not(Atom)) -->
    "not", ws, atom_expr(Atom), !.
literal_expr(pos(Atom)) -->
    atom_expr(Atom).

% Comparison Operators
comp_op('!=') --> "!=".
comp_op('==') --> "==".
comp_op('<=') --> "<=".
comp_op('>=') --> ">=".
comp_op('<')  --> "<".
comp_op('>')  --> ">".
comp_op('=')  --> "=".

% ------------------------------------------------------------------------------
% Atoms, Expressions & Terms
% ------------------------------------------------------------------------------

atom_expr(atom(Name, Args)) -->
    ident(Name), "(", ws, args_expr(Args), ws, ")", !.
atom_expr(atom(Name, [])) -->
    ident(Name).

args_expr([Arg|Rest]) -->
    term_expr(Arg), ws, ",", !, ws, args_expr(Rest).
args_expr([Arg]) -->
    term_expr(Arg).

% Terms & Arithmetic
term_expr(range(Low, High)) -->
    simple_term(Low), "..", simple_term(High), !.
term_expr(Expr) -->
    arith_expr(Expr).

arith_expr(binary(Op, Left, Right)) -->
    simple_term(Left), ws, arith_op(Op), ws, arith_expr(Right), !.
arith_expr(Term) -->
    simple_term(Term).

arith_op('+') --> "+".
arith_op('-') --> "-".
arith_op('*') --> "*".
arith_op('/') --> "/".

simple_term(Var)   --> var_ident(Var), !.
simple_term(Num)   --> number_term(Num), !.
simple_term(Ident) --> ident(Ident).

% ------------------------------------------------------------------------------
% Lexical Analysis & Comments
% ------------------------------------------------------------------------------

ident(Atom) -->
    [C], { code_type(C, lower) },
    ident_rest(Rest),
    { atom_codes(Atom, [C|Rest]) }.

var_ident(Var) -->
    [C], { code_type(C, upper) },
    ident_rest(Rest),
    { atom_codes(Var, [C|Rest]) }.

ident_rest([C|Rest]) -->
    [C], { code_type(C, csym) }, !,
    ident_rest(Rest).
ident_rest([]) --> [].

number_term(Num) -->
    digits(D), { D \= [], number_codes(Num, D) }.

digits([C|Rest]) -->
    [C], { code_type(C, digit) }, !,
    digits(Rest).
digits([]) --> [].

% Whitespace & Comments Engine
ws --> "%", !, skip_comment, ws.
ws --> [C], { code_type(C, space) }, !, ws.
ws --> [].

skip_comment --> [10], !.         % Line feed
skip_comment --> [13, 10], !.     % CRLF
skip_comment --> [_], !, skip_comment.
skip_comment --> [].              % End of file

% ------------------------------------------------------------------------------
% Execution Runner
% ------------------------------------------------------------------------------

run_example :-
    ASPCode = "
        % Define domain rules
        node(1..4).
        
        % Choice aggregate rule
        1 { assign(X, C) : color(C) } 1 :- node(X).
        
        % Rule with default negation
        valid(X) :- node(X), not blocked(X).
        
        % Integrity constraints with arithmetic comparisons
        :- edge(X, Y), assign(X, C), assign(Y, C).
        :- queen(R1, C1), queen(R2, C2), R1 < R2, R1 + C1 == R2 + C2.
    ",
    parse_asp(ASPCode, AST),
    format("~n--- Parsed Modern ASP AST ---~n~n", []),
    forall(member(Stmt, AST), print_ast(Stmt)).

print_ast(fact(H)) :-
    format("FACT:~n  Head: ~w~n~n", [H]).
print_ast(rule(H, B)) :-
    format("RULE:~n  Head: ~w~n  Body: ~w~n~n", [H, B]).
print_ast(constraint(B)) :-
    format("CONSTRAINT:~n  Body: ~w~n~n", [B]).
