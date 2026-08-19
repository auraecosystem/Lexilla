local lpeg = require("lpeg") 
lpeg.locale(lpeg) -- Populates lpeg table with character classes (alpha, space, etc.)

--------------------------------------------------------------------------------
-- 1. Exact Word Match (Anchored to End-of-String)
--------------------------------------------------------------------------------
local word_pattern = lpeg.R("az")^1 * -1

print("--- 1. Word Pattern ---")
print(word_pattern:match("hello"))   --> 6 (returns index after successful match)
print(word_pattern:match("1 hello")) --> nil

--------------------------------------------------------------------------------
-- 2. Key-Value List Parser (% rawset)
--------------------------------------------------------------------------------
local space = lpeg.space^0
local name  = lpeg.C(lpeg.alpha^1) * space
local sep   = lpeg.S(",;") * space
local pair  = name * "=" * space * name * sep^-1

-- Parses key=value pairs directly into a table using rawset folding
local kv_parser = lpeg.Ct("") * (pair % rawset)^0

print("\n--- 2. Key-Value Parsing ---")
local kv_table = kv_parser:match("a=b, c = hi; next = pi")
for key, value in pairs(kv_table) do
    print(string.format("  %s = %q", key, value))
end
--> Output:
-->   a = "b"
-->   c = "hi"
-->   next = "pi"

--------------------------------------------------------------------------------
-- 3. String Splitting Utility
--------------------------------------------------------------------------------
--- Splits a string `s` by separator `sep` and returns an array table.
-- @param s string
-- @param sep string|pattern
-- @return table
local function split(s, sep)
    sep = lpeg.P(sep)
    local elem = lpeg.C((1 - sep)^0)
    local pattern = lpeg.Ct(elem * (sep * elem)^0)
    return pattern:match(s)
end

print("\n--- 3. String Split ---")
local tokens = split("apple, banana; orange", lpeg.S(",;") * space)
for i, token in ipairs(tokens) do
    print(string.format("  [%d] %s", i, token))
end

--------------------------------------------------------------------------------
-- 4. Substring Search Anywhere (Returns Start & End Positions)
--------------------------------------------------------------------------------
local Cp = lpeg.Cp()

--- Creates a recursive grammar pattern that matches `p` anywhere in a string.
-- Returns starting index and index immediately following the match.
-- @param p string|pattern
-- @return pattern
local function anywhere(p)
    p = lpeg.P(p)
    return lpeg.P({ Cp * p * Cp + 1 * lpeg.V(1) })
end

print("\n--- 4. Search Anywhere ---")
local start_idx, end_idx = anywhere("world"):match("hello world!")
print(string.format("Start index: %d, End index: %d", start_idx, end_idx))
--> Start index: 7, End index: 12
