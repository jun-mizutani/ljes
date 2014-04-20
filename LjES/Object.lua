-- ---------------------------------------------
-- Object.lua      2013/04/04
--   Copyright (c) 2013 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

--[[
  Object:new()
  Object:getInfo()
]]

Object = {}

function Object.new(self)
  local obj = {}
  setmetatable(obj, obj)
  obj.__index = self
  return obj
end

function Object.getInfo(self)
  CheckTable(self)
end

function CheckTable(Table)
  local str = string.format("--------- %15s ---(meta)---> %s",
                              Table, getmetatable(Table))
  print(str)

  local nameList = {}
  for name, value in pairs(Table) do
    nameList[#nameList + 1] = name
  end
  table.sort(nameList)
  for i = 1, #nameList do
    print(string.format("%24s  -- %s", nameList[i], Table[nameList[i]]))
  end
  print()

  local mt = getmetatable(Table)
  if mt ~= nil then
    local next = mt.__index
    if next ~= nil then CheckTable(next) end
  end
end
