-- ---------------------------------------------
-- GamePad.lua    2014/09/16
--   Copyright (c) 2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

local joystick = require("joystick")
local util = require("util")

require("Object")

GamePad = Object:new()

GamePad.NumOfDevices = 0
GamePad.Allocated = 0
GamePad.A      = 1
GamePad.B      = 2
GamePad.X      = 3
GamePad.Y      = 4
GamePad.L      = 5
GamePad.R      = 6
GamePad.START  = 7
GamePad.SELECT = 8
GamePad.DirX   = 1
GamePad.DirY   = 2

function GamePad.new(self)
  local obj = Object.new(self)
  obj.numDevice = 0
  obj.numAxes = 0
  obj.numButtons = 0
  obj.threshold = 1000
  if not joystick.initialized then
    GamePad.NumOfDevices = joystick.init()
    GamePad.Allocated = GamePad.Allocated + 1
    if GamePad.Allocated <= GamePad.NumOfDevices then
      obj.numDevice = GamePad.Allocated
      obj.numAxes = joystick.getNoOfAxes(obj.numDevice)
      obj.numButtons = joystick.getNoOfButtons(obj.numDevice)
    end
  end
  return obj
end

function GamePad.available(self)
  if self.numDevice > 0 then
    return true
  end
  return false
end

function GamePad.getNumOfAxes(self)
  return self.numAxes
end

function GamePad.getNumOfButtons(self)
  return self.numButtons
end

function GamePad.readEvents(self)
  return joystick.readAllEvents(self.numDevice)
end

function GamePad.checkButton(self, button)
  if button <= self.numButtons then
    if joystick.devices[self.numDevice].buttons[button].value ~= 0 then
      return true
    end
  end
  return false
end

function GamePad.checkAxis(self, axis)
  local THRES = self.threshold
  if axis <= self.numAxes then
    if joystick.devices[self.numDevice].axes[axis].value > THRES then
      return 1
    elseif joystick.devices[self.numDevice].axes[axis].value < -THRES then
      return -1
    end
  end
  return 0
end

function GamePad.list()
  local num_device = joystick.getNoOfDevices()
  for i = 1, num_device do
    util.printf("Name: %s\n", joystick.getName(i))
    util.printf("Ver.: %s\n", joystick.getVersion(i))
    local num_axes = joystick.getNoOfAxes(i)
    util.printf("  No. of Axes    : %d\n", num_axes)
    local num_buttons = joystick.getNoOfButtons(i)
    util.printf("  No. of Buttons : %d\n", num_buttons)
  end
end
