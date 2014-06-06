-- ---------------------------------------------
-- FrameBufferObject.lua 2014/06/05
--   Copyright (c) 2013-2014 Jun Mizutani,
--   released under the MIT open sondurce license.
-- ---------------------------------------------

local ffi = require("ffi")
local gl  = require("gles2")
local png  = require("png")

require("Texture")

FrameBufferObject = Object:new()

function FrameBufferObject.create(self, texture_class)
  self.texture = texture_class
  self.width = texture_class.width
  self.height = texture_class.height
  self.clearColor = {0.0, 0.0, 0.0, 1.0}
  local width = self.texture.width
  local height = self.texture.height

  local valueArray  = ffi.new("uint32_t[1]")
  gl.getIntegerv(gl.MAX_RENDERBUFFER_SIZE, valueArray)
  local maxRenderbufferSize = valueArray[0]
  if((maxRenderbufferSize <= width) or (maxRenderbufferSize <= height)) then
    -- >2048x2048
    return false
  end

  local framebuffer = ffi.new("uint32_t[1]")
  gl.genFramebuffers(1, framebuffer)
  gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer[0])

  local depthRenderbuffer = ffi.new("uint32_t[1]")
  gl.genRenderbuffers(1, depthRenderbuffer)
  gl.bindRenderbuffer(gl.RENDERBUFFER, depthRenderbuffer[0])
  gl.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_COMPONENT24_OES,
                         width, height)
  gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0,
    gl.TEXTURE_2D, texture_class:name(), 0)

  gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT,
    gl.RENDERBUFFER, depthRenderbuffer[0])

  self.framebuffer = framebuffer
  self.depthRenderbuffer = depthRenderbuffer

  local status = gl.checkFramebufferStatus(gl.FRAMEBUFFER)
  if (status == gl.FRAMEBUFFER_COMPLETE) then
    return true
  end
  return false
end

function FrameBufferObject.setClearColor(self, r, g, b, alpha)
  self.clearColor = {r, g, b, alpha}
end

function FrameBufferObject.clear(self)
  gl.bindFramebuffer(gl.FRAMEBUFFER, self.framebuffer[0])
  gl.viewport(0, 0, self.width, self.height)
  gl.clearColor(unpack(self.clearColor))
  gl.clear(gl.COLOR_BUFFER_BIT + gl.DEPTH_BUFFER_BIT)
  --self.texture:active()
end

function FrameBufferObject.endDraw(self)
  gl.bindFramebuffer(gl.FRAMEBUFFER, 0) -- window system fb
end

function FrameBufferObject.destroy(self)
  glDeleteRenderbuffers(1, self.depthRenderbuffer)
  glDeleteFramebuffers(1, self.framebuffer)
  return true
end

function FrameBufferObject.writeToFile(self)
  gl.bindFramebuffer(gl.FRAMEBUFFER, self.framebuffer[0])
  local w = self.width
  local h = self.height
  local buflen = w * h * 3
  local buf = ffi.new("uint8_t[?]", buflen)
  gl.readPixels(0, 0, w, h, gl.RGB, gl.UNSIGNED_BYTE, buf)
  local filename = "fbo" .. os.date("%Y%m%d_%H%M%S") .. ".png"
  png.flipImage(buf, w, h, 3)
  png.writePNG(filename, buf, w, h, 8, 3)
  gl.bindFramebuffer(gl.FRAMEBUFFER, 0) -- window system fb
end

