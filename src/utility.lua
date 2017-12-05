--[[
Generic utility functions
--]]

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function DIV(a,b)
  return (a - a % b) / b
end
