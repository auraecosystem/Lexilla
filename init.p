local lpeg = require "lpeg"
 
-- matches a word followed by end-of-string
p = lpeg.R"az"^1 * -1

print(p:match("hello"))        --> 6
print(lpeg.match(p, "hello"))  --> 6
print(p:match("1 hello"))      --> nil
lpeg.locale(lpeg)   -- adds locale entries into 'lpeg' table

local space = lpeg.space^0
local name = lpeg.C(lpeg.alpha^1) * space
local sep = lpeg.S(",;") * space
local pair = name * "=" * space * name * sep^-1
local list = lpeg.Ct("") * (pair % rawset)^0
t = list:match("a=b, c = hi; next = pi")
        --> { a = "b", c = "hi", next = "pi" }
function split (s, sep)
  sep = lpeg.P(sep)
  local elem = lpeg.C((1 - sep)^0)
  local p = elem * (sep * elem)^0
  return lpeg.match(p, s)
end
function split (s, sep)
  sep = lpeg.P(sep)
  local elem = lpeg.C((1 - sep)^0)
  local p = lpeg.Ct(elem * (sep * elem)^0)   -- make a table capture
  return lpeg.match(p, s)
end
function anywhere (p)
  return lpeg.P{ p + 1 * lpeg.V(1) }
end
local Cp = lpeg.Cp()
function anywhere (p)
  return lpeg.P{ Cp * p * Cp + 1 * lpeg.V(1) }
end

print(anywhere("world"):match("hello world!"))   --> 7   12
