-- ---------------------------------------------
-- Phong.lua       2013/04/09
--   Copyright (c) 2013 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

--[[
  Phong:new()
  Phong:initShaderParameter()
  Phong:init()
  Phong:setLightPosition(positionAndType)
  Phong:useTexture(flag)
  Phong:setTextureUnit(tex_unit)
  Phong:setEmissive(flag)
  Phong:setAmbientLight(intensity)
  Phong:setSpecular(intensity)
  Phong:setSpecularPower(power)
  Phong:setColor(color)
  Phong:setProjectionMatrix(m)
  Phong:setModelViewMatrix(m)
  Phong:setNormalMatrix(m)
  Phong:updateTexture(param)
  Phong:doParameter(param)
]]

local ffi = require "ffi"
local gl = require "gles2"
require "Shader"

Phong = Shader:new()

function Phong.new(self)
  local obj = Shader.new(self)
  obj.uProjMatrix = 0
  obj.uMVMatrix =   0
  obj.uNormalMatrix = 0
  obj.uTexUnit  = 0
  obj.uTexFlag  = 0
  obj.uEmit     = 0
  obj.uAmb      = 0
  obj.uSpec     = 0
  obj.uSpecPower= 0
  obj.uLightPos = 0
  obj.uColor    = 0
  obj.aPosition = 0
  obj.aNormal   = 0
  obj.aTexCoord = 0
  obj.default = {color = {0.8, 0.8, 1.0, 1.0}, tex_unit = 0,
                 light = {0.0, 0.0, 100.0, 1}, use_texture = 0,
                 emissive = 0, ambient = 0.3, specular = 0.6, power = 40 }
  obj.change = {}
  return obj
end

Phong.vShaderSrc = [[
  attribute vec3 aPosition;
  attribute vec3 aNormal;
  attribute vec2 aTexCoord;

  varying   vec3 vPosition;
  varying   vec3 vNormal;
  varying   vec2 vTexCoord;

  uniform   mat4 uProjMatrix;
  uniform   mat4 uMVMatrix;
  uniform   mat4 uNormalMatrix;

  void main(void) {
    gl_Position = uProjMatrix * uMVMatrix * vec4(aPosition, 1.0);

    vTexCoord = aTexCoord;
    vPosition = vec3(uMVMatrix * vec4(aPosition, 1.0));

    vNormal = vec3(uNormalMatrix * vec4(aNormal, 1));
  }
]]

Phong.fShaderSrc = [[
  precision mediump float;

  varying vec3   vPosition;
  varying vec3   vNormal;
  varying vec2   vTexCoord;
  uniform sampler2D uTexUnit;
  uniform int    uTexFlag;
  uniform int    uEmit;
  uniform float  uAmb;
  uniform float  uSpec;
  uniform float  uSpecPower;
  uniform vec4   uLightPos;
  uniform vec4   uColor;

  void main(void) {
    vec4 color;
    vec3 lit_vec;
    float diff;
    float Ispec;
    vec4 white = vec4(1.0, 1.0, 1.0, 1.0);
    vec3 nnormal = normalize(vNormal);

    if (uLightPos.w!=0.0) {
      lit_vec = normalize(uLightPos.xyz - vPosition);
    } else {
      lit_vec = normalize(uLightPos.xyz);
    }
    vec3 eye_vec = normalize(-vPosition);
    vec3 ref_vec = normalize(reflect(-lit_vec, nnormal));
    if (uEmit == 0) {
      diff = max(dot(nnormal, lit_vec), 0.0) * (1.0 - uAmb);
      Ispec = uSpec * pow(max(dot(ref_vec, eye_vec), 0.0), uSpecPower);
    } else {
      diff = 1.0 - uAmb;
      Ispec = 0.0;
    }
    if (uTexFlag != 0) {
      color = uColor * texture2D(uTexUnit,vec2(vTexCoord.s,vTexCoord.t));
      color = mix(diff * uColor, color, uColor.w);
    } else {
      color = uColor;
    }
    gl_FragColor = vec4(color.rgb * (uAmb+diff) + white.rgb * Ispec,1);
  }
]]

