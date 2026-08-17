import clingo

ASP_PROGRAM = """
#const n = 8.
row(1..n).
col(1..n).

1 { queen(R, C) : col(C) } 1 :- row(R).

:- queen(R1, C), queen(R2, C), R1 != R2.
:- queen(R1, C1), queen(R2, C2), R1 < R2, R1 - C1 == R2 - C2.
:- queen(R1, C1), queen(R2, C2), R1 < R2, R1 + C1 == R2 + C2.

#show queen/2.
"""

def render_board(model_symbols, size=8):
    grid = [["." for _ in range(size)] for _ in range(size)]
    for symbol in model_symbols:
        if symbol.name == "queen":
            r, c = symbol.arguments
            grid[r.number - 1][c.number - 1] = "Q"
            
    print("Found Solution:")
    for row in grid:
        print(" ".join(row))
    print()

def main():
    # Initialize ASP Control Object
    control = clingo.Control()
    control.add("base", [], ASP_PROGRAM)
    control.ground([("base", [])])

    # Callback executed whenever a stable model is computed
    def on_model(model):
        render_board(model.symbols(shown=True))

    # Solve logic program (limit=1 computes only the first answer set)
    solve_result = control.solve(on_model=on_model)
    
    if solve_result.satisfiable:
        print("Status: SATISFIABLE")
    else:
        print("Status: UNSATISFIABLE")

if __name__ == "__main__":
    main()
