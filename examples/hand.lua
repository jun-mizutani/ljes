#!/usr/bin/luajit
-- ---------------------------------------------
-- hand.lua     2014/03/30
--   Copyright (c) 2014 Jun Mizutani,
--   released under the MIT open source license.
--
-- Finger-counting, Collada animation and Action.
-- ---------------------------------------------

-- usage
--   $ luajit hand.lua

package.path = "../LjES/?.lua;" .. package.path

local demo = require("demo")
require("ColladaShape")
require("Schedule")
require("Action")

-- globals
local TEXTUTE_FILE = ""
local COLLADA_FILE = "hand.dae"
local g_totalVertices = 0
local g_totalTriangles = 0
local skeletons = {}
local bones = {}
local BONE = 1
local MESH = 1
local MAXBONE = 1
local HELP = false
local MAXMESH = 1
local anim_stopped = false
local shapes

demo.screen(0, 0)
local aSpace = demo.getSpace()
local eye = aSpace:addNode(nil, "eye")

function setBoneParams()
  bones = skeletons[MESH]
  if bones then MAXBONE = #bones end
end

function showBones(node, true_or_false)
  for i = 1, node:getShapeCount() do
    local shape = node:getShape(i)
    local skeleton = shape:getSkeleton()
    skeleton:showBone(true_or_false)
  end
  demo.aSpace:scanSkeletons()
end

function createBoneShape(size, r, g, b)
  local shape = Shape:new()
  shape:simpleBone(size)
  shape:shaderParameter("color", {r, g, b, 1.0})
  return shape
end

-- --------------------------------------------------------------------
-- main
-- --------------------------------------------------------------------

  demo.backgroundColor(0.2, 0.2, 0.4)

  -- texture
  if TEXTUTE_FILE ~= "" then
    require("Texture")
    tex = Texture:new()
    tex:readImageFromFile(TEXTUTE_FILE)
  end
  local start = aSpace:now()
  local boneFlag = true
  local verboseFlag = false

  -- load collada
  local collada = ColladaShape:new()
  local collada_text = util.readFile(COLLADA_FILE)
  collada:parse(collada_text ,verboseFlag)
  shapes = collada:makeShapes(boneFlag, verboseFlag)
  collada:releaseMeshes()
  for i = 1, #shapes do
    shapes[i]:releaseObjects()
  end
  shapes[1].anim:list()

  MAXMESH = #shapes

  -- print loading time
  local time = aSpace:now() - start
  util.printf("loading time = %f sec \n", time)

  local node = aSpace:addNode(nil, "node1")
  node:setPosition(0, 0, 0)
  local fig = aSpace:addNode(node, "fig")
  fig:setPosition(0, 0, 0)
  fig:setAttitude(0, 0, 0)

  -- set bone shape
  local size = demo.getShapeSize(shapes)
  local bone_shape = createBoneShape(size.max/70, 1, 1, 1)

  -- set eye position
  eye:setPosition(size.centerx, size.centery, size.max * 1.2)

  for i = 1, #shapes do
    local shape = shapes[i]
    local skeleton = shape:getSkeleton()
    if (skeleton ~= nil) and (skeleton:getBoneCount() > 0) then
      skeleton:setBoneShape(bone_shape)
      table.insert(skeletons, skeleton:getBoneOrder())
    else
      util.printf("No skeleton")
    end

    fig:addShape(shape)
    shape:shaderParameter("ambient", 0.4) 
    shape:shaderParameter("specular", 0.2)
    shape:shaderParameter("power", 20)
    if TEXTUTE_FILE ~= "" then
      shape:shaderParameter("use_texture", 1)
      shape:shaderParameter("texture", tex)
      shape:shaderParameter("color", {1.0, 1.0, 1.0, 1.0})
    else
      shape:shaderParameter("use_texture", 0)
      shape:shaderParameter("color", {0.9, 0.75, 0.75, 1.0})
    end
    util.printf("object vertex#=%d  triangle#=%d\n", shape:getVertexCount(),
                shape:getTriangleCount())
    g_totalVertices = g_totalVertices + shape:getVertexCount()
    g_totalTriangles = g_totalTriangles + shape:getTriangleCount()
  end

  demo.aText:setScale(1)
  setBoneParams()
  action = Action:new(fig.shapes[1].anim)
  action:addKeyPattern("N1", 500, 3, 4)
  action:addKeyPattern("N2", 500, 5, 6)
  action:addKeyPattern("N3", 500, 7, 8)
  action:addKeyPattern("N4", 500, 9, 10)
  action:addKeyPattern("N5", 500, 11, 12)
  action:addKeyPattern("N0", 500, 13, 14)

  action:addAction("N1", {1})
  action:addAction("N2", {2})
  action:addAction("N3", {3})
  action:addAction("N4", {4})
  action:addAction("N5", {5})
  action:addAction("N0", {6})

  action:startAction("N0")

