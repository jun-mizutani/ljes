-- ---------------------------------------------
-- Object.lua      2014/02/07
--   Copyright (c) 2013-2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

Object = {}

function Object.new(self)
  local obj = {}
  setmetatable(obj, obj)
  obj.__index = self
  return obj
end

