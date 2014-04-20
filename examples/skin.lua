#!/usr/bin/luajit
-- ---------------------------------------------
-- skin.lua         2014/03/30
--   Copyright (c) 2014 Jun Mizutani,
--   released under the MIT open source license.
--
-- Demonstrate skeletal animation without Collada.
-- ---------------------------------------------

package.path = "../LjES/?.lua;" .. package.path

local demo = require("demo")
local tex, tex2

local aShape
local j0, j1    -- Bone

function revolution(latitude, longitude, verts)
  local n = #verts / 2 -- latitude + 1
  local v
  local bottom = verts[#verts]
  local height = verts[2] - verts[#verts]
  for i= 0, n-1 do
    local k = i * 2 + 1  -- index++
      v = aShape:addVertex(verts[k], verts[k+1], 0)
      -- set vertex weight
      aShape:addVertexWeight(v, 0, 1 - (verts[k+1] - bottom)/height )
      aShape:addVertexWeight(v, 1, (verts[k+1] - bottom)/height )
  end
  T = math.pi * 2 / longitude
  for j = 1, longitude+1 do
    for i = 0, n-1 do
      local k = i * 2 + 1  -- index++
      v = aShape:addVertex(verts[k] * math.cos(T*j), verts[k+1],
                - verts[k] * math.sin(T*j))
      -- set vertex weight
      aShape:addVertexWeight(v, 0, 1 - (verts[k+1] - bottom)/height )
      aShape:addVertexWeight(v, 1, (verts[k+1] - bottom)/height )
    end
  end

  for j = 0, longitude-2 do
    for i = 0, n - 2  do
      aShape:addPlane(
        { j * n + i,
          j * n + i + 1,
          (j + 1) * n + i + 1,
          (j + 1) * n + i
        })
    end
  end
  --  m-1 to 0
  for i = 0, n - 2 do
    aShape:addPlane(
      { (longitude-1) * n + i,
        (longitude-1) * n + i + 1,
        i + 1,
        i
      })
  end
end

function prism(height, radius, n)
  vertices = {}
  table.insert(vertices,  0.0001 )    --  x axis   TOP
  table.insert(vertices,  height )    --  y axis

  table.insert(vertices,  radius )    --  x axis
  table.insert(vertices,  height )    --  y axis

  table.insert(vertices,  radius )    --  x axis
  table.insert(vertices,  height*2/3) --  y axis

  table.insert(vertices,  radius )    --  x axis
  table.insert(vertices,  height/3 )  --  y axis

  table.insert(vertices,  radius )    --  x axis
  table.insert(vertices,  0 )         --  y axis

  table.insert(vertices,  radius )    --  x axis
  table.insert(vertices,  -height/3 ) --  y axis
  table.insert(vertices,  radius )    --  x axis
  table.insert(vertices, -height*2/3) --  y axis
  table.insert(vertices,  radius )    --  x axis
  table.insert(vertices,  -height )   --  y axis

  table.insert(vertices,  0.0001 )    --  x axis   BOTTOM
  table.insert(vertices,  -height )   --  y axis
  revolution(8, n, vertices)
end

function createShapes()
  aShape = Shape:new()
  -- embed bones
  local skeleton = Skeleton:new()
  aShape:setSkeleton(skeleton)
  j0 = skeleton:addBone(nil, "j0")
  j1 = skeleton:addBone(j0, "j1")
  j0:setRestPosition(0.0, -10, 0.0)
  j1:setRestPosition(0.0, 10.0, 0.0)
  skeleton:bindRestPose()
  aShape:shaderParameter("has_bone", 1)

  aShape:setTextureMappingMode(1)
  aShape:setTextureMappingAxis(1)
  aShape:setTextureScale(16, 16)
  aShape:shaderParameter("use_texture", 1)
  aShape:shaderParameter("texture", tex)

  prism(10, 2, 16)
  aShape:endShape()
  aShape:shaderParameter("color", {1.0, 1.0, 1.0, 1.0})
end

demo.screen(0, 0)
math.randomseed(os.time())
local aSpace = demo.getSpace()
local eye = aSpace:addNode(nil, "eye")
eye:setPosition(0, 0, 25)
tex = Texture:new()
tex:readImageFromFile("num512.png")
createShapes()

local node = aSpace:addNode(nil, "objNode")
node:setPosition(0, 0, 0)
node:addShape(aShape)

demo.backgroundColor(0.0, 0.0, 0.0)
j1:rotateZ(75)
aSpace:timerStart()

function draw()
  local count = demo.aScreen:getFrameCount()
  if (count - math.floor(count/100)*100) < 50 then
    j1:rotateZ(-3)
  else
    j1:rotateZ(3)
  end
  j0:rotateY(-0.6)
  --node:rotateY(0.5)
  aSpace:draw(eye)
  --aShape.skeleton:listBones()
end

demo.loop(draw, true)
demo.exit()
