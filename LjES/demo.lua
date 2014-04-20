-- ---------------------------------------------
-- demo.lua    2014/03/30
--   Copyright (c) 2013-2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

local util = require("util")
local termios = require("termios")

require("BonePhong")
require("Screen")
require("Matrix")
require("Space")
require("Shape")
require("Text")
require("Message")

local demo = {}

globalQuit = false
demo.keyStatus = false

function demo.startCheckKey()
  termios.setRawMode()
  demo.keyStatus = true
end

function demo.endCheckKey()
  termios.restoreTermios()
  demo.keyStatus = false
end

function demo.checkKey(func)
  if (demo.keyStatus == false) then
    demo.startCheckKey()
  end
  local key = termios.realtimeKey()
  local scr = demo.aScreen
  local fw = scr.fullWidth
  local fh = scr.fullHeight
  if key ~= 0 then
    if (func ~= nil) then key = func(key) end
    if (key == 'q') then     globalQuit = true
    elseif (key == 'p') then scr:screenShot()
    elseif (key == 't') then scr:move(fw / 2, fh / 2, fw / 2, 0)
    elseif (key == 'b') then scr:move(fw / 2, fh / 2, fw / 2, fh / 2)
    elseif (key == 'g') then scr:restoreSize()
    elseif (key == 'f') then scr:move(fw, fh, 0, 0)
    end
  end
end

function demo.setViewAngle(angle)
  local aspect = demo.aScreen.width / demo.aScreen.height
  local projMat = Matrix:new()
  projMat:makeProjectionMatrix(0.1, 1000, angle, aspect)
  demo.phong:setProjectionMatrix(projMat)
end

function demo.getShapeSize(shapes)
  local size = {
    minx = 1.0E10, maxx = -1.0E10,
    miny = 1.0E10, maxy = -1.0E10,
    minz = 1.0E10, maxz = -1.0E10,
    centerx = 0.0, sizex = 0.0,
    centery = 0.0, sizey = 0.0,
    centerz = 0.0, sizez = 0.0,
  }
  for i = 1, #shapes do
    local shape = shapes[i]
    local b = shape:getBoundingBox()
    if size.minx > b.minx then size.minx = b.minx end
    if size.maxx < b.maxx then size.maxx = b.maxx end
    if size.miny > b.miny then size.miny = b.miny end
    if size.maxy < b.maxy then size.maxy = b.maxy end
    if size.minz > b.minz then size.minz = b.minz end
    if size.maxz < b.maxz then size.maxz = b.maxz end
  end
  size.centerx = (size.maxx + size.minx)/2
  size.sizex = size.maxx - size.minx
  size.centery = (size.maxy + size.miny)/2
  size.sizey = size.maxy - size.miny
  size.centerz = (size.maxz + size.minz)/2
  size.sizez = size.maxz - size.minz
  size.max = math.max(size.maxx, size.maxy, size.maxz)
  return size
end

function demo.screen(width, height)
  demo.aScreen = Screen:new()
  local scr = demo.aScreen
  termios.getTermios()

  scr:init(width, height, 0, 0)

  local phong = BonePhong:new()
  phong:setDefaultParam("light", {0, 100, 1000, 1})
  phong:init()
  demo.phong = phong
  Shape.ClassShader(phong)
  demo.setViewAngle(53)

  demo.aText = Text:new()
  demo.aText:init("font512.png")
  demo.aMessage = Message:new()
  demo.aMessage:init("font512.png")

  demo.aSpace = Space:new()
end

function demo.backgroundColor(r, g, b)
  demo.aScreen:setClearColor(r, g, b, 1.0)
end

function demo.getSpace()
  return demo.aSpace
end

function demo.printf(...)
   return util.printf(...)
end

function demo.getFrameCount()
  return demo.aScreen:getFrameCount()
end

function demo.textColor(r, g, b)
  demo.aText.shader:setColor(r, g, b)
end

function demo.textFontScale(scale)
  demo.aText.shader:setScale(scale)
end

function demo.messageColor(r, g, b)
  demo.aMessage:setColor(r, g, b)
end

function demo.messageFontScale(scale)
  demo.aMessage.shader:setScale(scale)
end

function demo.messageWrite(x, y, str)
  demo.aMessage:setMessage(1, x, y, str)
end

function demo.messageDraw()
  demo.aMessage:drawScreen()
end

function demo.loop(drawFunc, fpsFlag, keyFunc)
  local text = demo.aText
  local space = demo.aSpace
  local quit = false
  demo.aSpace:scanSkeletons()
  space:timerStart()
  while (globalQuit == false) and (quit ~= true)
         and (demo.aScreen:getFrameCount() < 50000) do
    demo.checkKey(keyFunc)
    demo.aScreen:clear()

    quit = drawFunc()
    -- Draw Bones
    demo.aScreen:clearDepthBuffer()
    demo.aSpace:drawBones()

    if fpsFlag then
      local fps = space:count() / space:uptime()
      text:writefAt(0, 0, "FPS : %8.4f", fps)
      text:drawScreen()
    end
    demo.aScreen:update()
  end
end

function demo.exit()
  util.sleep(0.05)
  if (demo.keyStatus) then
    demo.endCheckKey()
  end
  termios.restoreTermios()
  demo.aScreen:deinit()
end

return demo
