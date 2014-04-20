#!/usr/bin/luajit
-- ---------------------------------------------
-- demo_spheres.lua 2013/04/11,2014/03/30
--   Copyright (c) 2013-2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

package.path = "../LjES/?.lua;" .. package.path

local util = require("util")
local termios = require("termios")
require("Phong")
require("Screen")
require("Matrix")
require("Texture")
require("Space")
require("Shape")
require("Text")    -- changed from TexText

function checkKey(eye, base, text)
  local key = termios.realtimeKey()
  local scr = g_Screen
  local fw = scr.fullWidth
  local fh = scr.fullHeight
  if (key == 'q') then     g_Quit = true
  elseif (key == 'p') then scr:screenShot()
  elseif (key == 't') then scr:move(fw / 2, fh / 2, fw / 2, 0)
  elseif (key == 'b') then scr:move(fw / 2, fh / 2, fw / 2, fh / 2)
  elseif (key == 'g') then scr:restoreSize()
  elseif (key == 'f') then scr:move(fw, fh, 0, 0)
  elseif (key == 'w') then base:rotateX(0.3)
  elseif (key == 's') then base:rotateX(-0.3)
  elseif (key == 'a') then base:rotateY(0.3)
  elseif (key == 'd') then base:rotateY(-0.3)
  elseif (key == 'z') then eye:move(0,0,-1)
  elseif (key == 'x') then eye:move(0,0,1)
  elseif (key == 'j') then text:setScale(1)
  elseif (key == 'k') then text:setScale(2)
  elseif (key == 'l') then text:setScale(3)
  elseif (key == 'h') then
    if g_Help then
      hideHelp(text)
      g_Help = false
    else
      showHelp(text)
      g_Help = true
    end
  elseif (key == 'x') then eye:move(0,0,1)
  elseif (key >= '1') and (key <= '9') then
   local n = string.byte(key, 1)
   changeShape(g_Nodes, n - 48)
  end
end

function color(div, i, count)
  local d = 0.5 / div
  return {d * i + 0.5, (count % 2000)*0.00025 + 0.5, 1.0 - d * i, 1.0}
end

function makeShapes()
  local numShapes = 9
  local shapes = {}
  for i = 1, numShapes do
    shapes[i] = Shape:new()
    shapes[i]:shaderParameter("texture", tex)
    if i == 1 then
      shapes[i]:sphere(5, 16, 16)
    elseif i == 2 then
      shapes[i]:cone(8, 8, 16)
    elseif i == 3 then
      shapes[i]:truncated_cone(4, 3, 6, 16)
    elseif i== 4 then
      shapes[i]:double_cone(6, 6, 16)
    elseif i== 5 then
      shapes[i]:prism(6, 4, 16)
    elseif i== 6 then
      shapes[i]:donut(5, 4, 16, 16)
    elseif i== 7 then
      shapes[i]:setTextureMappingMode(1)
      shapes[i]:setTextureMappingAxis(1)
      shapes[i]:setTextureScale(8, 8)
      shapes[i]:cube(8)
    elseif i== 8 then
      shapes[i]:setTextureMappingMode(1)
      shapes[i]:setTextureMappingAxis(1)
      shapes[i]:setTextureScale(4, 4)
      shapes[i]:cuboid(10, 7, 4)
    elseif i== 9 then
      shapes[i]:shaderParameter("texture", tex2)
      shapes[i]:setTextureScale(4, 4)
      shapes[i]:mapCube(8)
    end
    shapes[i]:endShape()
    shapes[i]:shaderParameter("color", {1.0, 1.0, 1.0, 1.0})
    shapes[i]:shaderParameter("use_texture", 1)
  end
  return shapes
end

function changeShape(nodes, shape_no)
  g_totalVertices =  0
  g_totalTriangles = 0
  for i = 1, #nodes do
    s = nodes[i].obj:getShape(1)
    s:referShape(g_Shapes[shape_no])
    if i%2 == 0 then
      s:shaderParameter("use_texture", 1)
      s:shaderParameter("texture", g_tex)
      if shape_no == 9 then s:shaderParameter("texture", g_tex2) end
    end
    g_totalVertices = g_totalVertices + s:getVertexCount()
    g_totalTriangles = g_totalTriangles + s:getTriangleCount()
  end
end

