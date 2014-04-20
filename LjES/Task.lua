-- ---------------------------------------------
--  Task.lua       2014/03/16
--   Copyright (c) 2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

require("Object")

Task = Object:new()

function Task.new(self, name, no)
  local obj = Object.new(self)
  obj.name = name
  obj.id = no
  obj.stopped = false
  obj.ip = 0
  obj.stopIP = 0
  obj.commands = {}
  obj.time = 0
  obj.remaining_time = 0
  obj.targetObj = nil
  obj.arg = {}
  obj.currentCommand = nil
  obj.targetObject = nil
  return obj
end

function Task.setTargetObject(self, target)
  self.targetObject = target
end

-- task[1]:addCommand(1000, node.rotateX, arg)
function Task.addCommand(self, time, func, arg)
  -- func({10, 10, 10})
  table.insert(self.commands, {time, func, arg})
end

function Task.setTime(self, ip, time)
  if (ip > 0) and (ip <= #self.commands) then
    self.commands[ip][1] = time
  end
end

function Task.getTime(self, ip)
  if (ip > 0) and (ip <= #self.commands) then
    return self.commands[ip][1]
  else
    return -1
  end
end

function Task.getTime(self)
  return name
end

function Task.getNoOfCommands(self)
  return #self.commands
end

-- command_table = {
--   { 100, func,  {1, 20}  },
--   { 0,   func2, {"A"} },
--   { 300, funcA, {10}     }
-- }
function Task.setCommand(self, command_table)
  self.commands = command_table
  self:start()
end

function Task.partial_arg(self, arg, total_time, dtime)
  local doarg = {}
  for i = 1, #arg do
    -- print(arg[1])
    if total_time > 0.1 then
      doarg[i] = tonumber(arg[i]) * dtime / total_time
    else
      table.insert(doarg, arg[i])
    end
  end
  return doarg
end

function Task.controlCommand(self, command, arg)
  if command == "jump" then
     -- jump to current command + arg position
     -- {0, "jump", {-1}}
     self.ip = self.ip + arg - 1
  elseif command == "quit" then
    -- quit task
    self.stopped = true
  end
end

function Task.execCommand(self, doarg)
  local command = self.currentCommand
  if type(command) == "string" then
    self:controlCommand(command, unpack(doarg))
  elseif self.targetObject == nil then
    -- call function. {0, print, {"abc"} }
    self.ret_code = command(unpack(doarg))
  else
    if command ~= nil then
      -- call method. {1000, Bone.ratateX, {90} }
      self.ret_code = command(self.targetObject, unpack(doarg))
    else
       util.printf("Error (%s:execCommand):[%3d] %s:nil(..)\n",
                   self.name, self.ip, self.targetObject.name)
    end
  end
end

function Task.getNextCommand(self)
  repeat
    self.ip = self.ip + 1
    if (self.ip <= self.stopIP) and (self.ip > 0) then
      self.time = self.commands[self.ip][1]
      self.currentCommand = self.commands[self.ip][2]
      self.arg = self.commands[self.ip][3]
      self.remaining_time = self.time
      if self.time == 0 then
        self:execCommand(self.arg)
      end
    else
      self.stopped = true  -- end of task
      self.ip = -1
    end
  until self.time > 0 or self.stopped
end

function Task.start(self)
  self:startFromTo(1, -1)
end

function Task.startFrom(self, start_ip)
  self:startFromTo(start_ip, -1)
end

function Task.startFromTo(self, start_ip, stop_ip)
  if stop_ip > #self.commands then
    stop_ip = #self.commands
  end
  if stop_ip < 0 then
    self.stopIP = #self.commands
  else
    self.stopIP = stop_ip
  end
  if (start_ip > 0) and (start_ip <= self.stopIP) then
    self.stopped = false
    -- to compensate self.ip+=1 in getNextCommand.
    self.ip = start_ip - 1
    -- getNextCommand may execute commands with time==0.
    self:getNextCommand()
  end
end

function Task.execute(self, delta_msec)
  local doarg
  if self.stopped then return -1 end
  if self.ip == 0 then self:getNextCommand() end

  if self.remaining_time > delta_msec then
    self.remaining_time = self.remaining_time - delta_msec
    doarg = self:partial_arg(self.arg, self.time, delta_msec)
    self:execCommand(doarg)
  else
    local time_next = delta_msec - self.remaining_time
    doarg = self:partial_arg(self.arg, self.time, self.remaining_time)
    self:execCommand(doarg)
    repeat
      self:getNextCommand()
      if not self.stopped then
        self.remaining_time = self.time - time_next
        if self.time > time_next then
          doarg = self:partial_arg(self.arg, self.time, time_next)
          self:execCommand(doarg)
        else -- time < time_next
          time_next = time_next - self.time
          doarg = self:partial_arg(self.arg, self.time, self.time)
          self:execCommand(doarg)
        end
      end
    until self.remaining_time > 0 or self.stopped
  end
  return self.ip
end

function Task.executeOneCommand(self, ip, arg_rate)
  local commands = self.commands
  local object = self.targetObject
  local time = commands[ip][1]
  local command = commands[ip][2]
  local arg = commands[ip][3]
  local doarg = self:partial_arg(arg, 1.0, arg_rate)
  if object == nil then
    command(unpack(doarg))
  else
    command(object, unpack(doarg))
  end
end

function Task.directExecution(self, command, doarg)
  if self.targetObject == nil then
    self.ret_code = command(unpack(doarg))
  else
    if command ~= nil then
      self.ret_code = command(self.targetObject, unpack(doarg))
    else
      util.printf("Error( %s<%d>:directExecution ):[%3d] %s:nil(..)\n",
                   self.name, self.id, self.ip, self.targetObject.name)
    end
  end
end

function Task.insertCurrentCommand(self, time, command, arg, start_ip, stop_ip)
  self.time = time
  self.currentCommand = command
  self.arg = arg
  self.remaining_time = self.time
  if (start_ip ~= nil) and (stop_ip ~= nil) then
    if stop_ip > #self.commands then
      stop_ip = #self.commands
    end
    if stop_ip < 0 then
      self.stopIP = #self.commands
    else
      self.stopIP = stop_ip
    end
    if (start_ip > 0) and (start_ip <= self.stopIP) then
      self.stopped = false
      self.ip = start_ip - 1
    end
  end
end
