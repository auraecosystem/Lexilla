% Save as lpeg_input.lp and run: clingo lpeg_input.lp

#script (lua)
local lpeg = require("lpeg")

function main(prg)
    -- Raw string input (e.g., CSV/custom format)
    local raw_data = "node_a-node_b, node_b-node_c, node_c-node_d"

    -- LPeg Grammar to extract edge pairs
    lpeg.locale(lpeg)
    local name = lpeg.C((lpeg.alnum + lpeg.S("_"))^1)
    local pair = lpeg.Ct(name * "-" * name)
    local sep  = lpeg.S(", ") * lpeg.space^0
    local parser = lpeg.Ct(pair * (sep * pair)^0)

    local edges = parser:match(raw_data)

    -- Inject parsed LPeg captures into Clingo as facts: edge("X", "Y").
    for _, e in ipairs(edges) do
        local fact_str = string.format("edge(%q, %q).", e[1], e[2])
        prg:add("base", {}, fact_str)
    end

    -- Ground and Solve
    prg:ground({{"base", {}}})
    prg:solve()
end
#end.

% ASP Logic Rule: Compute reachability from dynamically parsed edges
reachable(X, Y) :- edge(X, Y).
reachable(X, Z) :- edge(X, Y), reachable(Y, Z).

#show reachable/2.
