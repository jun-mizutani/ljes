-- ---------------------------------------------
--  CoordinateSystem.lua  2014/06/05
--   Copyright (c) 2013-2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

require("Matrix")
require("Quat")
local util = require("util")

CoordinateSystem = Object:new()
CoordinateSystem.COORD_T = 0
CoordinateSystem.NODE_T = 1
CoordinateSystem.BONE_T = 2

function CoordinateSystem.new(self, parent_node, name)
  local obj = Object.new(self)
  obj.name = name
  obj.parent = parent_node
  obj.children = {}
  obj.type = CoordinateSystem.COORD_T
  obj.matrix = Matrix:new()
  obj.worldMatrix = Matrix:new()
  obj.position = {0, 0, 0}
  obj.quat = Quat:new()
  obj.dirty = true
  obj.accumulatedRatio = 0
  obj.startRotation = Quat:new()
  obj.endRotation = Quat:new()
  obj.startPosition = {}
  obj.transDistance = {}
  return obj
end

function CoordinateSystem.print(self, str, q, pos)
  util.printf("%s h:%8.3f p:%8.3f b:%8.3f ", str, q:quatToEuler())
  util.printf(" x:%9.4f y:%9.4f z:%9.4f\n", unpack(pos))
end

function CoordinateSystem.printMoveRange(self)
  self:print("start", self.startRotation, self.startPosition)
  self:print("end  ", self.endRotation, self.transDistance)
end

function CoordinateSystem.setType(self, type)
  self.type = type
end

function CoordinateSystem.getType(self)
  return self.type
end

function CoordinateSystem.addChild(self, child)
  table.insert(self.children, child)
end

function CoordinateSystem.getNoOfChildren(self)
  return #self.children
end

function CoordinateSystem.getChild(self, n)
  if n > #self.children then
    return nil
  else
    return self.children[n]
  end
end

function CoordinateSystem.setParent(self, parent)
  self.parent = parent
end

function CoordinateSystem.getParent(self)
  return self.parent
end

function CoordinateSystem.setName(self, name)
  self.name = name
end

function CoordinateSystem.getName(self)
  return self.name
end

function CoordinateSystem.setAttitude(self, head, pitch, bank)
  self.quat:eulerToQuat(head, pitch, bank)
  self.dirty = true
end

function CoordinateSystem.getWorldAttitude(self)
  self:setWorldMatrix()
  return self.worldMatrix:matToEuler()
end

function CoordinateSystem.getLocalAttitude(self)
  self:setMatrix()
  return self.matrix:matToEuler()
end

function CoordinateSystem.getWorldPosition(self)
  self:setWorldMatrix()
  return self.worldMatrix:getPosition()
end

function CoordinateSystem.getPosition(self)
  return self.position
end

function CoordinateSystem.setPosition(self, x, y, z)
  self.position[1] = x
  self.position[2] = y
  self.position[3] = z
end

function CoordinateSystem.setPositionX(self, x)
  self.position[1] = x
end

function CoordinateSystem.setPositionY(self, y)
  self.position[2] = y
end

function CoordinateSystem.setPositionZ(self, z)
  self.position[3] = z
end

function CoordinateSystem.rotateX(self, degree)
  local qq = Quat:new()
  qq:setRotateX(degree)
  self.quat:mulQuat(qq)
  self.dirty = true
end

function CoordinateSystem.rotateY(self, degree)
  local qq = Quat:new()
  qq:setRotateY(degree)
  self.quat:mulQuat(qq)
  self.dirty = true
end

function CoordinateSystem.rotateZ(self, degree)
  local qq = Quat:new()
  qq:setRotateZ(degree)
  self.quat:mulQuat(qq)
  self.dirty = true
end

function CoordinateSystem.rotate(self, head, pitch, bank)
  local qq = Quat:new()
  qq:eulerToQuat(head, pitch, bank)
  self.quat:mulQuat(qq)
  self.dirty = true
end

function CoordinateSystem.move(self, x, y, z)
  self:setMatrix()
  self.position = self.matrix:mulVector({x, y, z})
end

function CoordinateSystem.setMatrix(self)
  if self.dirty then
    self.matrix:setByQuat(self.quat)
    self.dirty = false
  end
  self.matrix:position(self.position)
end

function CoordinateSystem.setWorldMatrix(self)
  local parent = self.parent
  self:setMatrix()
  if (parent) then
    parent:setWorldMatrix()
    self.worldMatrix = self.matrix:clone()
    self.worldMatrix:lmul(parent.worldMatrix)
  else
    self.worldMatrix = self.matrix:clone()
  end
end

function CoordinateSystem.setWorldMatrixAll(self, wmat)
  self.matrix:setByQuat(self.quat)
  self.matrix:position(self.position)
  self.worldMatrix:copyFrom(self.matrix)
  if self.parent ~= nil and wmat ~= nil then
    self.worldMatrix:lmul(wmat)                -- [Cn] = [Q0] x ... x [Qn]
  end
  local children = self.children
  for j=1, #children do
    children[j]:setWorldMatrixAll(self.worldMatrix)
  end
end

