-- ---------------------------------------------
--  Schedule.lua   2014/03/16
--   Copyright (c) 2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

require("Task")
util = require("util")

Schedule = Object:new()

function Schedule.new(self)
  local obj = Object.new(self)
  obj.last = 0
  obj.sequenceNo = 0
  obj.pause = false
  obj.stopped = false
  obj.tasks = {}
  return obj
end

function Schedule.addTask(self, name)
  self.sequenceNo = self.sequenceNo + 1
  local task = Task:new(name, self.sequenceNo)
  local n = self:getEmptyTask()
  if n then
    self.tasks[n] = task
  else
    table.insert(self.tasks, task) -- no empty slot
  end
  return task
end

function Schedule.delTask(self, task)
  for i=1, #self.tasks do
    if self.tasks[i] == task then
      self.tasks[i] = 0
    end
  end
end

function Schedule.getEmptyTask(self)
  for i=1, #self.tasks do
    if self.tasks[i] == 0 then return i end
  end
  return nil -- no empty slot
end

function Schedule.getNoOfTasks(self)
  return #self.tasks
end

function Schedule.getTask(self, n)
  if (n > 0) and (n <= #self.tasks) then
    return self.tasks[i]
  else
    return nil
  end
end

function Schedule.getTaskByName(self, name)
  for i = 1, #self.tasks do
    if self.tasks[i] ~= 0 then
      if (self.tasks[i]:getName() == name) then
        return self.tasks[i]
      end
    end
  end
  return nil
end

function Schedule.pause(self)
  self.pause = true
end

function Schedule.start(self)
  self:startFromTo(1, -1)
end

function Schedule.startFrom(self, start_ip)
  self:startFromTo(start_ip, -1)
end

function Schedule.startFromTo(self, start_ip, stop_ip)
  self.stopped = false
  self.pause = false
  for i = 1, #self.tasks do
    if self.tasks[i] ~= 0 then
      self.tasks[i]:startFromTo(start_ip, stop_ip)
    end
  end
end

function Schedule.doCommandFps(self, frame_per_sec)
  local ip = -1
  local delta_msec = 1000 / frame_per_sec -- msec
  for i = 1, #self.tasks do
    if self.tasks[i] ~= 0 then
      ip = self.tasks[i]:execute(delta_msec)
    end
  end
  return ip
end

function Schedule.doCommand(self)
  local ip
  local running_ip = -1
  if self.stopped or self.pause then
    self.last = util.now()
    return -1
  end
  if self.last == 0 then
    self.last = util.now()
  end
  local new =  util.now()
  local delta_msec = (new - self.last) * 1000
  self.last = new
  if not self.stopped then
    for i = 1, #self.tasks do
      if self.tasks[i] ~= 0 then
        ip = self.tasks[i]:execute(delta_msec)
        if ip > 0 then running_ip = ip end
      end
    end
  end
  if running_ip < 0 then self.stopped = true end
  return running_ip -- when stopped, return -1
end

-- rate : 0.0 - 1.0
function Schedule.doOneCommand(self, ip, rate)
  for i = 1, #self.tasks do
    if self.tasks[i] ~= 0 then
      self.tasks[i]:executeOneCommand(ip, rate)
    end
  end
end

function Schedule.directExecution(self, time, command, args, start_ip, stop_ip)
  for i = 1, #self.tasks do
    if time > 0 then
      self.stopped = false
      self.pause = false
      self.tasks[i]:insertCurrentCommand(time, command, {args[i]},
                                         start_ip, stop_ip)
    else
      self.tasks[i]:directExecution(command, {args[i]})
    end
  end
end
