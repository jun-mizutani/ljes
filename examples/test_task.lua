#!/usr/bin/luajit
-- ---------------------------------------------
-- test_task.lua 2014/03/30
--   Copyright (c) 2014 Jun Mizutani,
--   released under the MIT open source license.
--
-- Demonstrate Schedule and Task class. 
-- ---------------------------------------------
package.path = "../LjES/?.lua;" .. package.path

  require("Schedule")
  local util = require("util")

  -- ---------------------
  -- function
  -- ---------------------
  function fa(a)
    print("A", a)
  end

  -- ---------------------
  -- class and method
  -- ---------------------
  Class = Object:new()
  function Class.new(self)
    local obj = Object.new(self)
    obj.value = 0
    return obj
  end

  function Class.print(self, val)
    print("Class", val)
  end

  local instance = Class:new()

  -- ---------------------
  -- another function
  -- ---------------------
  local fc = function(c) print("C", c) end
  local command_list = {
    {  100, fc, { 1000 }},
    {  200, fc, { 2000 }},
    { 3000, fc, { 3000 }}
  }

  schedule = Schedule:new()
  local task = schedule:addTask("task1")
  --              time, function, param
  task:addCommand(200, fa, { 100 }) -- fa( 100 * delta_time / total_time )
  task:addCommand(200, fa, { 300 })

  task = schedule:addTask("task2")
  task:setTargetObject(instance)  -- instance:print(...) will be called.
  task:addCommand( 10, Class.print, { 100 })
  task:addCommand(  1, Class.print, { 200 })
  task:addCommand(500, Class.print, { 30 })

  task = schedule:addTask("task3")
  task:setCommand(command_list)

  print("-- start!")
  schedule:start()

  -- execute commands every 50 msec for 5sec.
  for i = 1, 100 do
    schedule:doCommand()
    util.sleep(0.05)
  end
  print("-- finished!")
