local Cp = lpeg.Cp()
function anywhere (p)
  return (1 - lpeg.P(p))^0 * Cp * p * Cp
end
