-- ---------------------------------------------
-- Message.lua     2013/04/10
--   Copyright (c) 2013 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

--[[
  Message:new()
  Message:init(texture_file)
  Message:makeShape()
  Message:setScale(scale)
  Message:isExist(x, y)
  Message:setMessage(n, x, y, text)
  Message:writeMessage(x, y, text)
  Message:delMessage(n)
  Message:clearMessage()
  Message:listMessage()
  Message:drawScreen()
]]

local ffi = require("ffi")
local gl  = require("gles2")

require "Font"
require "Texture"

Message = Object:new(self)

function Message.new(self)
  local obj = Object.new(self)
  obj.vbo = 0
  obj.color = {1.0, 1.0, 1.0}
  return obj
end

function Message.init(self, texture_file)
  self.shader = Font:new()
  self.shader:init()
  self.tex = Texture:new()
  local ok = self.tex:readImageFromFile(texture_file)
  if not ok then return false end
  self:makeShape()
  self.message = {}
  self.last = 1
  return true
end

function Message.makeShape(self)
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

function Message.setScale(self, scale)
  if self.shader ~= nil then
    self.shader:setScale(scale)
  end
end

function Message.isExist(self, x, y)
  for i,v in ipairs(self.message) do
    if (x == v[1]) and (y == v[2]) then
      return i
    end
  end
  return -1
end

function Message.setMessage(self, n, x, y, text)
  self.message[n] = {x, y, text, self.color}
  return n
end

function Message.writeMessage(self, x, y, text)
  local n = self:isExist(x, y)
  if n > 0 then
    self:setMessage(n, x, y, text)
    return n
  else
    self.last = self:setMessage(self.last, x, y, text) + 1
    return self.last
  end
end

function Message.delMessage(self, n)
  self.message[n] = nil
end

function Message.clearMessage(self)
  self.message[n] = {}
  self.last = 1
end

function Message.listMessage(self)
  for i,v in pairs(self.message) do
    if v ~= nil then
      print(i, v[1], v[2], v[3])
    end
  end
end

function Message.setColor(self, r, g, b)
  self.color = {r, g, b}
end

function Message.drawScreen(self)
  local x, y, str, color, c
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
  for i,v in ipairs(self.message) do
    x = v[1]
    y = v[2]
    str = v[3]
    color = v[4]
    if ((x >= 0) and (x < 80)) and ((y >= 0) and (y < 25)) then
      for j=1, #str do
        c = string.byte(str, j)
        if (c ~= 32) then
          shd:setColor(unpack(color))
          shd:setChar(x, y, c)
          gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)
        end
      end
    end        -- if ((x>=0) and (x<80)) and ((y>=0) and (y<25))
  end          -- for i,v
  gl.disable(gl.BLEND)
end