-- --------------------------------------------
--  [1][2][3][4][5][6][7][8][9][0][-][^][\]
--   [Q][W][e][r][T][y][u][I][o][P][@]
--    [A][S][D][F][G][h][J][K][l]
--     [Z][X][c][v][B][n][m][,][.][/]
-- --------------------------------------------
function keyFunc(key)
  local ROT = 1.0
  local MOV = 0.3
  local t = demo.aText
  if key ~= string.char(0) then
    demo.messageColor(1.0, 0, 0)
    demo.messageFontScale(2)
    local str = string.format("[%1s]", key)
    demo.messageWrite(30, 0, str)
  end
  if (key == 'h') then
    t:clearScreen()
    if HELP then HELP = false else HELP = true end
  elseif (key == 'w') then node:rotateX(ROT)
  elseif (key == 's') then node:rotateX(-ROT)
  elseif (key == 'a') then node:rotateY(ROT)
  elseif (key == 'd') then node:rotateY(-ROT)
  elseif (key == 'z') then node:rotateZ(ROT)
  elseif (key == 'x') then node:rotateZ(-ROT)

  elseif (key == 'j') then
    BONE = BONE - 1
    if BONE < 1 then BONE = 1 end
  elseif (key == 'k') then
    BONE = BONE + 1
    if BONE > MAXBONE then BONE = MAXBONE end
  elseif (key == 'o') then fig.shapes[MESH]:hide(true)
  elseif (key == 'i') then fig.shapes[MESH]:hide(false)
  elseif (key == 'm') then
    MESH = MESH + 1
    if MESH > MAXMESH then MESH = MAXMESH end
    setBoneParams()
    if BONE > MAXBONE then BONE = MAXBONE end
  elseif (key == 'n') then
    MESH = MESH - 1 if MESH < 1 then MESH = 1 end
    setBoneParams()
    if BONE > MAXBONE then BONE = MAXBONE end
  elseif (key == '1') then action:startAction("N1") 
  elseif (key == '2') then action:startAction("N2")
  elseif (key == '3') then action:startAction("N3")
  elseif (key == '4') then action:startAction("N4")
  elseif (key == '5') then action:startAction("N5")
  elseif (key == '6') then action:startAction("N0")
  elseif (key == '9') then showBones(fig, true)
  elseif (key == '0') then showBones(fig, false)
  elseif (key == '@') then
    fig.shapes[1].anim:start()
    anim_stopped = false
  elseif (key == '/') then
    fig.shapes[1].anim:transitionTo(1000, 1, -1)
  -- BONE は MESH に依存することに注意
  elseif bones ~= nil then
    if (key == 'e') then bones[BONE]:rotateX(ROT)
    elseif (key == 'r') then bones[BONE]:rotateX(-ROT)
    elseif (key == 'c') then bones[BONE]:rotateZ(ROT)
    elseif (key == 'v') then bones[BONE]:rotateZ(-ROT)
    elseif (key == 'y') then bones[BONE]:rotateY(ROT)
    elseif (key == 'u') then bones[BONE]:rotateY(-ROT)
    end
  end
  return key
end

function draw_help()
  local t = demo.aText
  t:writeAt(3, 3, "+     -")
  t:writeAt(2, 4, "[w] - [s]  : rotate X")
  t:writeAt(2, 5, "[a] - [d]  : rotate Y")
  t:writeAt(2, 6, "[z] - [x]  : rotate Z")
  t:writeAt(0, 7, "Bone")
  t:writeAt(2, 8, "[e] - [r]  : rotate X")
  t:writeAt(2, 9, "[c] - [v]  : rotate Z")
  t:writeAt(2,10, "[y] - [u]  : rotate Y")
  t:writeAt(2,12, "[n] - [m]  : select Mesh")
  t:writeAt(2,13, "[j] - [k]  : select Bone")
  t:writeAt(2,14, "[o] - [i]  : hide / show")
  t:writeAt(2,15, "[0] - [9]  : hide/show bones")
  t:writeAt(2,16, "[p]  : Screenshot")
  t:writeAt(2,17, "[t]  : on top")
  t:writeAt(2,18, "[b]  : on bottom")
  t:writeAt(2,19, "[g]  : initial screen")
  t:writeAt(2,20, "[f]  : full screen ")
  t:writeAt(2,21, "[h]  : help on/off ")
  t:writeAt(2,22, "[@]  : Replay animation")
  t:writeAt(2,24, "[q]  : QUIT")
end

local g_count = 0

function draw()
  local t = demo.aText
  if HELP then
    draw_help()
  else
    t:writefAt(0, 3, "Vertices  :%6d", g_totalVertices)
    t:writefAt(0, 4, "Triangles :%6d", g_totalTriangles)
    t:writeAt(2, 21, "[h]  : help on/off ")
  end

  action:playAction()

  aSpace:draw(eye)
  if bones ~= nil and bones[BONE] ~= nil then
    t:writefAt(0, 2, "Mesh:%2d/%2d   Bone:%2d/%2d [%s]        ",
          MESH, MAXMESH, BONE, MAXBONE, bones[BONE].name)
  else
    t:writefAt(0,2, "Mesh:%2d/%2d   Bone:%2d/%2d           ",
          MESH, MAXMESH, BONE, MAXBONE)
  end
  t:writefAt(20, 0, "Finger-counting. Hit [1] - [6]")
  demo.messageDraw()
end

  demo.loop(draw, true, keyFunc)
  demo.exit()

