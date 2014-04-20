#!/usr/bin/luajit
-- ---------------------------------------------
-- axis.lua    2013/04/10
--   Copyright (c) 2013 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

package.path = "../LjES/?.lua;" .. package.path

require "Message"
local demo = require("demo2")

function createArrowShape(length, r, g, b)
  local obj = Shape:new()
  obj:arrow(length, length / 10, length / 100, 12)
  obj:endShape()
  obj:shaderParameter("color", {r, g, b, 1.0})
  obj:shaderParameter("ambient", 0.5)
  return obj
end

function createCoordNode(space, length)
  local shapeX = createArrowShape(length, 1.0, 0.0, 0.0)
  local shapeY = createArrowShape(length, 0.0, 0.8, 0.0)
  local shapeZ = createArrowShape(length, 0.0, 0.0, 1.0)
  local base = space:addNode(nil, "base")
  local nodeX = space:addNode(base, "X")
  local nodeY = space:addNode(base, "Y")
  local nodeZ = space:addNode(base, "Z")
  nodeX:addShape(shapeX)
  nodeY:addShape(shapeY)
  nodeZ:addShape(shapeZ)
  nodeX:setAttitude(0.0, 0.0, -90.0)
  nodeZ:setAttitude(0.0, 90.0, 0.0)
  return base
end

demo.screen(0, 0)
demo.backgroundColor(1.0, 1.0, 1.0)
local aSpace = demo.getSpace()
local eye = aSpace:addNode(nil, "eye")
eye:setPosition(0, 10, 23)
eye:setAttitude(0, -18, 0)

local aMes = Message:new()
local ok = aMes:init("font512.png")
aMes:setScale(4.0)
aMes:setColor(1.0, 0.0, 0.0)
aMes:writeMessage(16, 4, "X")
aMes:setColor(0.0, 0.8, 0.0)
aMes:writeMessage(11, 1, "Y")
aMes:setColor(0.0, 0.0, 1.0)
aMes:writeMessage(6, 4, "Z")

local node = createCoordNode(aSpace, 10.0)
node:setPosition(0, 0, 0)
node:setAttitude(-15, 0, 0)

local arrow_shape = Shape:new()
arrow_shape:arrow(2, 1.0, 0.2, 12)
arrow_shape:endShape()
arrow_shape:shaderParameter("color", {0.9, 0.6, 0.0, 1.0})
arrow_shape:shaderParameter("ambient", 0.5)
local arrow = aSpace:addNode(nil, "arrow")
arrow:addShape(arrow_shape)
arrow:setPosition(2, 2, 2)
arrow:setAttitude(0, -45, -30)

demo.textFontScale(2.0)
demo.textColor(0, 0, 0)

function draw()
  arrow:rotateX(0.2)
  aSpace:draw(eye)
  aMes:drawScreen()
end

demo.loop(draw, false)
demo.exit()
