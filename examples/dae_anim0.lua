#!/usr/bin/luajit
-- ---------------------------------------------
-- dae_view.lua     2014/03/30
--   Copyright (c) 2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

package.path = "../LjES/?.lua;" .. package.path

local demo = require("demo")
require("ColladaShape")

if arg[1] ~= nil then
  collada_file = arg[1]
else
  print("usage: luajit dae_anim0.lua your_collada.dae")
  return
end

demo.screen(0, 0)
local aSpace = demo.getSpace()
demo.backgroundColor(0.2, 0.2, 0.4)

-- load collada
local collada = ColladaShape:new()
local collada_text = util.readFile(collada_file)
collada:parse(collada_text ,true)
local shapes = collada:makeShapes(true, true)

-- set object
local node = aSpace:addNode(nil, "node")
for i = 1, #shapes do
  shapes[i]:shaderParameter("color", {0.8, 0.7, 0.6, 1.0})
  node:addShape(shapes[i])
end

-- set eye position
local eye = aSpace:addNode(nil, "eye")
local size =  demo.getShapeSize(shapes)
eye:setPosition(size.centerx, size.centery, size.max * 1.2)

-- setup animation
node.shapes[1].anim:start()

-- call back function
function draw()
  demo.aText:writeAt(2, 24, "[q]  : quit")
  node.shapes[1].anim:play() -- play one frame of animation
  aSpace:draw(eye)
end

-- main loop
demo.loop(draw, true)
demo.exit()
