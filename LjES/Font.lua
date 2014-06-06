-- ---------------------------------------------
-- Font.lua        2014/06/05
--   Copyright (c) 2013-2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

local gl  = require("gles2")

require("Shader")

Font = Shader:new()

function Font.new(self)
  local obj = Shader.new(self)
  obj.aPosition = 0
  obj.aTexCoord = 0
  obj.uTexUnit  = 0
  obj.uColor    = 0
  obj.uChar     = 0
  obj.uScale    = 0
  obj.scale     = 1.0
  return obj
end

function Font.initShaderParameter(self)
  self:useProgram()
  local prog = self.program
  self.aPosition = gl.getAttribLocation(prog, "aPosition")
  self.aTexCoord = gl.getAttribLocation(prog, "aTexCoord")
  self.uChar  = gl.getUniformLocation(prog, "uChar")
  self.uColor = gl.getUniformLocation(prog, "uColor")
  self.uScale = gl.getUniformLocation(prog, "uScale")
  self.uTexUnit =  gl.getUniformLocation(prog, "uTexUnit")
  self:setTextureUnit(0)
  self:setChar(0, 0, 0x20)
  self:setColor(1.0, 1.0, 1.0)
  self:setScale(1.0)
end

Font.vShaderSrc = [[
  attribute vec3  aPosition;
  attribute vec2  aTexCoord;
  varying   vec2  vTexCoord;
  uniform   vec3  uChar;
  uniform   float uScale;
  void main() {
    float  x, y;
    vec4 pos;
    y = floor((uChar.z + 0.5) / 16.0);
    x = uChar.z - y * 16.0;
    pos.x = (aPosition.x + uChar.x * 0.025) * uScale - 1.0;
    pos.y = 1.0 + (aPosition.y - 0.08 * (uChar.y+1.0)) * uScale;
    gl_Position = vec4(pos.xy, -0.9, 1.0);
    vTexCoord.s = aTexCoord.s + 0.0625 * x;
    vTexCoord.t = aTexCoord.t + 0.125 * y;
  }
]]

Font.fShaderSrc = [[
  precision mediump float;
  varying vec2 vTexCoord;
  uniform vec3 uColor;
  uniform sampler2D uTexUnit;

  void main(void) {
    vec4 tex;
    tex = texture2D(uTexUnit, vec2(vTexCoord.s,vTexCoord.t));
    gl_FragColor = vec4(tex.xyz * uColor, tex.w);
  }
]]

function Font.setTextureUnit(self, tex_unit)
  self:useProgram()
  gl.uniform1i(self.uTexUnit, tex_unit)
end

-- ($20<= ch <=$7F)
function Font.setChar(self, x, y, ch)
  self:useProgram()
  gl.uniform3f(self.uChar, x, y, ch)
end

-- x: 0..79, y: 0..24
function Font.setPos(self, x, y)
  self:useProgram()
  gl.uniform3f(self.uChar, x, y, 32.0)
end

function Font.setColor(self, r, g, b)
  self:useProgram()
  gl.uniform3f(self.uColor, r, g, b)
end

-- scale: 0.5 .. 8.0 (default: 1.0)
function Font.setScale(self, scale)
  self:useProgram()
  self.scale = scale
  gl.uniform1f(self.uScale, scale)
end

function Font.getScale(self)
  return self.scale
end
