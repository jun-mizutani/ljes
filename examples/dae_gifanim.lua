#!/usr/bin/luajit
-- ---------------------------------------------
-- dae_gifanim.lua     2014/03/30
--   Copyright (c) 2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

-- usage
--   $ luajit dae_gifanim.lua collada.dae texture.png
--   $ convert -delay 3 ss_*.png dae_anim.gif

package.path = "../LjES/?.lua;" .. package.path

local demo = require("demo")
require("ColladaShape")
require("Schedule")

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

function setBoneParams()
  bones = skeletons[MESH]
  if bones then MAXBONE = #bones end
end

function showBones(true_or_false)
  for i = 1, #shapes do
    local shape = shapes[i]
    local skeleton = shape:getSkeleton()
    skeleton:showBone(true_or_false)
  end
  demo.aSpace:scanSkeletons()
end

function createBoneShape(a, r, g, b)
  local shape = Shape:new()
  shape:simpleBone(a)
  shape:shaderParameter("color", {r, g, b, 1.0})
  return shape
end

-- --------------------------------------------------------------------
-- main
-- --------------------------------------------------------------------

  if arg[1] ~= nil then COLLADA_FILE = arg[1] end
  if arg[2] ~= nil then TEXTUTE_FILE = arg[2] end

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
  if shapes[1].anim ~= nil then
    shapes[1].anim:list()
  end
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
  local size =  demo.getShapeSize(shapes)
  local bone_shape = createBoneShape(size.max/100, 1, 1, 1)

  -- set eye position
  local eye = aSpace:addNode(nil, "eye")
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
    if TEXTUTE_FILE ~= "" then
      shape:shaderParameter("use_texture", 1)
      shape:shaderParameter("texture", tex)
      shape:shaderParameter("color", {1.0, 1.0, 1.0, 1.0})
    else
      shape:shaderParameter("use_texture", 0)
      shape:shaderParameter("color", {0.8, 0.7, 0.6, 1.0})
    end
    util.printf("object vertex#=%d  triangle#=%d\n", shape:getVertexCount(),
                shape:getTriangleCount())
    g_totalVertices = g_totalVertices + shape:getVertexCount()
    g_totalTriangles = g_totalTriangles + shape:getTriangleCount()
  end

  demo.aText:setScale(1)
  setBoneParams()

-- --------------------------------------------
--  [1][2][3][4][5][6][7][8][9][0][-][^][\]
--   [Q][W][e][r][T][y][u][I][o][P][@]
--    [A][S][D][F][G][h][J][K][l]
--     [Z][X][c][v][B][n][m][,][.][/]
-- --------------------------------------------
function keyFunc(key)
  local ROT = 1.0
  local MOV = 0.3

  if (key == 'h') then
    demo.aText:clearScreen()
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
  elseif (key == '1') then eye:move( MOV, 0, 0)
  elseif (key == '2') then eye:move(-MOV, 0, 0)
  elseif (key == '3') then eye:move( 0, MOV, 0)
  elseif (key == '4') then eye:move( 0,-MOV, 0)
  elseif (key == '5') then eye:move( 0, 0, MOV)
  elseif (key == '6') then eye:move( 0, 0,-MOV)
  elseif (key == '9') then showBones(true)
  elseif (key == '0') then showBones(false)
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

  --node:rotateY(0.5)

  if fig.shapes[1].anim ~= nil then
    local running = fig.shapes[1].anim:playFps(33)
    if running < 0 then fig.shapes[1].anim:start() end
  end
  aSpace:draw(eye)
  demo.aScreen:screenShot(string.format("ss_%03d.png", g_count))
  g_count = g_count + 1
  if bones ~= nil and bones[BONE] ~= nil then
    t:writefAt(0, 2, "Mesh:%2d/%2d   Bone:%2d/%2d [%s]        ",
          MESH, MAXMESH, BONE, MAXBONE, bones[BONE].name)
    t:writefAt(40, 0, "World H:%6.2f, P:%6.2f, B:%6.2f",
        bones[BONE]:getWorldAttitude())
    t:writefAt(46, 1, "X:%6.2f, Y:%6.2f, Z:%6.2f",
                unpack(bones[BONE]:getWorldPosition()))
    t:writefAt(40, 2, "Local h:%6.2f, p:%6.2f, b:%6.2f",
        bones[BONE]:getLocalAttitude())
    t:writefAt(46, 3, "x:%6.2f, y:%6.2f, z:%6.2f",
                unpack(bones[BONE]:getPosition()))
    --[[
    t:writefAt(40, 5, "Node  H:%6.2f, P:%6.2f, B:%6.2f",
                      fig:getWorldAttitude())
    t:writefAt(46, 6, "X:%6.2f, Y:%6.2f, Z:%6.2f",
                      unpack(fig:getWorldPosition()))
    --]]
  else
    t:writefAt(0,2, "Mesh:%2d/%2d   Bone:%2d/%2d           ",
          MESH, MAXMESH, BONE, MAXBONE)
  end
end

  --showBones(true)
  if fig.shapes[1].anim ~= nil then
    fig.shapes[1].anim:start()
  end
  demo.loop(draw, true, keyFunc)
  demo.exit()

