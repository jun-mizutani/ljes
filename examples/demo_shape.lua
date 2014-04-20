#!/usr/bin/luajit
-- ---------------------------------------------
-- demo_shape.lua  2013/04/11
--   Copyright (c) 2013 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

package.path = "../LjES/?.lua;" .. package.path

local demo = require("demo2")
local shapes = {}
local tex, tex2

function createShapes()
  for i=1, 9 do
    shapes[i] = Shape:new()
    shapes[i]:setTextureMappingMode(0)
    shapes[i]:setTextureMappingAxis(1)
    shapes[i]:shaderParameter("use_texture", 1)
    shapes[i]:shaderParameter("texture", tex)
    if i == 1 then
      shapes[i]:sphere(8, 16, 16)
    elseif i == 2 then
      shapes[i]:cone(10, 6, 16)
    elseif i == 3 then
      shapes[i]:truncated_cone(8, 2, 5, 16)
    elseif i== 4 then
      shapes[i]:double_cone(10, 8, 16)
    elseif i== 5 then
      shapes[i]:prism(12, 4, 16)
    elseif i== 6 then
      shapes[i]:donut(8, 3, 16, 16)
    elseif i== 7 then
      shapes[i]:setTextureMappingMode(1)
      shapes[i]:setTextureMappingAxis(1)
      shapes[i]:setTextureScale(8, 8)
      shapes[i]:cube(8)
    elseif i== 8 then
      shapes[i]:setTextureMappingMode(1)
      shapes[i]:setTextureMappingAxis(1)
      shapes[i]:setTextureScale(4, 4)
      shapes[i]:cuboid(8, 7, 6)
    elseif i== 9 then
      shapes[i]:shaderParameter("texture", tex2)
      shapes[i]:setTextureScale(4, 4)
      shapes[i]:mapCube(10)
    end
    shapes[i]:endShape()
    local r = (math.random() * 0.5) + 0.5
    local g = (math.random() * 0.5) + 0.5
    local b = (math.random() * 0.5) + 0.5
    shapes[i]:shaderParameter("color", {r, g, b, 1.0})
  end
  return shapes
end


demo.screen(-200, -200)
math.randomseed(os.time())

local aSpace = demo.getSpace()

local eye = aSpace:addNode(nil, "eye")
eye:setPosition(0, 0, 50)

tex = Texture:new()
tex:readImageFromFile("num512.png")
tex2 = Texture:new()
tex2:readImageFromFile("CubeMap_dice.png")

createShapes()

local objNode = {}
local rot = {}
for i=1, 9 do
  objNode[i] = aSpace:addNode(nil, "objNode")
  local x = (math.random() - 0.5) * 50
  local y = (math.random() - 0.5) * 50
  local z = -math.random() * 30 - 15
  objNode[i]:setPosition(x, y, z)
  objNode[i]:addShape(shapes[i])
  rot[i] = math.random() * 0.8 + 0.5
end

aSpace:timerStart()

demo.backgroundColor(0.2, 0.2, 0.4)
function draw()
  for i=1,9 do
    objNode[i]:rotateX(rot[i])
    objNode[i]:rotateY(rot[i])
  end
  eye:rotateZ(0.3)
  aSpace:draw(eye)
end

demo.loop(draw, true)
demo.aText.shader:getInfo()
demo.exit()
