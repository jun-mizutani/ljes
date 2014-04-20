-- ---------------------------------------------
--  Space.lua      2013/04/10
--   Copyright (c) 2013 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

--[[
  Space:new()
  Space:addNode(parent_node, name)
  Space:delNode(name)
  Space:findNode(name)
  Space:listNode()
  Space:now()
  Space:timerStart()
  Space:uptime()
  Space:deltaTime()
  Space:count()
  Space:setLight(node)
  Space:setEye(node)
  Space:draw(eye_node)
]]

local util = require "util"
require "Object"
require "Matrix"
require "Node"

Space = Object:new()

function Space.new(self)
  local obj = Object.new(self)
  obj.nodes = {}
  obj.roots = {}
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
    table.insert(parent_node.children, node)
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

function Space.findNode(self, name)
  for i=1, #self.nodes do
    if (self.nodes[i].name == name) then
      return self.nodes[i]
    end
  end
  print(name .. " not found!\n")
  return nil
end

function Space.listNode(self)
  function listChildNodes(children, level)
    if #children == 0 then return end
    for j=1, #children do
      local fmt = '%' .. tostring(level*4) .. 's%s'
      print(string.format(fmt, ' ', children[j].name))
      listChildNodes(children[j].children, level + 1)
    end
  end

  for i=1, #self.nodes do
    if (self.nodes[i].parent == nil) then
      print(self.nodes[i].name)
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
