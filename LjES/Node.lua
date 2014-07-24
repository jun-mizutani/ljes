-- ---------------------------------------------
--  Node.lua        2014/07/21
--   Copyright (c) 2013-2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

require("CoordinateSystem")

Node = CoordinateSystem:new(nil)      -- inherit CoordinateSystem

function Node.new(self, parent_bone, name)
  local obj = CoordinateSystem.new(self, parent_bone, name)
  obj.type = obj.NODE_T
  obj.modelViewMatrix = Matrix:new()
  obj.normalMatrix = Matrix:new()
  obj.attachable = false
  obj.restPos = {0.0, 0.0, 0.0}
  obj.restQuat = Quat:new()
  obj.restMatrix = Matrix:new()
  obj.bofMatrix = Matrix:new()
  obj.modelMatrix = Matrix:new()  -- for rest position
  obj.hasWeights = false
  if parent_bone ~= nil then
    obj.rootBone = false
  else
    obj.rootBone = true
  end
  obj.shapes = {}
  obj.hideShape = true
  return obj
end

-- override CoordinateSystem.setParent(self, parent)
function Node.setParent(self, parent)
  self.parent = parent
  if parent ~= nil then
    self.rootBone = false
  else
    self.rootBone = true
  end
end

function Node.hide(self, true_or_false)
  self.hideShape = true_or_false
  local shapes = self.shapes
  if #shapes > 0 then
    for i=1, #shapes do
      shapes[i]:hide(true_or_false)
    end
  end
end

function Node.setAttachable(self, true_or_false)
  self.attachable = true_or_false
end

function Node.detach(self)
  if (self.type == self.NODE_T) or self.attachable then
    CoordinateSystem.detach(self)
  end
end

function Node.attach(self, parent_node)
  if (self.type == self.NODE_T) or self.attachable then
    CoordinateSystem.attach(self, parent_node)
  end
end

function Node.setWeights(self)
  self.hasWeights = true
end

function Node.setRestPosition(self, x, y, z)
  self.restPos[1] = x
  self.restPos[2] = y
  self.restPos[3] = z
  self:setPosition(x, y, z)
end

function Node.setRestByMatrix(self, matrix)
  self.restMatrix:copyFrom(matrix)
  self.restQuat:matrixToQuat(matrix)
  self.restPos = self.matrix:getPosition()
end

function Node.rotateRest(self, head, pitch, bank)
  local qq = Quat:new()
  qq:eulerToQuat(head, pitch, bank)
  self.restQuat:mulQuat(qq)
  self.quat:copyFrom(self.restQuat)
end

function Node.moveRest(self, x, y, z)
  self:setRestMatrix()
  self.restPos = self.restMatrix:mulVector({x, y, z})
  self:setPosition(unpack(self.restPos))
end

function Node.setRestMatrix(self)
  self.restMatrix:setByQuat(self.restQuat)
  self.restMatrix:position(self.restPos)
end

-- for rest position
function Node.setModelMatrixAll(self, mmat)
  self:setRestMatrix()
  self.modelMatrix:copyFrom(self.restMatrix)
  if self.parent ~= nil then
    self.modelMatrix:lmul(mmat)                -- [Mn]=[J0]x[J1]x ..[Jn]
  end
  local children = self.children
  for j=1, #children do
    children[j]:setModelMatrixAll(self.modelMatrix)
  end
  self.bofMatrix:copyFrom(self.modelMatrix)
  self.bofMatrix:inverse()                     -- [Mn]^-1
end

-- for pose position
-- overide CoordinateSystem.setWorldMatrixAll(self, wmat)
function Node.setGlobalMatrixAll(self, wmat)
  -- self:setWorldMatrixAll(self, wmat)
  self.matrix:setByQuat(self.quat)
  self.matrix:position(self.position)
  self.worldMatrix:copyFrom(self.matrix)
  if self.rootBone == false and wmat ~= nil then
    self.worldMatrix:lmul(wmat)                -- [Cn] = [Q0] x ... x [Qn]
  end
  local children = self.children
  for j=1, #children do
    children[j]:setWorldMatrixAll(self.worldMatrix)
  end
end

function Node.getRestMatrix(self)
  return self.restMatrix:clone()
end

function Node.getModelMatrix(self)
  return self.modelMatrix:clone()
end

function Node.getBofMatrix(self)
  return self.bofMatrix:clone()
end

function Node.getGlobalMatrix(self)
  return self:getWorldMatrix()
end

function Node.addShape(self, shape)
  if shape == nil then
    util.printf("Error, try to add nil shape to %s.", self.name)
    return
  end
  table.insert(self.shapes, shape)
  if shape.skeleton == nil then return end
  local bones = shape.skeleton.bones
  if #bones > 0 then
    for i = 1, #bones do
      if bones[i].parent == nil then
        bones[i].parent = self
        self:addChild(bones[i])
      end
    end
  end
end

function Node.delShape(self)
  table.remove(self.shapes)
end

function Node.setShape(self, shape)
   self.shapes = {}
   self:addShape(shape)
end

function Node.getShape(self, n)
  if (n > #self.shapes) or (n <= 0) then
    return nil
  else
    return self.shapes[n]
  end
end

function Node.getShapeCount(self)
  return #self.shapes
end

function Node.draw(self, view_matrix, light_vec)
  if (self.type == self.BONE_T) and not self.attachable then
    return
  end

  local modelview = self.modelViewMatrix
  local normal = self.normalMatrix
  self:setMatrix()
  modelview:copyFrom(self.matrix)
  modelview:lmul(view_matrix)   --  eye = [view] * [model] * local
  normal:copyFrom(modelview)
  normal:position({0, 0, 0})

  if self.type == self.NODE_T then
    local shapes = self.shapes
    for i=1, #shapes do
      if light_vec ~= nil then
	 shapes[i]:shaderParameter("light", light_vec)
      end
      shapes[i]:draw(modelview, normal)
    end
  end

  local children = self.children
  for j=1, #children do
    children[j]:draw(modelview, light_vec)
  end
end

function Node.drawBones(self)
  local modelview = self.modelViewMatrix
  local normal = self.normalMatrix

  if self.type == self.BONE_T then
    local shapes = self.shapes
    for i=1, #shapes do
      shapes[i]:draw(modelview, normal)
    end
  end
  local children = self.children
  for j=1, #children do
    children[j]:drawBones()
  end
end
