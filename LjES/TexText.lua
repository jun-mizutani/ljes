-- ---------------------------------------------
-- TexText.lua     2013/04/10
--   Copyright (c) 2013 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

--[[
  TexText:new()
  TexText:init(texture_file)
  TexText:makeShape ()
  TexText:goTo(x, y)
  TexText:saveCursor()
  TexText:restoreCursor()
  TexText:scrollUp()
  TexText:incCursorPosition()
  TexText:write(str)
  TexText:writeAt(x, y, str)
  TexText:clearLine(lineNo)
  TexText:clearScreen()
  TexText:fontTest()
  TexText:setScale(scale)
  TexText:drawScreen()
]]

local ffi = require("ffi")
local gl  = require("gles2")

require "Font"
require "Texture"

TexText = Object:new(self)

function TexText.new(self)
  local obj = Object.new(self)
  obj.vbo = 0
  return obj
end

function TexText.init(self, texture_file)
  self.screen = ffi.new("uint8_t[?]", 80*25)
  self.shader = Font:new()
  self.shader:init()
  self.tex = Texture:new()
  local ok = self.tex:readImageFromFile(texture_file)
  if not ok then return false end
  self:makeShape()
  self:clearScreen()
  return true
end

function TexText.makeShape (self)
  local vObj = ffi.new("float[?]", 20,
    0.0,   0.0,   0.0,  0.0,    0.0,
    0.025, 0.0,   0.0,  0.0625, 0.0,
    0.0,   0.08,  0.0,  0.0,    0.125,
    0.025, 0.08,  0.0,  0.0625, 0.125)

  local vbo = ffi.new("uint32_t[1]")
  gl.genBuffers(1, vbo)
  self.vbo = vbo[0]
  gl.bindBuffer(gl.ARRAY_BUFFER, self.vbo)
  gl.bufferData(gl.ARRAY_BUFFER, ffi.sizeof(vObj), vObj, gl.STATIC_DRAW)
end

function TexText.goTo(self, x, y)
  if ((x >= 0) and (x < 80)) then
    self.cursorX = x
  end
  if ((y >= 0) and (y < 25)) then
    self.cursorY = y
  end
end

function TexText.saveCursor(self)
  self.cursorX2 = self.cursorX
  self.cursorY2 = self.cursorY
end

function TexText.restoreCursor(self)
  self.cursorX = self.cursorX2
  self.cursorY = self.cursorY2
end

function TexText.scrollUp(self)
  local i, j
  for i=0, 24 do
    for j=0, 79 do
       self.screen[i * 80 + j] = self.screen[(i+1) * 80 + j]
    end
  end
  for j=0, 79 do
    self.screen[24 * 80 + j] = 32
  end
end

function TexText.incCursorPosition(self)
  if (self.cursorX < 79) then
    self.cursorX = self.cursorX + 1
  elseif (self.cursorY < 24) then
    self.cursorY = self.cursorY + 1
    self.cursorX = 0
  else
    self:scrollUp()
    self.cursorY = 24
    self.cursorX = 0
  end
end

function TexText.write(self, str)
  for i=1, string.len(str) do
    self.screen[self.cursorY * 80 + self.cursorX] = string.byte(str, i)
    self:incCursorPosition()
  end
end

function TexText.writeAt(self, x, y, str)
   self:goTo(x, y)
   self:write(str)
end

function TexText.clearLine(self, lineNo)
  for j=0, 79 do
    self.screen[lineNo * 80 + j] = 32
  end
end

function TexText.clearScreen(self)
  for i=0, 24 do
    self:clearLine(i)
  end
  self.cursorX = 0
  self.cursorY = 0
end

function TexText.fontTest(self)
  for i=0, 24 do
    for j=0, 79 do
      self.screen[i * 80 + j] = 32 + j + i
    end
  end
end

function TexText.setScale(self, scale)
  if self.shader ~= nil then
    self.shader:setScale(scale)
  end
end

function TexText.drawScreen(self)
  local i, j, c
  local shd = self.shader
  gl.useProgram(shd.program)
  gl.enable(gl.BLEND)
  gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
  gl.bindBuffer(gl.ARRAY_BUFFER, self.vbo)
  gl.enableVertexAttribArray(shd.aPosition)
  gl.enableVertexAttribArray(shd.aTexCoord)
  gl.vertexAttribPointer(shd.aPosition,3,gl.FLOAT,gl.FALSE,5*4,
        ffi.cast("const void *", 0))
  gl.vertexAttribPointer(shd.aTexCoord,2,gl.FLOAT,gl.FALSE,5*4,
        ffi.cast("const void *", 3*4))
  self.tex:active()
  local scale = shd:getScale()
  if scale < 1.0 then scale = 1.0 end
  local maxRow = math.floor(25 / scale) - 1
  local maxColumn = math.floor(80 / scale) - 1
  for i=0, maxRow do
    for j=0, maxColumn do
      c = self.screen[i * 80 + j]
      if (c ~= 32) then
        shd:setChar(j, i, c)
        gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)
      end
    end
  end
  gl.disable(gl.BLEND)
end

