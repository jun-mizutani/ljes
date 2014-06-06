-- ---------------------------------------------
-- BonePhong.lua    2014/06/05
--   Copyright (c) 2013-2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

local ffi = require("ffi")
local gl = require("gles2")
require("Shader")

BonePhong = Shader:new()

function BonePhong.new(self)
  local obj = Shader.new(self)
  obj.MAX_BONES = 40
  obj.PALETTE_SIZE = obj.MAX_BONES * 3
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
  obj.uHasBone  = 0
  obj.aPosition = 0
  obj.aNormal   = 0
  obj.aTexCoord = 0
  obj.aIndex    = 0
  obj.aWeight = 0
  obj.default = {color = {0.8, 0.8, 1.0, 1.0}, tex_unit = 0,
                 light = {0.0, 0.0, 100.0, 1}, use_texture = 0,
                 emissive = 0, ambient = 0.3, specular = 0.6,
                 power = 40, has_bone = 0 }
  obj.change = {}
  return obj
end

BonePhong.vShaderSrc = [[
  attribute vec3 aPosition;
  attribute vec3 aNormal;
  attribute vec2 aTexCoord;
  attribute vec4 aIndex;
  attribute vec4 aWeight;

  varying   vec3 vPosition;
  varying   vec3 vNormal;
  varying   vec2 vTexCoord;

  uniform   int  uHasBone;
  uniform   mat4 uProjMatrix;
  uniform   mat4 uMVMatrix;
  uniform   mat4 uNormalMatrix;
  uniform   vec4 uBones[120];

  void main(void) {
    mat4  mat;
    vec4  v0, v1, v2;
    int i0, i1, i2, i3;
    if (uHasBone == 0) {
      mat = mat4(1.0);
    } else {
      i0 = int(aIndex.x) * 3;
      i1 = int(aIndex.y) * 3;
      i2 = int(aIndex.z) * 3;
      i3 = int(aIndex.w) * 3;
      v0  = uBones[i0] * aWeight.x + uBones[i1] * aWeight.y;
      v0 += uBones[i2] * aWeight.z + uBones[i3] * aWeight.w;
      v1  = uBones[i0 + 1] * aWeight.x + uBones[i1 + 1] * aWeight.y;
      v1 += uBones[i2 + 1] * aWeight.z + uBones[i3 + 1] * aWeight.w;
      v2  = uBones[i0 + 2] * aWeight.x + uBones[i1 + 2] * aWeight.y;
      v2 += uBones[i2 + 2] * aWeight.z + uBones[i3 + 2] * aWeight.w;
      mat[0] = vec4(v0.x, v1.x, v2.x, 0.0);
      mat[1] = vec4(v0.y, v1.y, v2.y, 0.0);
      mat[2] = vec4(v0.z, v1.z, v2.z, 0.0);
      mat[3] = vec4(v0.w, v1.w, v2.w, 1.0);
    }
    vTexCoord = aTexCoord;
    vPosition = vec3(uMVMatrix * mat * vec4(aPosition, 1.0));
    vNormal = mat3(uNormalMatrix) * mat3(mat) * aNormal;
    gl_Position = uProjMatrix * uMVMatrix * mat * vec4(aPosition, 1.0);
  }
]]

BonePhong.fShaderSrc = [[
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

function BonePhong.initShaderParameter(self)
  self:useProgram()
  local prog = self.program
  self.uHasBone   = gl.getUniformLocation(prog, "uHasBone")
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
  self.aIndex     = gl.getAttribLocation(prog, "aIndex")
  self.aWeight    = gl.getAttribLocation(prog, "aWeight")
  self.uBones     = gl.getUniformLocation(prog, "uBones")
end

function BonePhong.init(self)
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
  self:setHasBone(self.default.has_bone)
end

function BonePhong.setDefaultParam(self, key, value)
  self.default[key] = value
  if key == "color"  then self:setColor(value)
  elseif key == "tex_unit" then self:setTextureUnit(value)
  elseif key == "use_texture" then self:useTexture(value)
  elseif key == "light" then self:setLightPosition(value)
  elseif key == "emissive" then self:setEmissive(value)
  elseif key == "ambient" then self:setAmbientLight(value)
  elseif key == "specular" then self:setSpecular(value)
  elseif key == "power" then self:setSpecularPower(value)
  elseif key == "has_bone" then self:setHasBone(value)
  end
end

function BonePhong.setLightPosition(self, positionAndType)
  --  positionAndType : {x, y, z, type}
  --  type : 1/parallel light, 0/point light
  self:useProgram()
  gl.uniform4f(self.uLightPos, unpack(positionAndType))
end

function BonePhong.useTexture(self, flag)
  self:useProgram()
  gl.uniform1i(self.uTexFlag, flag)
  self.textureFlag = flag
end

function BonePhong.setTextureUnit(self, tex_unit)
  self:useProgram()
  gl.uniform1i(self.uTexUnit, tex_unit)
end

function BonePhong.setEmissive(self, flag)
  self:useProgram()
  gl.uniform1i(self.uEmit, flag)
end

function BonePhong.setAmbientLight(self, intensity)
  self:useProgram()
  gl.uniform1f(self.uAmb, intensity)
end

function BonePhong.setSpecular(self, intensity)
  self:useProgram()
  gl.uniform1f(self.uSpec, intensity)
end

function BonePhong.setSpecularPower(self, power)
  self:useProgram()
  gl.uniform1f(self.uSpecPower, power)
end

function BonePhong.setColor(self, color)
   -- color : {r, g, b, a}
  self:useProgram()
  gl.uniform4f(self.uColor, unpack(color))
end

function BonePhong.setProjectionMatrix(self, m)
  self:useProgram()
  gl.uniformMatrix4fv(self.uProjMatrix, 1, 0, m:convFloat())
end

function BonePhong.setModelViewMatrix(self, m)
  self:useProgram()
  gl.uniformMatrix4fv(self.uMVMatrix, 1, 0, m:convFloat())
end

function BonePhong.setNormalMatrix(self, m)
  self:useProgram()
  gl.uniformMatrix4fv(self.uNormalMatrix, 1, 0, m:convFloat())
end

function BonePhong.updateTexture(self, param)
  if (param.texture ~= nil) then
    self.change.texture = param.texture
    param.texture:active()
    self:setTextureUnit(0)
  end
end

function BonePhong.setHasBone(self, flag)
  self:useProgram()
  gl.uniform1i(self.uHasBone, flag)
end

function BonePhong.setMatrixPalette(self, matrixPalette)
  self:useProgram()
  -- send 40 * 3 float4 to GPU
  gl.uniform4fv(self.uBones, self.PALETTE_SIZE, matrixPalette);
end

function BonePhong.doParameter(self, param)
  self:updateParam(param, "color", self.setColor)
  self:updateParam(param, "light", self.setLightPosition)
  self:updateParam(param, "use_texture", self.useTexture)
  self:updateParam(param, "ambient", self.setAmbientLight)
  self:updateParam(param, "specular", self.setSpecular)
  self:updateParam(param, "power", self.setSpecularPower)
  self:updateParam(param, "emissive", self.setEmissive)
  self:updateParam(param, "has_bone", self.setHasBone)
  self:updateTexture(param)
end
