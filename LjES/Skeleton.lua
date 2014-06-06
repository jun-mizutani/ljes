-- ---------------------------------------------
--  Skeleton.lua       2014/06/06
--   Copyright (c) 2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

local ffi = require("ffi")
require("Node")

Skeleton = Object:new()

function Skeleton.new(self)
  local obj = Object.new(self)
  obj.MAX_BONE = 40
  obj.bones = {}
  obj.attachable = false
  obj.boneOrder = {}
  obj.allJointNames = {}
  obj.boneNo = 0
  obj.boneShape = nil
  obj.matrixPalette = ffi.new("float[40 * 3 * 4]", {})
  obj.show = false
  return obj
end

function Skeleton.clone(self)
  local skel = Skeleton:new()
  local num = 0
  skel:setBoneOrder(self.boneOrder)

  local function copyBoneToBone(src_bone, parent)
    if num < self.MAX_BONE then
      num = num + 1
      local bone = skel:addBone(parent, src_bone.name)
      bone:setRestByMatrix(src_bone.restMatrix)
      bone:setByMatrix(src_bone.restMatrix)
      bone.hasWeights = src_bone.hasWeights
      if #src_bone.children > 0 then
        for i=1, #src_bone.children do
          copyBoneToBone(src_bone.children[i], bone)
        end
      end
    end
  end
  copyBoneToBone(self.bones[1], nil)
  skel:bindRestPose()
  return skel
end

function Skeleton.addBone(self, parent_bone, name)
  local bone = Node:new(parent_bone, name)
  bone:setType(bone.BONE_T)
  if self.boneShape ~= nil then
    bone:addShape(self.boneShape)
  end
  table.insert(self.bones, bone)
  self.boneNo = #self.bones
  if parent_bone ~= nil then
    table.insert(parent_bone.children, bone)
  end
  return bone
end

function Skeleton.setBoneShape(self, shape)
  self.boneShape = shape
  if #self.bones == 0 then return end
  for i=1, #self.bones do
    self.bones[i]:setShape(self.boneShape)
  end
end

function Skeleton.setAttachable(self, true_or_false)
  self.attachable = true_or_false
  if #self.bones == 0 then return end
  for i=1, #self.bones do
    self.bones[i]:setAttachable(true_or_false)
  end
end

function Skeleton.isAttachable(self)
  return self.attachable
end

function Skeleton.isShown(self)
  return self.show
end

function Skeleton.showBone(self, true_or_false)
  self.show = true_or_false
  if #self.bones == 0 then return end
  for i=1, #self.bones do
    local bone = self.bones[i]
    bone:hide(not true_or_false)
    if true_or_false then
      bone:setAttachable(true)
    else
      bone:setAttachable(self.attachable)
    end
  end
end

function Skeleton.setBoneOrder(self, names)
  self.allJointNames = names
  local nBones = #names
  if nBones > self.MAX_BONE then nBones = self.MAX_BONE end
  for i=1, nBones do
    for j=1, #self.bones do
      if self.bones[j].name == names[i] then
        table.insert(self.boneOrder, self.bones[j])
      end
    end
  end
  return self.boneOrder
end

function Skeleton.getBoneOrder(self)
  return self.boneOrder
end

function Skeleton.getBoneNo(self, name)
  for i=1, #self.bones do
    if self.bones[i].name == name then
      return i - 1
    end
  end
  util.printf("Bone [%s] not found. (getBoneNo)\n", name)
  return nil
end

function Skeleton.getBoneCount(self)
  return #self.bones
end

function Skeleton.getBone(self, name)
  for i=1, #self.bones do
    if self.bones[i].name == name then
      return self.bones[i]
    end
  end
  util.printf("Bone [%s] not found.(getBone)\n", name)
  return nil
end

-- num : Matrix palette No. can exceeds 39, starting at 0
function Skeleton.getBoneFromJointNo(self, num)
  if #self.boneOrder > 0 then
    local bone_name = self.allJointNames[num + 1]
    return self:getBone(bone_name)
  else
    return self.bones[num + 1]
  end
end

