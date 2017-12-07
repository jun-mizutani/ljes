-- ---------------------------------------------
-- joystick.lua    2014/09/16
--   Copyright (c) 2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

local ffi = require("ffi")
local bit = require("bit")

local bnot, bor, band = bit.bnot, bit.bor, bit.band

ffi.cdef[[
  struct js_event {
    unsigned int time;  /* event timestamp in milliseconds */
    short value;        /* value */
    char  type;         /* event type */
    char  number;       /* axis/button number */
  };

  static const int F_SETFL = 4;

  int ioctl(int, unsigned long, ...);
  int open(const char* filename, int flags);
  int read(int fd, void *buf, unsigned int nbytes);
  int fcntl(int fd, int cmd, ...);
  int close(int fd);
]]

local joystick = {
  JS_EVENT_BUTTON = 0x1,
  JS_EVENT_AXIS   = 0x2,
  JS_EVENT_INIT   = 0x80,
  JSIOCGVERSION   = 0x80046a01,
  JSIOCGAXES      = 0x80016a11,
  JSIOCGBUTTONS   = 0x80016a12,
  JSIOCGNAME      = 0x80006a13,
  JSIOCSCORR      = 0x40246a21,
  JSIOCGCORR      = 0x80246a22,
  JSIOCSAXMAP     = 0x40406a31,
  JSIOCGAXMAP     = 0x80406a32,
  JSIOCSBTNMAP    = 0x44006a33,
  JSIOCGBTNMAP    = 0x84006a34,
  JS_CORR_NONE    = 0x0,
  JS_CORR_BROKEN  = 0x1,
  JS_RETURN       = 0xc,
  JS_TRUE         = 0x1,
  JS_FALSE        = 0x0,
  JS_X_0          = 0x1,
  JS_Y_0          = 0x2,
  JS_X_1          = 0x4,
  JS_Y_1          = 0x8,
  JS_MAX          = 0x2,
  JS_DEF_TIMEOUT  = 0x1300,
  JS_DEF_CORR     = 0x0,
  JS_DEF_TIMELIMIT= 0xa,
  JS_SET_CAL      = 0x1,
  JS_GET_CAL      = 0x2,
  JS_SET_TIMEOUT  = 0x3,
  JS_GET_TIMEOUT  = 0x4,
  JS_SET_TIMELIMIT= 0x5,
  JS_GET_TIMELIMIT= 0x6,
  JS_GET_ALL      = 0x7,
  JS_SET_ALL      = 0x8,

  BUTTON_T        = 0,
  AXIS_T          = 1,
  A_BTN           = 1,
  B_BTN           = 2,
  X_BTN           = 3,
  Y_BTN           = 4,
  L_BTM           = 5,
  R_BTN           = 6,
  SELECT          = 7,
  START           = 8,
  LEFT            = -16,
  RIGHT           = 16,
  UP              = -32,
  DOWN            = 32,
  initialized     = false
}

joystick.devices = {}

function joystick.openBlockingMode(device)
  local O_RDONLY   = 0
  local fd = ffi.C.open(device, O_RDONLY)
  return fd
end

function joystick.open(device)
  local O_RDONLY   = 0
  local O_NONBLOCK = 0x800
  local fd = ffi.C.open(device, O_RDONLY + O_NONBLOCK)
  return fd
end

function joystick.openJoystick(n, mode)
  if (n >= 0) and (n <=7) then
    local m = n + 1
    local fd = joystick.open("/dev/input/js" .. tonumber(n))
    if fd >= 0 then
      local device = {}
      device.num = n
      device.fd = fd
      table.insert(joystick.devices, device)
      return fd
    else
      return -1
    end
  else
    return -1
  end
end

function joystick.setDeviceInfo()
  local version = ffi.new("int[1]")
  local axes = ffi.new("unsigned char[1]")
  local buttons = ffi.new("unsigned char[1]")
  local name = ffi.new("char[128]")
  for i = 1, #joystick.devices do
    local fd = joystick.devices[i].fd
    ffi.C.ioctl(fd, joystick.JSIOCGVERSION, version)
    ffi.C.ioctl(fd, joystick.JSIOCGAXES, axes)
    ffi.C.ioctl(fd, joystick.JSIOCGBUTTONS, buttons)
    ffi.C.ioctl(fd, joystick.JSIOCGNAME + 128 * 0x10000, name)
    joystick.devices[i].version = version[0]
    joystick.devices[i].num_axes = axes[0]
    joystick.devices[i].num_buttons = buttons[0]
    joystick.devices[i].name = ffi.string(name)
    joystick.devices[i].axes = {}
    joystick.devices[i].buttons = {}
    for j = 1, axes[0] do
      table.insert(joystick.devices[i].axes,
                   {type = 0, number = 0, value = 0, time = 0})
    end
    for j = 1, buttons[0] do
      table.insert(joystick.devices[i].buttons,
                   {type = 0, number = 0, value = 0, time = 0})
    end
  end
