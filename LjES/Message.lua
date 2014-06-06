-- ---------------------------------------------
-- Message.lua     2014/06/06
--   Copyright (c) 2013-2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

local ffi = require("ffi")
local gl = require("gles2")
require("Text")

Message = Text:new()

function Message.new(self)
  local obj = Text.new(self)
  obj.color = {1.0, 1.0, 1.0}
  return obj
end

function Message.init(self, font_texture_file)
  Text.init(self, font_texture_file)
  self.messages = {}
  self.last = 1
end

function Message.setMessage(self, n, x, y, text)
  self.messages[n] = {x, y, text, self.color}
  return n
end

function Message.writeMessage(self, x, y, text)
  self.last = self:setMessage(self.last, x, y, text) + 1
  return self.last
end

function Message.delMessage(self, n)
  self.messages[n] = nil
end

function Message.clearMessages(self)
  self.messages = {}
  self.last = 1
end

function Message.listMessages(self)
  for i,v in pairs(self.messages) do
    if v ~= nil then
      util.printf("%2d  x:%2d  y:%2d  r:%2f g:%2f b:%2f %s\n", i,
                  v[1], v[2], v[4][1], v[4][2], v[4][3], v[3])
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
  for i,v in ipairs(self.messages) do
    x = v[1]
    y = v[2]
    str = v[3]
    color = v[4]
    if ((x >= 0) and (x < 80)) and ((y >= 0) and (y < 25)) then
      for j=1, #str do
        c = string.byte(str, j)
        if (c ~= 32) then
          shd:setColor(unpack(color))
          shd:setChar(x+j-1, y, c)
          gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)
        end
      end
    end        -- if ((x>=0) and (x<80)) and ((y>=0) and (y<25))
  end          -- for i,v
  gl.disable(gl.BLEND)
end

