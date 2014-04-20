-- ---------------------------------------------
-- Background.lua   2013/03/20
--   Copyright (c) 2013 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

--[[
  Background:new()
  Background:initShaderParameter()
  Background:setTextureUnit(tex_unit)
  Background:setColor(r, g, b)
  Background:setAspect(aspect)
  Background:setWindow(left, top, width, height)
  Background:setOrder(order)
  Background:init()
  Background:setBackground(texture)
  Background:makeShape (scale)
  Background:drawScreen()
]]

local ffi = require("ffi")
local gl  = require("gles2")

require "Shader"
require "Texture"

Background = Shader:new()

function Background.new(self)
  local obj = Shader.new(self)
  obj.aPosition = 0
  obj.aTexCoord = 0
  obj.uTexUnit  = 0
  obj.uColor    = 0
  obj.uAspect   = 0
  obj.uWindow   = 0
  obj.uOrder    = 0
  obj.color     = {1.0, 1.0, 1.0}
  obj.aspect    = 1.0
  obj.window = {0.0, 0.0, 1.0, 1.0}
  obj.order     = 0.0
  return obj
end

function Background.initShaderParameter(self)
  self:useProgram()
  local prog = self.program
  self.aPosition = gl.getAttribLocation(prog, "aPosition")
  self.aTexCoord = gl.getAttribLocation(prog, "aTexCoord")
  self.uColor = gl.getUniformLocation(prog, "uColor")
  self.uAspect = gl.getUniformLocation(prog, "uAspect")
  self.uWindow = gl.getUniformLocation(prog, "uWindow")
  self.uOrder = gl.getUniformLocation(prog, "uOrder")
  self.uTexUnit =  gl.getUniformLocation(prog, "uTexUnit")
end

Background.vShaderSrc = [[
  attribute vec3  aPosition;
  attribute vec2  aTexCoord;
  varying   vec2  vTexCoord;
  uniform   float uAspect;
  uniform   float uOrder;
  uniform   vec4  uWindow; // left, top, width, height
  void main() {
     vec3 pos;
     pos.x = aPosition.x * uWindow.z + uWindow.x - 1.0;
     pos.y = aPosition.y * uWindow.w + uWindow.y - 1.0;
     pos.z = aPosition.z - 0.00001*uOrder;
     gl_Position = vec4(pos.xyz, 1.0);
     vTexCoord.s = aTexCoord.s;
     vTexCoord.t = aTexCoord.t * uAspect;
  }
]]

Background.fShaderSrc = [[
  precision mediump float;
  varying vec2 vTexCoord;
  uniform vec3 uColor;
  uniform sampler2D uTexUnit;

  void main(void) {
    vec4 tex;
    tex = texture2D(uTexUnit, vec2(vTexCoord.s,vTexCoord.t));
    gl_FragColor = vec4(tex.xyz*uColor, tex.w);
  }
]]

function Background.setTextureUnit(self, tex_unit)
  self:useProgram()
  gl.uniform1i(self.uTexUnit, tex_unit)
end

function Background.setColor(self, r, g, b)
  self.color = {r, g, b}
end

-- aspect: 0.5 .. 8.0 (default: 1.0)
function Background.setAspect(self, aspect)
  self.aspect = aspect
end

-- 0.0 .. 1.0 (default: 0, 0, 1, 1)
function Background.setWindow(self, left, top, width, height)
  self.window = {left, top, width, height}
end

-- order: 0.0, 1.0, 2.0, ..  (default: 0.0)
function Background.setOrder(self, order)
  self.order = order
end


function Background.init(self)
  self.status = self:initShaders()
  self:initShaderParameter()
  self:useProgram()
  self:setColor(1.0, 1.0, 1.0)
  self.vbo = 0
  self:makeShape()
end

function Background.setBackground(self, texture)
  self.texture = texture
end

function Background.makeShape (self, scale)
  local vObj = ffi.new("float[?]", 20,  --         (2)        (3)
     -- position XYZ,   texcoord UV : 5 floats   1.0 +---------+
      0.0,  0.0,  0.999999, 0.0, 0.0,   -- (0)       |         |
      2.0,  0.0,  0.999999, 1.0, 0.0,   -- (1)    Y  |         |
      0.0,  2.0,  0.999999, 0.0, 1.0,   -- (2)   0.0 +---------+
      2.0,  2.0,  0.999999, 1.0, 1.0    -- (3)       0.0 -X-> 1.0
     )                                  --         (0)        (1)

  local vbo = ffi.new("uint32_t[1]")
  gl.genBuffers(1, vbo)
  self.vbo = vbo[0]
  gl.bindBuffer(gl.ARRAY_BUFFER, self.vbo)
  gl.bufferData(gl.ARRAY_BUFFER, ffi.sizeof(vObj), vObj, gl.STATIC_DRAW)
end

function Background.drawScreen(self)
  local shd = self
  self:useProgram()
  gl.uniform1f(self.uAspect, self.aspect)
  gl.uniform1f(self.uOrder,  self.order)
  gl.uniform4f(self.uWindow, unpack(self.window))
  gl.uniform3f(self.uColor, unpack(self.color))
--  gl.enable(gl.BLEND)
--  gl.blendFunc(gl.SRC_ALPHA, gl.ONE)
  gl.bindBuffer(gl.ARRAY_BUFFER, self.vbo)
  gl.enableVertexAttribArray(shd.aPosition)
  gl.enableVertexAttribArray(shd.aTexCoord)
  gl.vertexAttribPointer(shd.aPosition,3,gl.FLOAT,gl.FALSE,5*4,
        ffi.cast("const void *", 0))
  gl.vertexAttribPointer(shd.aTexCoord,2,gl.FLOAT,gl.FALSE,5*4,
        ffi.cast("const void *", 3*4))
  self.texture:active()

  gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)
--  gl.disable(gl.BLEND)
end

