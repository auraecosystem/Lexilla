-- Save as asp_parser.lua and run: lua asp_parser.lua
local lpeg = require("lpeg")
lpeg.locale(lpeg)

-- Whitespace & Delimiters
local space = lpeg.space^0
local comma = space * lpeg.P(",") * space
local dot   = space * lpeg.P(".") * space

-- Atoms & Terms
local ident = lpeg.C(lpeg.R("az", "AZ", "09", "__")^1)
local var   = lpeg.C(lpeg.R("AZ") * (lpeg.alnum + lpeg.S("_"))^0)
local term  = var + ident + lpeg.C(lpeg.digit^1)

local args  = lpeg.Ct(term * (comma * term)^0)
local atom  = lpeg.Ct(ident * ("(" * args * ")")^-1)

-- Rule Elements
local head  = atom
local body  = lpeg.Ct(atom * (comma * atom)^0)

-- ASP Rule Grammars
local fact = (head * dot) / function(h) 
    return { type = "fact", head = h } 
end

local rule = (head * space * lpeg.P(":-") * space * body * dot) / function(h, b) 
    return { type = "rule", head = h, body = b } 
end

local constraint = (lpeg.P(":-") * space * body * dot) / function(b) 
    return { type = "constraint", body = b } 
end

-- Complete ASP Program Grammar
local asp_grammar = lpeg.Ct((rule + constraint + fact + space)^0)

--------------------------------------------------------------------------------
-- Example Usage
--------------------------------------------------------------------------------
local asp_code = [[
    node(1).
    color(red).
    reachable(Y) :- edge(1, Y).
    :- edge(X, Y), color(X, C), color(Y, C).
]]

local ast = asp_grammar:match(asp_code)

-- Pretty print AST
for i, statement in ipairs(ast) do
    print(string.format("[%d] Type: %s", i, statement.type))
end
