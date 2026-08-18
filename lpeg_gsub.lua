local lpeg = require("lpeg")

function gsub (s, patt, repl)
  patt = lpeg.P(patt)
  patt = lpeg.Cs((patt / repl + 1)^0)
  return lpeg.match(patt, s)
end

-- String replacement
print(gsub("hello world", "world", "Lua"))          -- "hello Lua"

-- Pattern replacement (replace digits with '#')
local digit = lpeg.R("09")^1
print(gsub("User 123 logged in from 456", digit, "#")) -- "User # logged in from #"