function CoordinateSystem.getWorldMatrix(self)
  self:setWorldMatrix()
  return self.worldMatrix:clone()
end

function CoordinateSystem.setByMatrix(self, matrix)
  self.matrix:copyFrom(matrix)
  self.quat:matrixToQuat(matrix)
  self.position = self.matrix:getPosition()
end

function CoordinateSystem.setQuat(self, quat)
  self.quat = quat
end

function CoordinateSystem.getQuat(self)
  return self.quat
end

function CoordinateSystem.getQuatFromMatrix(self)
  local quat = Quat:new()
  quat:matrixToQuat(self.matrix)
  return quat
end

function CoordinateSystem.getPositionFromMatrix(self)
  return self.matrix:getPosition()
end

function CoordinateSystem.detach(self)
  local parent = self.parent
  if (parent~=nil) then
    self:setWorldMatrix()
    self.quat:matrixToQuat(self.worldMatrix)
    self.position = self.worldMatrix:getPosition()
    self.dirty = true
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

function CoordinateSystem.attach(self, parent_node)
  local q = Quat:new()
  if ((self.parent == nil) and (parent_node)) then
    local p = parent_node:getWorldPosition()
    local r = self:getWorldPosition()
    q:matrixToQuat(parent_node.worldMatrix)
    q:condugate()
    self.quat:matrixToQuat(self.worldMatrix)
    self.quat:lmulQuat(q)
    self.position[1] = r[1] - p[1]
    self.position[2] = r[2] - p[2]
    self.position[3] = r[3] - p[3]
    self.position = parent_node.worldMatrix:tmul3x3Vector(self.position)
    self.parent = parent_node
    table.insert(parent_node.children, self)
    self.dirty = true
  end
end

function CoordinateSystem.inverse(self, new_parent)
  if (self.parent) then
    local p = self.parent
    self:detach()
    p:inverse(self)
  end
  self:attach(new_parent)
end

function CoordinateSystem.distance(self, node)
  local a = self:getWorldPosition()
  local b = node:getWorldPosition()
  local x = b[1] - a[1]
  local y = b[2] - a[2]
  local z = b[3] - a[3]
  return math.sqrt(x * x + y * y + z * z)
end

function CoordinateSystem.putRotation(self, head, pitch, bank)
  self.accumulatedRatio = 0
  local qq = Quat:new()
  qq:eulerToQuat(head, pitch, bank)
  self.startRotation:copyFrom(self.quat)
  self.endRotation:copyFrom(self.quat)
  self.endRotation:mulQuat(qq)
end

function CoordinateSystem.putRotationByQuat(self, quat)
  self.accumulatedRatio = 0
  self.startRotation:copyFrom(self.quat)
  self.endRotation:copyFrom(self.quat)
  self.endRotation:mulQuat(quat)
end

function CoordinateSystem.putAttitudeByQuat(self, quat)
  self.accumulatedRatio = 0
  self.startRotation:copyFrom(self.quat)
  self.endRotation:copyFrom(quat)
end

function CoordinateSystem.putAttitude(self, head, pitch, bank)
  self.accumulatedRatio = 0
  self.startRotation:copyFrom(self.quat)
  self.endRotation:eulerToQuat(head, pitch, bank)
end

function CoordinateSystem.putDistance(self, x, y, z)
  self.accumulatedRatio = 0
  self.startPosition = { unpack(self.position) }
  self.transDistance = {x, y, z}
end

function CoordinateSystem.putRotTrans(self, quat, pos)
  self.accumulatedRatio = 0
  self.startRotation:copyFrom(self.quat)
  self.endRotation:copyFrom(self.quat)
  self.endRotation:mulQuat(quat)
  self.startPosition = { unpack(self.position) }
  self.transDistance = { unpack(pos) }
end

function CoordinateSystem.putRotTransByMatrix(self, matrix)
  self.accumulatedRatio = 0
  self.startRotation:copyFrom(self.quat)
  self.endRotation:matrixToQuat(matrix)
  self.startPosition = { unpack(self.position) }
  local endPosition = matrix:getPosition()
  for i=1, 3 do
    self.transDistance[i] = endPosition[i] - self.startPosition[i]
  end
end

function CoordinateSystem.execRotation(self, t)
  self.quat:slerp(self.startRotation, self.endRotation, t)
  self.dirty = true
end

function CoordinateSystem.execTranslation(self, t)
  local distance = self.transDistance
  local pos = self.startPosition
  self.position[1] = pos[1] + distance[1] * t
  self.position[2] = pos[2] + distance[2] * t
  self.position[3] = pos[3] + distance[3] * t
end

function CoordinateSystem.doRotation(self, t)
  self.accumulatedRatio = self.accumulatedRatio + t
  local accum = self.accumulatedRatio
  self:execRotation(accum)
end

function CoordinateSystem.doTranslation(self, t)
  self.accumulatedRatio = self.accumulatedRatio + t
  local accum = self.accumulatedRatio
  self:execTranslation(accum)
end

function CoordinateSystem.doRotTrans(self, t)
  self.accumulatedRatio = self.accumulatedRatio + t
  local accum = self.accumulatedRatio
  self:execRotation(accum)
  self:execTranslation(accum)
end

