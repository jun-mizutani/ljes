-- ---------------------------------------------
-- Texture.lua      2014/01/09
--   Copyright (c) 2013-2014 Jun Mizutani,
--   released under the MIT open sondurce license.
-- ---------------------------------------------

local ffi  = require "ffi"
local gl   = require "gles2"
local png  = require "png"
local util = require "util"

require("Object")

Texture = Object:new()

function Texture.new(self)
  local obj = Object.new(self)
  obj.status = false
  obj.filename = nil
  obj.textureUnit = 0
  obj.image_buffer = nil
  obj.width = 0
  obj.height = 0
  obj.ncol = 0
  obj.texname = 0
  return obj
end

function Texture.setupTexture(self)
  local tex = ffi.new("uint32_t[1]")
  gl.genTextures(1, tex)
  self.texname = tex[0]
  gl.bindTexture(gl.TEXTURE_2D, self.texname)
  gl.pixelStorei(gl.UNPACK_ALIGNMENT, 1)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
end

function Texture.setClamp(self)
  gl.bindTexture(gl.TEXTURE_2D, self.texname)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
end

function Texture.readImageFromFile(self, textureFile)
  self:setupTexture()
  if util.isFileExist(textureFile) ~= true then
    textureFile = util.packagePath() .. textureFile
    if util.isFileExist(textureFile) ~= true then
      return false
    end
  end
  local image, bytes, w, h, bpp, ncol = png.readPNG(textureFile, 1)
  if image == nil then return false end
  self.filename = textureFile
  png.flipImage(image, w, h, ncol)
  self:setImage(image, w, h, ncol)
  return true
end

function Texture.setImage(self, image, width, height, ncol)
  if ncol == 4 then
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width, height, 0, gl.RGBA,
      gl.UNSIGNED_BYTE, image)
  else
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGB, width, height, 0, gl.RGB,
      gl.UNSIGNED_BYTE, image)
  end
  self.image_buffer = image
  self.width = width
  self.height = height
  self.ncol = ncol
end

function Texture.writeImageToFile(self)
  local w = self.width
  local h = self.height
  local filename = "tex" .. os.date("%Y%m%d_%H%M%S") .. ".png"
  png.writePNG(filename, self.image_buffer, w * h * self.ncol, w, h,
               8, self.ncol)
end

function Texture.createTexture(self, width, height, ncol)
  self:setupTexture()
  if ncol == 3 then
    self.image_buffer = ffi.new("uint8_t[?]", width * height * 3)
    self.ncol = 3
  else
    self.image_buffer = ffi.new("uint8_t[?]", width * height * 4)
    self.ncol = 4
  end
  self.width = width
  self.height = height
end

function Texture.fillTexture(self, r, g, b, a)
  local n, m
  for y=0, self.height - 1 do
    n = y * self.width
    for x=0, self.width - 1 do
      m = (n + x) * self.ncol
      self.image_buffer[m  ] = r
      self.image_buffer[m+1] = g
      self.image_buffer[m+2] = b
      if self.ncol == 4 then
        self.image_buffer[m+3] = a
      end
    end
  end
end

function Texture.point(self, x, y, color)
  -- color : {r, b, g, a}
  if x >= self.width or y >= self.height then return false end
  if x < 0 or y < 0 then return false end
  local n = (y * self.width + x) * self.ncol
  self.image_buffer[n  ] = color[1]
  self.image_buffer[n+1] = color[2]
  self.image_buffer[n+2] = color[3]
  if self.ncol == 4 then
    self.image_buffer[n+3] = color[4]
  end
end

function Texture.assignTexture(self)
  gl.bindTexture(gl.TEXTURE_2D, self.texname)
  if self.ncol == 3 then
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGB, self.width, self.height,
                  0, gl.RGB, gl.UNSIGNED_BYTE, self.image_buffer)
  else
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, self.width, self.height,
                  0, gl.RGBA, gl.UNSIGNED_BYTE, self.image_buffer)
  end
end

function Texture.name(self)
  return self.texname
end

function Texture.active(self)
  gl.activeTexture(gl.TEXTURE0)
  gl.bindTexture(gl.TEXTURE_2D, self.texname)
end

