-- ---------------------------------------------
-- Shader.lua       2013/03/21
--   Copyright (c) 2013 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

--[[
  Shader:new()
  Shader:loadShader(type, shaderSource)
  Shader:initShaders()
  Shader:setDefaultParam(key, value)
  Shader:updateParam(param, key, updateFunc)
  Shader:initShaderParameter()
  Shader:doParameter(param)
  Shader:useProgram()
  Shader:init()
]]

local ffi = require "ffi"
local gl = require "gles2"

require "Object"

Shader = Object:new()

function Shader.new(self)
  local obj = Object.new(self)
  obj.program = 0
  return obj
end

Shader.vShaderSrc = ""
Shader.fShaderSrc = ""

function Shader.loadShader(self, type, shaderSource)
  local shader = gl.createShader(type)
  if shader == 0 then
    local shaderType = "FRAGMENT_SHADER"
    if type == gl.VERTEX_SHADER then
      shaderType = "VERTEX_SHADER"
    end
    print(string.format("glCreateShader: %s failed.", shaderType))
    return 0
  end
  local CharP = ffi.typeof("const char*")
  local CharPP = ffi.typeof("const char* [1]")
  local cp = CharP(shaderSource)
  local cpp = CharPP(cp)
  gl.shaderSource(shader, 1, cpp, nil)
  gl.compileShader(shader)
  local compiled = ffi.new("uint32_t[1]")
  gl.getShaderiv(shader, gl.COMPILE_STATUS, compiled)
  if compiled[0] == 0 then
    local infoLen = ffi.new("uint32_t[1]")
    gl.getShaderiv(shader, gl.INFO_LOG_LENGTH, infoLen)
    if (infoLen[0] > 0) then
      local infoLog = ffi.new("char[?]", infoLen[0])
      gl.getShaderInfoLog(shader, infoLen[0], nil, infoLog)
      print(string.format("Error compiling shader: %s", infoLog))
    end
    gl.deleteShader(shader)
    return 0
  end
  return shader
end

function Shader.initShaders(self)
  local vShader = self:loadShader(gl.VERTEX_SHADER, self.vShaderSrc)
  local fShader = self:loadShader(gl.FRAGMENT_SHADER, self.fShaderSrc)

  local prog = gl.createProgram()
  self.program = prog
  if prog == 0 then
    self.program = 0
    print("failed to create program.")
    return False
  end

  gl.attachShader(prog, vShader)
  gl.attachShader(prog, fShader)
  gl.linkProgram(prog)
  linked = ffi.new("uint32_t[1]")
  gl.getProgramiv(prog, gl.LINK_STATUS, linked)
  if linked[0] == 0 then
    local infoLen = ffi.new("uint32_t[1]")
    gl.getProgramiv(prog, gl.INFO_LOG_LENGTH, infoLen)
    if infoLen[0] > 0 then
      local infoLog = ffi.new("char[?]", infoLen[0])
      gl.getProgramInfoLog(prog, infoLen[0], nil, infoLog)
      print(string.format("Error linking program: %s", infoLog[0]))
    end
    gl.deleteProgram(prog)
    return False
  end

  gl.deleteShader(vShader)
  gl.deleteShader(fShader)
  return prog
end

function Shader.setDefaultParam(self, key, value)
  self.default[key] = value
end

function Shader.updateParam(self, param, key, updateFunc)
  function compare(table1, table2)
    if table1 == table2  then return true end  -- identical table
    if #table1 ~= #table2 then return false end
    for i=1, #table1 do
      if table1[i] ~= table2[i] then return false end
    end
    return true  -- same contents
  end

  if (param[key] ~= nil) then
    self.change[key] = param[key]
    updateFunc(self, param[key])
  else
    local c = self.change
    if c[key] ~= nil then
      local d = self.default
      if type(d[key]) == "table" then
        if compare(c[key], d[key]) == false then
          c[key] = d[key]
        end
      elseif c[key] ~= d[key] then
        c[key] = d[key]
        updateFunc(self, d[key])
      end
    end
  end
end

function Shader.initShaderParameter(self)
end

function Shader.doParameter(self, param)
end

function Shader.useProgram(self)
  gl.useProgram(self.program)
end

function Shader.init(self)
  self.status = self:initShaders()
  self:initShaderParameter()
end
