-- ---------------------------------------------
--  Space.lua      2014/02/16
--   Copyright (c) 2013-2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

local util = require "util"
require "Object"
require "Matrix"
require "Node"

Space = Object:new()

function Space.new(self)
  local obj = Object.new(self)
  obj.nodes = {}
  obj.roots = {}
  obj.skeletons = {}
  obj.light = nil
  local sec, usec = util.gettimeofday()
  obj.startTime = sec + usec/1000000
  obj.time = 0
  obj.elapsedTime = 0
  obj.drawCount = 0
  return obj
end

function Space.addNode(self, parent_node, name)
  local node = Node:new(parent_node, name)
  table.insert(self.nodes, node)
  if parent_node ~= nil then
    parent_node:addChild(node)
  end
  return node
end

function Space.delNode(self, name)
  local node = self:findNode(name)
  if (node) then
    for i=1, #self.nodes do
      if (self.nodes[i] == node) then
        table.remove(self.nodes, i)
      end
    end
  end
end

function Space.scanSkeletons(self)
  local shapes
  self.skeletons = {}
  for i=1, #self.nodes do
    shapes = self.nodes[i].shapes
    if #shapes > 0 then 
      for j=1, #shapes do
        local skeleton = shapes[j].skeleton
        if skeleton ~= nil then
          if skeleton:isAttachable() or skeleton:isShown() then
            table.insert(self.skeletons, skeleton)
          end
        end
      end
    end
  end
end

function Space.findNode(self, name)
  for i=1, #self.nodes do
    if (self.nodes[i].name == name) then
      return self.nodes[i]
    end
  end
  util.printf("%s not found!\n", name)
  return nil
end

function Space.listNode(self)
  function listChildNodes(children, level)
    if #children == 0 then return end
    for j=1, #children do
      local fmt = '%' .. tostring(level*4) .. 's%s'
      util.printf(fmt, ' ', children[j].name)
      listChildNodes(children[j].children, level + 1)
    end
  end

  for i=1, #self.nodes do
    if (self.nodes[i].parent == nil) then
      util.printf("%s\n", self.nodes[i].name)
      listChildNodes(self.nodes[i].children, 1)
    end
  end
end

function Space.now(self)
  local sec, usec = util.gettimeofday()
  return sec + usec/1000000
end

function Space.timerStart(self)
  self.startTime = self:now()
end

function Space.uptime(self)
  return self:now() - self.startTime
end

function Space.deltaTime(self)
  return self.elapsedTime
end

function Space.count(self)
  return self.drawCount
end

function Space.setLight(self, node)
  self.light = node
end

function Space.setEye(self, node)
  self.eye = node
end

function Space.draw(self, eye_node)
  local node
  local oldTime = self.time
  self.time = self.now()
  self.elapsedTime = self.time - oldTime

  if (eye_node == nil) and (self.eye ~= nil)then
    eye_node = self.eye
  end
  eye_node:setWorldMatrix()
  local view_matrix = Matrix:new()
  view_matrix:makeView(eye_node.matrix)

  for i=1, #self.nodes do
    node = self.nodes[i]
    if (node.parent == nil) then
      node:draw(view_matrix)
    end
  end
  self.drawCount = self.drawCount + 1
end

function Space.drawBones(self)
  if #self.skeletons == 0 then return end
  for i=1, #self.skeletons do
    self.skeletons[i]:drawBones()
  end
end
