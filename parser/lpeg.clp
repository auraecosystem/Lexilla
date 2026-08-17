local lpeg = require("lpeg")

-- Lexical Definitions
local Space    = lpeg.S(" \n\t")^0
local Number   = lpeg.C(lpeg.P("-")^-1 * lpeg.R("09")^1 * (lpeg.P(".") * lpeg.R("09")^1)^-1) * Space
local TermOp   = lpeg.C(lpeg.S("+-")) * Space
local FactorOp = lpeg.C(lpeg.S("*/")) * Space
local Open     = "(" * Space
local Close    = ")" * Space

-- Grammar Construction
local Exp, Term, Factor = lpeg.V("Exp"), lpeg.V("Term"), lpeg.V("Factor")

local ast_grammar = Space * lpeg.P({
    "Exp",
    Exp    = lpeg.Ct(Term * (TermOp * Term)^0),
    Term   = lpeg.Ct(Factor * (FactorOp * Factor)^0),
    Factor = Number + Open * Exp * Close,
}) * -1

-- AST Evaluator
local function eval_ast(node)
    if type(node) == "string" then
        return tonumber(node)
    end
    
    local acc = eval_ast(node[1])
    for i = 2, #node, 2 do
        local op  = node[i]
        local val = eval_ast(node[i + 1])
        if     op == "+" then acc = acc + val
        elseif op == "-" then acc = acc - val
        elseif op == "*" then acc = acc * val
        elseif op == "/" then acc = acc / val
        end
    end
    return acc
end

local function parse_and_eval_ast(expr)
    local ast = ast_grammar:match(expr)
    if not ast then error("Syntax error in expression", 2) end
    return eval_ast(ast)
end

print(parse_and_eval_ast("3 + 5*9 / (1+1) - 12")) --> 13.5
