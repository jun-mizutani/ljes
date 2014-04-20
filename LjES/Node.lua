-- ---------------------------------------------
--  Node.lua        2013/04/04
--   Copyright (c) 2013 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

--[[
  Node:new(parent_node, name)
  Node:addShape(shape)
  Node:delShape()
  Node:getShape(n)
  Node:draw(view_matrix)
  Node:setAttitude(head, pitch, bank)
  Node:getWorldAttitude()
  Node:getLocalAttitude()
  Node:setPosition(x, y, z)
  Node:setPositionX(x)
  Node:setPositionY(y)
  Node:setPositionZ(z)
  Node:rotateX(degree)
  Node:rotateY(degree)
  Node:rotateZ(degree)
  Node:rotate(head, pitch, bank)
  Node:move(x, y, z)
  Node:setMatrix()
  Node:setWorldMatrix()
  Node:detach()
  Node:attach(parent_node)
  Node:inverse(new_parent)
  Node:distance(node)
  Node:getWorldPosition()
]]

require "Object"
require "Matrix"
require "Quat"

Node = Object:new()

function Node.new(self, parent_node, name)
  local obj = Object.new(self)
  obj.name = name
  obj.parent = parent_node
  obj.children = {}
  obj.matrix = Matrix:new()
  obj.wp = {0, 0, 0}
  obj.quat = Quat:new()
  obj.shapes = {}
  return obj
end

function Node.addShape(self, shape)
  if shape ~= nil then
    table.insert(self.shapes, shape)
  else
    print(string.format("Error try to add nil shape to %s", self.name))
  end
end

function Node.delShape(self)
  table.remove(self.shapes)
end

function Node.getShape(self, n)
  if (n > #self.shapes) or (n <= 0) then
    return nil
  else
    return self.shapes[n]
  end
end

function Node.draw(self, view_matrix)
  self:setMatrix()
  local modelview = self.matrix:copy()
  modelview:lmul(view_matrix)      --  eye = [view] * [model] * local
  local normal = modelview:copy()
  normal:position({0, 0, 0})

  local shapes = self.shapes
  for i=1, #shapes do
    shapes[i]:draw(modelview, normal)
  end

  local children = self.children
  for j=1, #children do
    children[j]:draw(modelview)
  end
end

function Node.setAttitude(self, head, pitch, bank)
  self.quat:eulerToQuat(head, pitch, bank)
end

function Node.getWorldAttitude(self)
  self:setWorldMatrix()
  return self.matrix:matToEuler()
end

function Node.getLocalAttitude(self)
  self:setMatrix()
  return self.matrix:matToEuler()
end

function Node.setPosition(self, x, y, z)
  self.wp[1] = x
  self.wp[2] = y
  self.wp[3] = z
end

function Node.setPositionX(self, x)
  self.wp[1] = x
end

function Node.setPositionY(self, y)
  self.wp[2] = y
end

function Node.setPositionZ(self, z)
  self.wp[3] = z
end

function Node.rotateX(self, degree)
  local qq = Quat:new()
  qq:setRotateX(degree)
  self.quat:mulQuat(qq)
end

function Node.rotateY(self, degree)
  local qq = Quat:new()
  qq:setRotateY(degree)
  self.quat:mulQuat(qq)
end

function Node.rotateZ(self, degree)
  local qq = Quat:new()
  qq:setRotateZ(degree)
  self.quat:mulQuat(qq)
end

function Node.rotate(self, head, pitch, bank)
  local qq = Quat:new()
  qq:eulerToQuat(head, pitch, bank)
  self.quat:mulQuat(qq)
end

function Node.move(self, x, y, z)
  self:setMatrix()
  self.wp = self.matrix:mulVector({x, y, z})
end

function Node.setMatrix(self)
  self.matrix:setByQuat(self.quat)
  self.matrix:position(self.wp)
end

function Node.setWorldMatrix(self)
  local parent = self.parent
  self:setMatrix()
  if (parent) then
    parent:setWorldMatrix()
    self.matrix:lmul(parent.matrix)
  end
end

function Node.detach(self)
  local parent = self.parent
  if (parent~=nil) then
    self:setWorldMatrix()
    self.quat:matrixToQuat(self.matrix)
    self.wp = self.matrix:getPosition()
    if (#parent.children > 0) then
      for i=1, #parent.children do
        if (parent.children[i] == self) then
          table.remove(parent.children, i)
        end
      end
    end
    self.parent = nil
  end
end

function Node.attach(self, parent_node)
  local q = Quat:new()
  if ((self.parent == nil) and (parent_node)) then
    local p = parent_node:getWorldPosition()
    local r = self:getWorldPosition()
    q:matrixToQuat(parent_node.matrix)
    q:condugate()
    self.quat:matrixToQuat(self.matrix)
    self.quat:lmulQuat(q)
    self.wp[1] = r[1] - p[1]
    self.wp[2] = r[2] - p[2]
    self.wp[3] = r[3] - p[3]
    self.wp = parent_node.matrix:tmul3x3Vector(self.wp)
    self.parent = parent_node
    table.insert(parent_node.children, self)
  end
end

function Node.inverse(self, new_parent)
  if (self.parent) then
    local p = self.parent
    self:detach()
    p:inverse(self)
  end
  self:attach(new_parent)
end

function Node.distance(self, node)
  local a = self:getWorldPosition()
  local b = node:getWorldPosition()
  local x = b[1] - a[1]
  local y = b[2] - a[2]
  local z = b[3] - a[3]
  return math.sqrt(x * x + y * y + z * z)
end

function Node.getWorldPosition(self)
  self:setWorldMatrix()
  return self.matrix:getPosition()
end