function Phong.initShaderParameter(self)
  self:useProgram()
  local prog = self.program
  self.uProjMatrix = gl.getUniformLocation(prog, "uProjMatrix")
  self.uMVMatrix  =   gl.getUniformLocation(prog, "uMVMatrix")
  self.uNormalMatrix = gl.getUniformLocation(prog, "uNormalMatrix")
  self.uTexUnit   = gl.getUniformLocation(prog, "uTexUnit")
  self.uTexFlag   = gl.getUniformLocation(prog, "uTexFlag")
  self.uEmit      = gl.getUniformLocation(prog, "uEmit")
  self.uAmb       = gl.getUniformLocation(prog, "uAmb")
  self.uSpec      = gl.getUniformLocation(prog, "uSpec")
  self.uSpecPower = gl.getUniformLocation(prog, "uSpecPower")
  self.uLightPos  = gl.getUniformLocation(prog, "uLightPos")
  self.uColor     = gl.getUniformLocation(prog, "uColor")
  self.aPosition  = gl.getAttribLocation(prog, "aPosition")
  self.aNormal    = gl.getAttribLocation(prog, "aNormal")
  self.aTexCoord  = gl.getAttribLocation(prog, "aTexCoord")
end

function Phong.init(self)
  self.status = self:initShaders()
  self:initShaderParameter()
  self:useProgram()
  self:setLightPosition(self.default.light)
  self:useTexture(self.default.use_texture)
  self:setColor(self.default.color)
  self:setEmissive(self.default.emissive)
  self:setAmbientLight(self.default.ambient)
  self:setSpecular(self.default.specular)
  self:setSpecularPower(self.default.power)
end

function Phong.setDefaultParam(self, key, value)
  self.default[key] = value
  if key == "color"  then self:setColor(value)
  elseif key == "tex_unit" then self:setTextureUnit(value)
  elseif key == "use_texture" then self:useTexture(value)
  elseif key == "light" then self:setLightPosition(value)
  elseif key == "emissive" then self:setEmissive(value)
  elseif key == "ambient" then self:setAmbientLight(value)
  elseif key == "specular" then self:setSpecular(value)
  elseif key == "power" then self:setSpecularPower(value)
  end
end

function Phong.setLightPosition(self, positionAndType)
  --  positionAndType : {x, y, z, type}
  --  type : 1/parallel light, 0/point light
  self:useProgram()
  gl.uniform4f(self.uLightPos, unpack(positionAndType))
end

function Phong.useTexture(self, flag)
  self:useProgram()
  gl.uniform1i(self.uTexFlag, flag)
  self.textureFlag = flag
end

function Phong.setTextureUnit(self, tex_unit)
  self:useProgram()
  gl.uniform1i(self.uTexUnit, tex_unit)
end

function Phong.setEmissive(self, flag)
  self:useProgram()
  gl.uniform1i(self.uEmit, flag)
end

function Phong.setAmbientLight(self, intensity)
  self:useProgram()
  gl.uniform1f(self.uAmb, intensity)
end

function Phong.setSpecular(self, intensity)
  self:useProgram()
  gl.uniform1f(self.uSpec, intensity)
end

function Phong.setSpecularPower(self, power)
  self:useProgram()
  gl.uniform1f(self.uSpecPower, power)
end

function Phong.setColor(self, color)
   -- color : {r, g, b, a}
  self:useProgram()
  gl.uniform4f(self.uColor, unpack(color))
end

function Phong.setProjectionMatrix(self, m)
  self:useProgram()
  gl.uniformMatrix4fv(self.uProjMatrix, 1, 0, m:convFloat())
end

function Phong.setModelViewMatrix(self, m)
  self:useProgram()
  gl.uniformMatrix4fv(self.uMVMatrix, 1, 0, m:convFloat())
end

function Phong.setNormalMatrix(self, m)
  self:useProgram()
  gl.uniformMatrix4fv(self.uNormalMatrix, 1, 0, m:convFloat())
end

function Phong.updateTexture(self, param)
  if (param.texture ~= nil) then
    self.change.texture = param.texture
    param.texture:active()
    self:setTextureUnit(0)
  end
end

function Phong.doParameter(self, param)
  self:updateParam(param, "color", self.setColor)
  self:updateParam(param, "light", self.setLightPosition)
  self:updateParam(param, "use_texture", self.useTexture)
  self:updateParam(param, "ambient", self.setAmbientLight)
  self:updateParam(param, "specular", self.setSpecular)
  self:updateParam(param, "power", self.setSpecularPower)
  self:updateParam(param, "emissive", self.setEmissive)
  self:updateTexture(param)
end