function showHelp(text)
  local top = 6
  text:goTo(0, top)
  text:write("[q] Quit           [h] Show/Hide Help")
  text:goTo(0, top + 1)
  text:write("[f] Full Screen    [g] Resume Screen")
  text:goTo(0, top + 2)
  text:write("[t] Upper Right    [b] Lower Right")
  text:goTo(0, top + 3)
  text:write("[w]/[s] Rotate X   [a]/[d] Rotate Y")
  text:goTo(0, top + 4)
  text:write("[z] Move Near      [x] Move Far")
  text:goTo(0, top + 5)
  text:write("[p] Screenshot     [1]-[9] Change Shape")
  text:goTo(0, top + 6)
  text:write("Text Size : [j] = 1, [k] = 2, [l] = 3")
end

function hideHelp(text)
  local top = 6
  for i = top, top+6 do
    text:clearLine(i)
  end
end

  g_Quit = false
  g_totalVertices = 0
  g_totalTriangles = 0
  g_Help = true;
  g_Nodes = {}
  g_Shapes = {}


  local FontScale = 1.0
  g_Screen = Screen:new()
  g_Screen:init(-120, -80, 0, 0)

  local phong = Phong:new()
  phong:setDefaultParam("light", {0, 100, 1000, 1})
  phong:init()
  Shape.ClassShader(phong)

  local aspect = g_Screen.width / g_Screen.height
  local projMat = Matrix:new()
  projMat:makeProjectionMatrix(1, 1000, 53, aspect)
  phong:setProjectionMatrix(projMat)

  local aText = Text:new()
  aText:init("font512.png")
  local aSpace = Space:new()
  g_tex = Texture:new()
  g_tex:readImageFromFile("num512.png")
  g_tex2 = Texture:new()
  g_tex2:readImageFromFile("CubeMap_dice.png")

  g_Shapes = makeShapes()

  local numNodes = 40
  local nodes = g_Nodes
  for i = 1, numNodes do
    nodes[i] = {}                              -- Each nodes[] has two nodes.
    nodes[i].base = aSpace:addNode(nil, string.format("base%02d", i))
    nodes[i].obj = aSpace:addNode(nodes[i].base, string.format("obj%02d", i))
    nodes[i].base:setPosition(0, i*1.5, 0)
    nodes[i].obj:setPosition(0, 0, 22.0)

    local s = Shape:new()
    s:referShape(g_Shapes[1])
    s:shaderParameter("color", color(numNodes, i, 0))
    if i%2 == 0 then
      s:shaderParameter("use_texture", 1)
      s:shaderParameter("texture", g_tex)
    end
    nodes[i].obj:addShape(s)
    g_totalVertices = g_totalVertices + s:getVertexCount()
    g_totalTriangles = g_totalTriangles + s:getTriangleCount()
  end

  local eyeBase = aSpace:addNode(nil, "eyeBase")
  eyeBase:setPosition(0, 0, 0)
  local eye = aSpace:addNode(eyeBase, "eye")
  eye:setPosition(0, 30, 100)

  g_Screen:setClearColor(0.0, 0.0, 0.3, 1.0)
  aSpace:timerStart()
  aText:setScale(FontScale)
  aText:writeAt(0, 0, "LjES : A 3D Framework for LuaJIT")
  aText:writeAt(0, 1, "       running on Raspberry Pi")
  showHelp(aText)
  termios.getTermios()
  termios.setRawMode()

  while (g_Quit == false) and (g_Screen:getFrameCount() < 6000) do
    checkKey(eye, eyeBase, aText)
    g_Screen:clear()
    local count = g_Screen:getFrameCount()
    for i = 1, numNodes do
      nodes[i].base:rotateY(0.2*i)
      local s = nodes[i].obj:getShape(1)
      s:shaderParameter("color", color(numNodes, i, count))
      if i%2 == 0 then
        nodes[i].obj:rotateX(-2.0)
      else
        nodes[i].obj:rotateX(1.0)
      end
    end
    aSpace:draw(eye)

    aText:goTo(0,2)
    aText:write(string.format("FPS : %8.4f ", aSpace:count()/aSpace:uptime()))
    aText:goTo(0,3)
    aText:write(string.format("Vertices  : %d   ", g_totalVertices))
    aText:goTo(0,4)
    aText:write(string.format("Triangles : %d   ", g_totalTriangles))
    aText:drawScreen()
    g_Screen:update()
  end
  util.sleep(0.10)
  termios.restoreTermios()

