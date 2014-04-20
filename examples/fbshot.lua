#!/usr/bin/luajit
-- ---------------------------------------------
-- fbshot.lua 2014/03/29
--   Copyright (c) 2014 Jun Mizutani,
--   released under the MIT open source license.
--
-- Save framebuffer into PNG file.
-- ---------------------------------------------
package.path = "../LjES/?.lua;" .. package.path

local bit = require("bit")
local ffi = require("ffi")
local png = require("png")
local util = require("util")

local filename = arg[1]
local w = tonumber(arg[2])
local h = tonumber(arg[3])

if (filename == nil) or (arg[2] == nil) or (arg[2] == nil) then
  util.printf("  usage:\n")
  util.printf("    sudo ./fbshot.lua filename width height\n")
  return
end

local fb = util.readFile("/dev/fb0")
local buflen = w * h * 3
local buf = ffi.new("uint8_t[?]", buflen)

for i = 0, w * h - 1 do
  local n = i * 2 + 1
  local fb1 = string.sub(fb, n, n):byte(1)
  local fb2 = string.sub(fb, n+1 , n+1):byte(1)
  rgb16 = fb2*256 + fb1 
  red = bit.rshift(bit.band(rgb16, 0xF800), 8) 
  green = bit.rshift(bit.band(rgb16, 0x07E0), 3) 
  blue = bit.lshift(bit.band(rgb16, 0x1F), 3)
  buf[i*3  ] = red
  buf[i*3+1] = green
  buf[i*3+2] = blue
end
png.writePNG(filename, buf, w, h, 8, 3)


