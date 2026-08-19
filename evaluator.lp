local lpeg = require("lpeg") 

-- Lexical Definitions
local Space    = lpeg.S(" \n\t")^0
local Number   = (lpeg.P("-")^-1 * lpeg.R("09")^1 * (lpeg.P(".") * lpeg.R("09")^1)^-1) * Space
local TermOp   = lpeg.C(lpeg.S("+-")) * Space
local FactorOp = lpeg.C(lpeg.S("*/")) * Space
local Open     = "(" * Space
local Close    = ")" * Space

-- Fold Combinator Function
local function fold_op(acc, op, val)
    if     op == "+" then return acc + val
    elseif op == "-" then return acc - val
    elseif op == "*" then return acc * val
    elseif op == "/" then return acc / val
    end
end

-- Grammar Construction
local V = lpeg.V

local fold_grammar = Space * lpeg.P({
    "Exp",
    Exp    = V("Term") * (TermOp * V("Term") % fold_op)^0,
    Term   = V("Factor") * (FactorOp * V("Factor") % fold_op)^0,
    Factor = Number / tonumber + Open * V("Exp") * Close,
}) * -1

local function eval_direct(expr)
    local result = fold_grammar:match(expr)
    if result == nil then error("Syntax error in expression", 2) end
    return result
end

print(eval_direct("3 + 5*9 / (1+1) - 12")) --> 13.5