function Skeleton.printJointNames(self)
  util.printf("#self.allJointNames = %4d\n", #self.allJointNames)
  for i = 1, #self.allJointNames do
    util.printf("%4d  %s\n", i-1, self.allJointNames[i])
  end
end

function Skeleton.printBone(self)
  util.printf("#self.bones = %4d\n", #self.bones)
  for i=1, #self.bones do
    util.printf("%4d  %s\n", i, self.bones[i].name)
  end
end

function Skeleton.getJointFromBone(self, bone)
  if #self.allJointNames > 0 then
    for i = 1, #self.allJointNames do
      if bone.name == self.allJointNames[i] then
        return (i-1)  -- starting at 0
      end
    end
  else
    return self:getBoneNoFromBone(bone)
  end
  return nil
end

function Skeleton.getBoneNoFromBone(self, bone)
  if #self.bones > 0 then
    for i=1, #self.bones do
      if self.bones[i] == bone then
        return (i-1)  -- starting at 0
      end
    end
  end
  return nil
end

function Skeleton.bindRestPose(self)
  for i=1, #self.bones do
    local bone = self.bones[i]
    if bone.rootBone then
      bone:setModelMatrixAll(nil)
    end
  end
end

function Skeleton.updateMatrixPalette(self)
  local wm = Matrix:new()
  for i=1, #self.bones do
    local bone = self.bones[i]
    if bone.rootBone then
      bone:setGlobalMatrixAll(nil)
    end
  end
  local nBones = #self.boneOrder
  if nBones > 0 then
    for i=1, nBones do
      wm:copyFrom(self.boneOrder[i].worldMatrix)
      wm:mul(self.boneOrder[i].bofMatrix) -- [Pallete_n] = [Cn] x [Mn]^-1

      local n = (i-1) * 12
      for j=0, 2 do
        local k = n + j * 4
        self.matrixPalette[k ]    = wm.mat[j]
        self.matrixPalette[k + 1] = wm.mat[j+4]
        self.matrixPalette[k + 2] = wm.mat[j+8]
        self.matrixPalette[k + 3] = wm.mat[j+12]
      end
    end
  else                                      -- if #self.boneOrder == 0
    nBones = #self.bones
    if nBones > self.MAX_BONE then nBones = self.MAX_BONE end
    for i=1, nBones do
      wm:copyFrom(self.bones[i].worldMatrix)
      wm:mul(self.bones[i].bofMatrix)   -- [Pallete_n] = [Cn] x [Mn]^-1
      local n = (i-1) * 12
      for j=0, 2 do
        local k = n + j * 4
        self.matrixPalette[k ]    = wm.mat[j]
        self.matrixPalette[k + 1] = wm.mat[j+4]
        self.matrixPalette[k + 2] = wm.mat[j+8]
        self.matrixPalette[k + 3] = wm.mat[j+12]
      end
    end
  end
  return self.matrixPalette
end

function Skeleton.listBones(self)
  self:updateMatrixPalette()
  for i=1, #self.bones do
    local bone = self.bones[i]
    util.printf("--- [%d] : %s\n", i, bone.name)
    util.printf("<<rest local>>\n")
    bone.restMatrix:print()
    util.printf("<<model>>\n")
    bone.modelMatrix:print()
    util.printf("<<bone offset>>\n")
    bone.bofMatrix:print()
    util.printf("<<world>>\n")
    bone.worldMatrix:print()
    util.printf("<<local>>\n")
    bone.matrix:print()
    local pos = bone:getPosition()
    util.printf(" x:% 12.5f, y:% 12.5f, z:% 12.5f\n",
               pos[1], pos[2], pos[3])
    local h, p, b = bone:getLocalAttitude()
    util.printf(" h:% 12.5f, p:% 12.5f, b:% 12.5f\n", h, p, b)
  end
end

function Skeleton.printMatrixPalette(self)
  self:bindRestPose()
  local m = self:updateMatrixPalette()
  self:listBones()
  util.printf("\n")

  local nBones = #self.boneOrder
  if nBones > 0 then
    if nBones > self.MAX_BONE then nBones = self.MAX_BONE end
    for i=1, nBones do
      local bone = self.boneOrder[i]
      local k = (i-1) * 16
      util.printf("------- Pallete [%2d  %s] --------\n", i, bone.name)
      local fmt = "% 16.11e % 16.11e % 16.11e % 16.11e\n"
      util.printf(fmt, m[k+0], m[k+4], m[k+8],  m[k+12])
      util.printf(fmt, m[k+1], m[k+5], m[k+9],  m[k+13])
      util.printf(fmt, m[k+2], m[k+6], m[k+10], m[k+14])
      util.printf(fmt, m[k+3], m[k+7], m[k+11], m[k+15])
    end
  else
    for i=1, #self.bones do
      local k = (i-1) * 16
      util.printf("------- Pallete [%2d] --------\n", i)
      local fmt = "% 16.11e % 16.11e % 16.11e % 16.11e\n"
      util.printf(fmt, m[k+0], m[k+4], m[k+8],  m[k+12])
      util.printf(fmt, m[k+1], m[k+5], m[k+9],  m[k+13])
      util.printf(fmt, m[k+2], m[k+6], m[k+10], m[k+14])
      util.printf(fmt, m[k+3], m[k+7], m[k+11], m[k+15])
    end
  end
end

function Skeleton.drawBones(self, view_matrix)
  local bone
  if self.show == false then return end
  if #self.bones > 0 then
    for i=1, #self.bones do
      bone = self.bones[i]
      if bone.rootBone then bone:drawBones() end
    end
  end
end