end

function joystick.init()
  for i = 0, 7 do
    joystick.openJoystick(i)
  end
  if #joystick.devices > 0 then
    joystick.setDeviceInfo()
    joystick.initialized = true
  end
  return #joystick.devices
end

function joystick.readOneEvent(device)
  if (device < 1) or (device > #joystick.devices) then
    return nil -- invalid device
  end
  local fd = joystick.devices[device].fd
  local js = ffi.new("struct js_event[1]")
  local size = ffi.sizeof(js)
  local res = ffi.C.read(fd, js, size)
  if res == size then
    local event = js[0]
    event.type = band(event.type, bnot(joystick.JS_EVENT_INIT))
    return event
  else
    return nil
  end
end

function joystick.readAllEvents(device)
  local event_list = {}
  local event = joystick.readOneEvent(device)
  while (event ~= nil) do
    table.insert(event_list, event)
    event = joystick.readOneEvent(device)
  end
  if #event_list == 0 then return 0 end
  for j = 1, #event_list do
    local js = event_list[j]
    local num = js.number + 1
    if js.type == joystick.JS_EVENT_BUTTON then
      joystick.devices[device].buttons[num].value = js.value
      joystick.devices[device].buttons[num].time = js.time
    elseif js.type == joystick.JS_EVENT_AXIS then
      joystick.devices[device].axes[num].value = js.value
      joystick.devices[device].axes[num].time = js.time
    end
  end
  return #event_list
end

function joystick.readAllDevices()
  -- for every device
  for i = 1, #joystick.devices do
    joystick.readAllEvents(i)
  end
end

function joystick.getNoOfDevices()
  return #joystick.devices
end

function joystick.getName(device_num)
  return joystick.devices[device_num].name
end

function joystick.getVersion(device_num)
  return joystick.devices[device_num].version
end

function joystick.getNoOfAxes(device_num)
  return joystick.devices[device_num].num_axes
end

function joystick.getNoOfButtons(device_num)
  return joystick.devices[device_num].num_buttons
end

-- return the button value
-- device_num: 1..8, button_num: 1..n
function joystick.getButton(device_num, button_num)
  return joystick.devices[device_num].buttons[button_num].value
end

-- return the time at button-value-change
-- device_num: 1..8, button_num: 1..n
function joystick.getButtonTime(device_num, button_num)
  return joystick.devices[device_num].buttons[button_num].time
end

-- return the axis value
-- device_num: 1..8, axis_num: 1..m
function joystick.getAxis(device_num, axis_num)
  return joystick.devices[device_num].axes[axis_num].value
end

-- return the time at axis-value-change
-- device_num: 1..8, axis_num: 1..m
function joystick.getAxisTime(device_num, axis_num)
  return joystick.devices[device_num].axes[axis_num].time
end

-- return the current bit pattern
-- device_num: 1..8
function joystick.getPattern(device_num)
  local btn_pattern = 0
  local axis_pattern = 0
  local device = joystick.devices[device_num]
  for I=1, device.num_buttons do
    if device.buttons[i].value > 0 then
      btn_pattern = bor(btn_pattern, bshl(1, I))
    end
  end
  for I=1, device.num_axes do
    if device.axes[i].value > 10000 then
      axis_pattern = bor(axis_pattern, bshl(1, I*2))
    elseif device.axes[i].value < -10000 then
      axis_pattern = bor(axis_pattern, bshl(2, I*2))
    end
  end
  return btn_pattern, axis_pattern
end

-- return the current bit pattern
-- device_num: 1..8
function joystick.checkPattern(device_num, type, pattern)
  local btn, axis = joystick.getPattern(device_num)
  if type == joystick.BUTTON_T then
    if btn == pattern then
      return true
    else
      return false
    end
  elseif type == joystick.AXIS_T then
    if axis == pattern then
      return true
    else
      return false
    end
  end
  return false
end

return joystick
