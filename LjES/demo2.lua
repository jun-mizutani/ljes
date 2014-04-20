-- ---------------------------------------------
-- demo2.lua       2013/04/10
--   Copyright (c) 2013 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

local util = require("util")
local termios = require("termios")

require("Phong")
require("Screen")
require("Matrix")
require("Space")
require("Shape")
require("TexText")
require("Text")

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
  projMat:makeProjectionMatrix(1, 1000, angle, aspect)
  demo.phong:setProjectionMatrix(projMat)
end

function demo.screen(width, height)
  demo.aScreen = Screen:new()
  local scr = demo.aScreen
  termios.getTermios()

  scr:init(width, height, 0, 0)

  local phong = Phong:new()
  phong:setDefaultParam("light", {0, 100, 1000, 1})
  phong:init()
  demo.phong = phong
  Shape.ClassShader(phong)
  demo.setViewAngle(53)

  demo.aText = TexText:new()
  local ok = demo.aText:init("font512.png")
  if not ok then
     print("using Text.lua")
    demo.aText = Text:new()
    demo.aText:init()
  end
  demo.aSpace = Space:new()
end

function demo.backgroundColor(r, g, b)
  demo.aScreen:setClearColor(r, g, b, 1.0)
end

function demo.getSpace()
  return demo.aSpace
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

function demo.textWrite(x, y, str)
  demo.aText.goto(x, y)
  demo.aText.write(str)
end

function demo.loop(drawFunc, fpsFlag, keyFunc)
  local text = demo.aText
  local space = demo.aSpace
  space:timerStart()
  while (globalQuit == false) and (demo.aScreen:getFrameCount() < 5000) do
    demo.checkKey(keyFunc)
    demo.aScreen:clear()

    drawFunc()

    if fpsFlag then
      text:goTo(0,0)
      local fps = space:count() / space:uptime()
      text:write("FPS : ")
      text:write(string.format("%8.4f", fps))
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
