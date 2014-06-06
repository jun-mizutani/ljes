-- ---------------------------------------------
-- Stack.lua       2013/11/09
--   Copyright (c) 2013 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

require("Object")

Stack = Object:new()

function Stack.new(self)
  local obj = Object.new(self)
  obj.stack = {}
  return obj
end

function Stack.push(self, contents)
  table.insert(self.stack, contents)
end

function Stack.pop(self)
  if #self.stack < 1 then return nil end
  return table.remove(self.stack)
end

function Stack.top(self)
  return self.stack[#self.stack]
end

function Stack.count(self)
  return #self.stack
end

