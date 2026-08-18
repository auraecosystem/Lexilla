:- module(parser, [parse_asp/2, run_example/0]).

%% parse_asp(+InputString, -AST)
%  Parses an ASP program string into an Abstract Syntax Tree (AST).
parse_asp(String, AST) :-
    string_codes(String, Codes),
    phrase(asp_program(AST), Codes).

% ------------------------------------------------------------------------------
% DCG Grammar Rules 
% ------------------------------------------------------------------------------

% Program: zero or more statements separated by whitespace
asp_program([Stmt|Rest]) -->
    ws, statement(Stmt), !, asp_program(Rest).
asp_program([]) --> ws.

% Statements: Rules, Constraints, or Facts
statement(rule(Head, Body)) -->
    atom_expr(Head), ws, ":-", ws, body_expr(Body), ws, ".".
statement(constraint(Body)) -->
    ":-", ws, body_expr(Body), ws, ".".
statement(fact(Head)) -->
    atom_expr(Head), ws, ".".

% Body: Comma-separated list of atoms
body_expr([A|Rest]) -->
    atom_expr(A), ws, ",", !, ws, body_expr(Rest).
body_expr([A]) -->
    atom_expr(A).

% Atom: predicate(arg1, arg2) or atom without arguments
atom_expr(atom(Name, Args)) -->
    ident(Name), "(", ws, args_expr(Args), ws, ")", !.
atom_expr(atom(Name, [])) -->
    ident(Name).

% Arguments: Comma-separated terms
args_expr([Arg|Rest]) -->
    term_expr(Arg), ws, ",", !, ws, args_expr(Rest).
args_expr([Arg]) -->
    term_expr(Arg).

% Terms: Variables (Upper), Numbers (Digits), or Identifiers (Lower)
term_expr(Var)   --> var_ident(Var), !.
term_expr(Num)   --> number_term(Num), !.
term_expr(Ident) --> ident(Ident).

% ------------------------------------------------------------------------------
% Lexical & Tokenizer Rules
% ------------------------------------------------------------------------------

% Identifiers (lowercase start)
ident(Atom) -->
    [C], { code_type(C, lower) },
    ident_rest(Rest),
    { atom_codes(Atom, [C|Rest]) }.

% Variables (uppercase start)
var_ident(Var) -->
    [C], { code_type(C, upper) },
    ident_rest(Rest),
    { atom_codes(Var, [C|Rest]) }.

ident_rest([C|Rest]) -->
    [C], { code_type(C, csym) }, !,
    ident_rest(Rest).
ident_rest([]) --> [].

% Numbers
number_term(Num) -->
    digits(D), { D \= [], number_codes(Num, D) }.

digits([C|Rest]) -->
    [C], { code_type(C, digit) }, !,
    digits(Rest).
digits([]) --> [].

% Whitespace
ws --> [C], { code_type(C, space) }, !, ws.
ws --> [].

% ------------------------------------------------------------------------------
% Example Usage Runner
% ------------------------------------------------------------------------------

run_example :-
    ASPCode = "
        node(1).
        color(red).
        reachable(Y) :- edge(1, Y).
        :- edge(X, Y), color(X, C), color(Y, C).
    ",
    parse_asp(ASPCode, AST),
    format("~n--- Abstract Syntax Tree ---~n~n", []),
    forall(member(Stmt, AST), print_statement(Stmt)).

print_statement(fact(Head)) :-
    format("Fact:       ~w~n", [Head]).
print_statement(rule(Head, Body)) :-
    format("Rule:       ~w :- ~w~n", [Head, Body]).
print_statement(constraint(Body)) :-
    format("Constraint: :- ~w~n", [Body]).
