-- ---------------------------------------------
-- Text.lua        2013/04/10
--   Copyright (c) 2013 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

--[[
  Text:new()
  Text:init()
  Text:makeShape ()
  Text:initFont()
  Text:createCharTexture()
  Text:goTo(x, y)
  Text:saveCursor()
  Text:restoreCursor()
  Text:scrollUp()
  Text:incCursorPosition()
  Text:write(str)
  Text:writeAt(x, y, str)
  Text:clearLine(lineNo)
  Text:clearScreen()
  Text:fontTest()
  Text:setScale(scale)
  Text:drawScreen()
]]

local ffi = require("ffi")
local bit = require("bit")
local gl  = require("gles2")

require "Font"

local shl = bit.lshift
local band = bit.band

Text = Object:new(self)

function Text.new(self)
  local obj = Object.new(self)
  obj.vbo = 0
  return obj
end

Text.letters = {
  --  lower --> upper
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},              --
  {0,0,0,8,8,0,0,8,8,8,8,8,8,8,8,0},              -- !
  {0,0,0,0,0,0,0,0,0,0,10,10,20,20,20,0},         -- "
  {0,0,0,0,20,20,20,62,20,20,20,20,62,20,20,0},   -- #
  {0,0,0,8,8,28,42,42,40,28,10,10,42,28,8,0},     -- $
  {0,0,0,33,81,82,86,84,40,8,18,21,37,37,2,0},    -- %
  {0,0,0,44,50,18,18,18,42,36,6,10,10,10,4,0},    -- &
  {0,0,0,0,0,0,0,0,0,0,4,4,8,12,12,0},            -- '
  {0,0,0,16,16,8,8,4,4,4,4,4,8,8,16,0},           -- (
  {0,0,0,4,4,8,8,16,16,16,16,16,8,8,4,0},         -- )
  {0,0,0,0,0,8,73,42,28,28,42,73,8,0,0,0},        -- *
  {0,0,0,0,0,8,8,8,62,8,8,8,0,0,0,0},             -- +
  {0,0,4,8,12,12,0,0,0,0,0,0,0,0,0,0},            -- ,
  {0,0,0,0,0,0,0,0,0,30,0,0,0,0,0,0},             -- -
  {0,0,0,12,12,0,0,0,0,0,0,0,0,0,0,0},            -- .
  {0,0,0,2,2,4,4,8,8,16,16,32,32,0,0,0},          -- /
  {0,0,0,12,18,18,18,18,18,18,18,18,18,12,0,0},   -- 0
  {0,0,0,28,8,8,8,8,8,8,8,8,12,8,0,0},            -- 1
  {0,0,0,30,2,2,4,8,8,16,16,18,18,12,0,0},        -- 2
  {0,0,0,12,18,18,18,16,12,16,16,18,18,12,0,0},   -- 3
  {0,0,0,16,16,62,18,18,20,20,24,24,16,16,0,0},   -- 4
  {0,0,0,12,18,18,18,16,16,14,2,2,2,30,0,0},      -- 5
  {0,0,0,12,18,18,18,18,14,2,2,18,18,12,0,0},     -- 6
  {0,0,0,4,4,4,4,8,8,8,16,16,16,30,0,0},          -- 7
  {0,0,0,12,18,18,18,18,12,18,18,18,18,12,0,0},   -- 8
  {0,0,0,12,18,18,18,16,28,18,18,18,18,12,0,0},   -- 9
  {0,0,0,0,0,12,12,0,0,0,12,12,0,0,0,0},          -- :
  {0,0,0,0,4,8,12,0,0,0,12,12,0,0,0,0},           -- ;
  {0,0,0,16,8,8,4,4,2,4,4,8,8,16,0,0},            -- <
  {0,0,0,0,0,0,0,62,0,0,62,0,0,0,0,0},            -- =
  {0,0,0,2,4,4,8,8,16,8,8,4,4,2,0,0},             -- >
  {0,0,0,8,8,0,8,8,16,34,34,34,34,28,0,0},        -- ?
  {0,0,0,60,2,2,50,42,42,42,50,34,34,38,28,0},    -- @
  {0,0,0,34,34,34,34,34,62,34,34,34,34,20,8,0},   -- A
  {0,0,0,30,34,34,34,34,30,18,34,34,34,18,14,0},  -- B
  {0,0,0,28,34,34,34,34,2,2,2,34,34,18,12,0},     -- C
  {0,0,0,14,18,34,34,34,34,34,34,34,34,18,14,0},  -- D
  {0,0,0,62,2,2,2,2,2,30,2,2,2,2,62,0},           -- E
  {0,0,0,2,2,2,2,2,2,30,2,2,2,2,62,0},            -- F
  {0,0,0,44,50,34,34,34,58,2,2,2,34,18,12,0},     -- G
  {0,0,0,34,34,34,34,34,34,62,34,34,34,34,34,0},  -- H
  {0,0,0,28,8,8,8,8,8,8,8,8,8,8,28,0},            -- I
  {0,0,0,28,34,34,34,32,32,32,32,32,32,32,32,0},  -- J
  {0,0,0,34,34,18,18,10,6,6,10,10,18,18,34,0},    -- K
  {0,0,0,62,2,2,2,2,2,2,2,2,2,2,2,0},             -- L
  {0,0,0,34,34,34,42,42,42,54,54,54,34,34,34,0},  -- M
  {0,0,0,34,34,50,50,42,42,42,38,38,38,34,34,0},  -- N
  {0,0,0,28,34,34,34,34,34,34,34,34,34,18,12,0},  -- O
  {0,0,0,2,2,2,2,2,30,34,34,34,34,18,14,0},       -- P
  {0,0,0,44,50,18,42,42,34,34,34,34,34,18,12,0},  -- Q
  {0,0,0,34,34,34,34,18,30,34,34,34,34,18,14,0},  -- R
  {0,0,0,28,34,34,32,32,16,12,2,2,34,18,12,0},    -- S
  {0,0,0,8,8,8,8,8,8,8,8,8,8,8,62,0},             -- T
  {0,0,0,28,52,34,34,34,34,34,34,34,34,34,34,0},  -- U
  {0,0,0,8,8,8,20,20,20,20,34,34,34,34,34,0},     -- V
  {0,0,0,20,20,20,42,42,42,42,42,42,42,42,42,0},  -- W
  {0,0,0,34,34,34,20,20,8,8,20,20,34,34,34,0},    -- X
  {0,0,0,8,8,8,8,8,8,20,20,34,34,34,34,0},        -- Y
  {0,0,0,62,2,2,4,4,8,8,16,16,32,32,62,0},        -- Z
  {0,0,0,56,8,8,8,8,8,8,8,8,8,8,56,0},            -- [
  {0,0,0,0,32,32,16,16,8,8,4,4,2,2,0,0},          --
  {0,0,0,14,8,8,8,8,8,8,8,8,8,8,14,0},            -- ]
  {0,0,0,0,0,0,0,0,0,0,0,0,34,20,8,0},            -- ^
  {0,0,0,62,0,0,0,0,0,0,0,0,0,0,0,0},             -- _
  {0,0,0,0,0,0,0,0,0,0,0,16,8,24,24,0},           -- `
  {0,0,0,44,18,18,18,18,28,16,12,0,0,0,0,0},      -- a
  {0,0,0,30,34,34,34,34,34,30,2,2,2,2,2,0},       -- b
  {0,0,0,28,34,34,2,2,34,34,28,0,0,0,0,0},        -- c
  {0,0,0,60,34,34,34,34,34,60,32,32,32,32,32,0},  -- d
  {0,0,0,28,34,2,2,62,34,34,28,0,0,0,0,0},        -- e
  {0,0,0,8,8,8,8,8,8,62,8,8,8,48,0,0},            -- f
  {0,0,30,32,32,60,34,34,34,34,60,0,0,0,0,0},     -- g
  {0,0,0,34,34,34,34,34,34,30,2,2,2,2,0,0},       -- h
  {0,0,0,8,8,8,8,8,8,0,8,8,0,0,0,0},              -- i
  {0,0,6,8,8,8,8,8,8,8,0,8,8,0,0,0},              -- j
  {0,0,0,34,34,18,10,6,10,18,34,2,2,2,2,0},       -- k
  {0,0,0,16,8,8,8,8,8,8,8,8,8,8,8,0},             -- l
  {0,0,0,42,42,42,42,42,42,42,30,0,0,0,0,0},      -- m
  {0,0,0,34,34,34,34,34,34,34,30,0,0,0,0,0},      -- n
  {0,0,0,28,34,34,34,34,34,34,28,0,0,0,0,0},      -- o
  {0,0,2,2,2,30,34,34,34,34,30,0,0,0,0,0},        -- p
  {0,0,32,32,32,60,34,34,34,34,60,0,0,0,0,0},     -- q
  {0,0,0,2,2,2,2,2,6,10,50,0,0,0,0,0},            -- r
  {0,0,0,30,32,32,28,2,2,2,60,0,0,0,0,0},         -- s
  {0,0,0,48,8,8,8,8,8,8,62,8,8,0,0,0},            -- t
  {0,0,0,60,34,34,34,34,34,34,34,0,0,0,0,0},      -- u
  {0,0,0,8,8,8,20,20,34,34,34,0,0,0,0,0},         -- v
  {0,0,0,20,20,42,42,42,42,42,42,0,0,0,0,0},      -- w
  {0,0,0,34,34,20,20,8,20,34,34,0,0,0,0,0},       -- x
  {0,0,6,8,8,8,20,20,34,34,34,0,0,0,0,0},         -- y
  {0,0,0,62,2,4,8,8,16,32,62,0,0,0,0,0},          -- z
  {0,0,16,8,8,8,8,8,4,8,8,8,8,8,16,0},            -- {
  {0,0,8,8,8,8,8,8,8,8,8,8,8,8,8,0},              -- |
  {0,0,4,8,8,8,8,8,16,8,8,8,8,8,4,0},             -- }
  {0,0,0,0,0,0,0,0,0,0,0,0,34,84,8,0},            -- ~
  {0,0,42,85,42,85,42,85,42,85,42,85,42,85,42,85}
}

function Text.init(self)
  self.screen = ffi.new("uint8_t[?]", 80*25)
  self.bytes = ffi.new("uint8_t[?]", 128*128*4)
  self.shader = Font:new()
  self.shader:init()
  self:initFont()
  self:createCharTexture()
  self:makeShape()
  self:clearScreen()
end

function Text.makeShape (self)
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

function Text.initFont(self)
  local j, k, i, b, c, n
  local TEX_HEIGHT = 128
  local TEX_WIDTH  = 128
  local letters = Text.letters

  for y=0, TEX_HEIGHT-1 do
    j = math.floor(y / 16)
    k = y % 16
    -- k = 16 - y % 16
    for x=0, TEX_WIDTH-1 do
      i = math.floor(x / 8)
      b = x % 8
      if ((i+j*16) < 96) then
        c = letters[i+j*16 + 1][k + 1]
      else
        c = 0
      end
      n = (y * 128 + x) * 4
      if band(c, shl(0x01, b)) ~= 0 then
        self.bytes[n    ]=255
        self.bytes[n + 1]=255
        self.bytes[n + 2]=255
        self.bytes[n + 3]=255
      else
        self.bytes[n    ]=255
        self.bytes[n + 1]=255
        self.bytes[n + 2]=255
        self.bytes[n + 3]=0
      end
    end
  end
end

function Text.createCharTexture(self)
  local tex = ffi.new("uint32_t[1]")
  gl.genTextures(1, tex)
  self.texname = tex[0]
  gl.bindTexture(gl.TEXTURE_2D, self.texname)
  gl.pixelStorei(gl.UNPACK_ALIGNMENT, 1)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
  gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 128, 128, 0, gl.RGBA,
      gl.UNSIGNED_BYTE, self.bytes)
end

function Text.goTo(self, x, y)
  if ((x >= 0) and (x < 80)) then
    self.cursorX = x
  end
  if ((y >= 0) and (y < 25)) then
    self.cursorY = y
  end
end

function Text.saveCursor(self)
  self.cursorX2 = self.cursorX
  self.cursorY2 = self.cursorY
end

function Text.restoreCursor(self)
  self.cursorX = self.cursorX2
  self.cursorY = self.cursorY2
end

function Text.scrollUp(self)
  local i, j
  for i=0, 24 do
    for j=0, 79 do
       self.screen[i * 80 + j] = self.screen[(i+1) * 80 + j]
    end
  end
  for j=0, 79 do
    self.screen[24 * 80 + j] = 0
  end
end

function Text.incCursorPosition(self)
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

function Text.write(self, str)
  for i=1, string.len(str) do
    self.screen[self.cursorY * 80 + self.cursorX] = string.byte(str, i) - 32
    self:incCursorPosition()
  end
end

function Text.writeAt(self, x, y, str)
   self:goTo(x, y)
   self:write(str)
end

function Text.clearLine(self, lineNo)
  for j=0, 79 do
    self.screen[lineNo * 80 + j] = 0
  end
end

function Text.clearScreen(self)
  for i=0, 24 do
    self:clearLine(i)
  end
  self.cursorX = 0
  self.cursorY = 0
end

function Text.fontTest(self)
  for i=0, 24 do
    for j=0, 79 do
      self.screen[i * 80 + j] = j + i
    end
  end
end

function Text.setScale(self, scale)
  if self.shader ~= nil then
    self.shader:setScale(scale)
  end
end

function Text.drawScreen(self)
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
  gl.activeTexture(gl.TEXTURE0)
  gl.bindTexture(gl.TEXTURE_2D, self.texname)
  local scale = shd:getScale()
  if scale < 1.0 then scale = 1.0 end
  local maxRow = math.floor(25 / scale) - 1
  local maxColumn = math.floor(80 / scale) - 1
  for i=0, maxRow do
    for j=0, maxColumn do
      c = self.screen[i * 80 + j]
      if (c ~= 0) then
        shd:setChar(j, i, c)
        gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)
      end
    end
  end
  gl.disable(gl.BLEND)
end

