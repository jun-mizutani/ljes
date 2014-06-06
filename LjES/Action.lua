-- ---------------------------------------------
--  Node.lua        2014/03/16
--   Copyright (c) 2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

require("Object")
local util = require("util")

Action = Object:new()

function Action.new(self, anim)
  local obj = Object.new(self)
  obj.anim = anim
  obj.actions = {}
  obj.patterns = {}
  obj.pat_index = 0
  obj.verbose = false
  obj.currentAction = {}
  obj.currentPattern = {}
  return obj
end

function Action.addKeyPattern(self, name, time, from, to)
  table.insert(self.patterns, {name, time, from, to})
  return #self.patterns
end

function Action.addAction(self, name, pattern_list)
  self.actions[ name ] = pattern_list
  return #self.actions
end

function Action.setVerbose(self, true_or_false)
  self.verbose = true_or_false
end

function Action.startAction(self, action_name)
  self.currentAction = self.actions[action_name]
  self.pat_index = 1
  self.currentPattern = self.currentAction[self.pat_index]
  return self:startTimeFromTo(self.currentPattern)
end

function Action.getPattern(self)
  return unpack(self.currentPattern) -- name, time, from ,to
end

function Action.playAction(self)
  local ip = self.anim:play()
  if ip < 0 then     -- end of current pattern
    self.pat_index = self.pat_index + 1
    if self.pat_index > #self.currentAction then
      return -1      -- end of current action
    end
    self.currentPattern = self.currentAction[self.pat_index]
    return self:startTimeFromTo(self.currentPattern)
  end
  return ip
end

function Action.startTimeFromTo(self, pat)
  local name, time, from, to = unpack(self.patterns[pat])
  if self.verbose then
    util.printf("\npattern:%2d %10s %4d msec  %2d -> %2d\n",
              self.currentPattern, name, time, from, to)
  end
  self.anim:startTimeFromTo(time, from, to)
  return from * 2 - 1
end
