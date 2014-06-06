-- ---------------------------------------------
--  Animation.lua      2014/06/05
--   Copyright (c) 2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

require("Schedule")
require("Node")
local util = require("util")

Animation = Object:new()

function Animation.new(self, name)
  local obj = Object.new(self)
  obj.name = name
  obj.boneCount = 0
  obj.times = {}
  obj.poses = {}
  obj.boneNames = {}
  obj.diffPoses = {}
  obj.tasks = {}
  obj.schedule = Schedule:new()
  obj.skeleton = nil
  obj.endFrameIP = -1
  return obj
end

-- times = time of key frame[1 .. n]
function Animation.setTimes(self, times)
  self.times = times
end

-- bone_poses = mat, mat, ..
function Animation.setBonePoses(self, bone_poses)
  table.insert(self.poses, bone_poses)
  self.boneCount = #self.poses
  return #self.poses
end

function Animation.addBoneName(self, bone_name)
  table.insert(self.boneNames, bone_name)
end

function Animation.getBoneName(self, i)
  if #self.boneNames >= i then
    return self.boneNames[i]
  else
    return nil
  end
end

function Animation.getType(self)
  return self.type
end

function Animation.getName(self)
  return self.name
end

function Animation.countPoses(self)
  return #self.times
end

function Animation.getNoOfBones(self)
  return self.boneCount
end

function Animation.close(self)
end

local function difference(matA, matB)
  local quat
  local pos = {}
  local qA = Quat:new()
  local qB = Quat:new()
  local posA = matA:getPosition()
  local posB = matB:getPosition()
  qA:matrixToQuat(matA)
  qB:matrixToQuat(matB)
  local dp = qA:dotProduct(qB)
  if dp < 0 then qB:negate() end  -- shortest path
  qA:condugate()
  quat = qB:clone()
  quat:lmulQuat(qA)
  pos[1] = posB[1] - posA[1]
  pos[2] = posB[2] - posA[2]
  pos[3] = posB[3] - posA[3]
  return quat, pos
end

function Animation.setData(self, skeleton, bind_shape_matrix)
  local time
  local q, pos
  self.skeleton = skeleton
  local bsm = bind_shape_matrix:clone()
  local m = bsm.mat
  m[ 1], m[ 2] = m[ 2], -m[ 1]
  m[ 5], m[ 6] = m[ 6], -m[ 5]
  m[ 9], m[10] = m[10], -m[ 9]
  m[13], m[14] = m[14], -m[13]
  for i = 1, self:getNoOfBones() do
    local task = self.schedule:addTask(self.boneNames[i])
    local b = skeleton:getBone(self.boneNames[i])
    if b == nil then
      skeleton:printJointNames()
      skeleton:printBone()
      util.printf("skeleton:getBone(self.boneNames[%d]) is nil.\n", i)
    end
    task:setTargetObject(b)
    table.insert(self.tasks, task)
    if b.rootBone then
      util.printf("root bone = %s\n", self.boneNames[i])
      for key = 1, #self.times do
        self.poses[i][key]:lmul(bsm)
      end
    end
  end

  for key = 2, #self.times do
    time = (self.times[key] - self.times[key-1]) * 1000  -- msec
    for i = 1, self:getNoOfBones() do
      self.tasks[i]:addCommand(0, Node.putRotTransByMatrix,
                               {self.poses[i][key]})
      self.tasks[i]:addCommand(time, Node.doRotTrans, {1.0})
    end
  end
end

function Animation.appendData(self, time, key_frame_no)
  local q, pos
  local bone
  local bone_diff
  for i = 1, self:getNoOfBones() do
    bone = self.poses[i]
    local last_frame = #self.times
    q, pos = difference(bone[last_frame], bone[key_frame_no])
    bone_diff = {q, pos}
    table.insert(self.diffPoses, bone_diff)
    self.tasks[i]:addCommand(0, Node.putRotTrans, {q , pos})
    self.tasks[i]:addCommand(time, Node.doRotTrans, {1.0})
  end
end

function Animation.getPeriodFromTo(self, from, to)
  if (from < 1) or (from > #self.times) then return -1 end
  if (to < from) or (to > #self.times) then return -1 end
  return (self.times[to] - self.times[from]) * 1000
end

function Animation.setPose(self, key)
  for i = 1, self:getNoOfBones() do
    local b = self.skeleton:getBone(self.boneNames[i])
    b:setByMatrix(self.poses[i][key])
  end
end

function Animation.transitionTo(self, time, keyFrom, keyTo)
  local args = {}
  local ones = {}
  for i = 1, self:getNoOfBones() do
    table.insert(args, self.poses[i][keyFrom])  -- matrix
    table.insert(ones, 1.0)
  end
  self.schedule:directExecution(0, Node.putRotTransByMatrix, args)
  self.schedule:directExecution(time, Node.doRotTrans, ones,
                                keyFrom * 2 - 1, (keyTo - 1) * 2)
end

function Animation.start(self)
  self:setPose(1)
  self.schedule:startFrom(1)
end

function Animation.play(self)
  return self.schedule:doCommand()
end

function Animation.playFps(self, frame_per_sec)
  return self.schedule:doCommandFps(frame_per_sec)
end

function Animation.startFromTo(self, keyFrom, keyTo)
  self:setPose(keyFrom)
  self.schedule:startFromTo(keyFrom * 2 -1, (keyTo - 1) * 2)
end

function Animation.startTimeFromTo(self, time, keyFrom, keyTo)
  self:transitionTo(time, keyFrom, keyTo)
end

function Animation.list(self, print_matrix)
  local time
  local mat = Matrix:new()
  local q, pos
  local h, p, b

  util.printf("\nAnimetion:%s, No. of keyframe=%d\n", self.name, #self.times)
  for i = 1, self:getNoOfBones() do
    util.printf("[%02d]---- %s ----\n", i, self:getBoneName(i))
    for key = 1, #self.times do
      util.printf("[%6.2f]", self.times[key])
      mat:copyFrom(self.poses[i][key])
      if print_matrix then mat:print() end
      pos = mat:getPosition()
      h, p, b = mat:matToEuler()
      util.printf(" h:%8.3f p:%8.3f b:%8.3f ", h, p, b)
      util.printf(" x:%9.4f y:%9.4f z:%9.4f\n", unpack(pos))
    end
  end
end
