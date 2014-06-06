-- ---------------------------------------------
--  Frame.lua      2014/06/05
--  treat <node> elements of COLLADA format
--   Copyright (c) 2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

require("CoordinateSystem")
local util = require("util")

Frame = CoordinateSystem:new(nil)

function Frame.new(self, parent, name)
  local obj = CoordinateSystem.new(self, parent)
  obj.name = name
  obj.usedAsBone = false
  obj.boneCount = 0
  obj.hasMesh = false
  obj.bofMatrix = Matrix:new()
  obj.type = ""
  if parent then
    parent:addChild(obj)
  end
  return obj
end

-- override CoordinateSystem.setByMatrix
function Frame.setByMatrix(self, matrix)
  self.matrix:copyFrom(matrix)
  self.quat:matrixToQuat(matrix)
  self.position = self.matrix:getPosition()
end

function Frame.setWeights(self)
  self.hasWeights = true
end

function Frame.setType(self, type_name)
  self.type = type_name
end

function Frame.getType(self)
  return self.type
end

function Frame.getName(self)
  return self.name
end

function Frame.findFrame(self, name)
  if self.name == name then return self end
  if #self.children > 0 then
    for i=1, #self.children do
      local frame = self.children[i]:findFrame(name)
      if frame then return frame end
    end
  end
  return nil
end

function Frame.getNoOfBones(self, names)
  local count = 0
  if #self.children > 0 then
    for i = 1, #self.children do
      count = count + self.children[i]:getNoOfBones(names)
    end
  end
  for i = 1, #names do
    if names[i] == self.name then
      count = count + 1
      break
    end
  end
  return count
end

function Frame.findChildFrames(self, names)
  for i = 1, #names do
    if names[i] == self.name then return self end
  end
  if #self.children > 0 then
    local frame
    for i = 1, #self.children do
      frame = self.children[i]:findChildFrames(names)
      if frame ~= nil then return frame end
    end
  end
  return nil
end

function Frame.getFramesFromNames(self, joint_names)
  local frames = {}
  local frame
  for i = 1, #joint_names do
    frame = self:findFrame(joint_names[i])
    table.insert(frames, frame)
  end
  return frames
end

function Frame.copyToBone(self, joint_names, bind_shape_matrix,
                          skeleton, parent_bone, count, verbose)
  if not self:findChildFrames(joint_names) then return end

  local bone
  if self.type == "JOINT" then
    if parent_bone == nil then
      local bsm = bind_shape_matrix:clone()
      local m = bsm.mat
      m[ 1], m[ 2] = m[ 2], -m[ 1]
      m[ 5], m[ 6] = m[ 6], -m[ 5]
      m[ 9], m[10] = m[10], -m[ 9]
      m[13], m[14] = m[14], -m[13]
      self.matrix:lmul(bsm)
    end
    bone = skeleton:addBone(parent_bone, self.name)
    if verbose then
      util.printf("bones[%2d] %s\n", skeleton:getBoneCount(), self.name)
    end
    bone:setByMatrix(self.matrix)
    bone:setRestByMatrix(self.matrix)
    if self.hasWeights then bone:setWeights() end
  end
  if #self.children > 0 then
    for i=1, #self.children do
      self.children[i]:copyToBone(joint_names, bind_shape_matrix,
                                  skeleton, bone, count, verbose)
    end
  end
  return
end

function Frame.list(self, level)
  local pos, pos2
  local q = Quat:new()
  local h, p, b
  local head = string.rep("+", level)
  local left = string.rep(" ", level)

  util.printf("%snode:%s  type=%s\n", head, self.name, self.type)
  -- local matrix
  self.matrix:print()
  pos2 = self:getPosition()
  util.printf("%slocal x:% 12.5f, y:% 12.5f, z:% 12.5f\n", left,
               pos2[1], pos2[2], pos2[3])
  h, p, b = self:getLocalAttitude()
  util.printf("%s      h:% 12.5f, p:% 12.5f, b:% 12.5f\n", left, h, p, b)
  q = self:getQuat()
  --util.printf("%s      q0:% 10.5f, q1:% 10.5f, q2:% 10.5f, q3:% 10.5f\n\n",
  --               left, q.q[0], q.q[1], q.q[2], q.q[3])
end

function Frame.listAll(self, level)
   self:list(level)
  if self.children then
    for i=1, #self.children do
      self.children[i]:listAll(level + 1)
    end
  end
end

