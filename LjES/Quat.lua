-- ---------------------------------------------
-- Quat.lua        2014/03/05
--   Copyright (c) 2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

ffi  = require "ffi"
util = require "util"

require "Object"

local function RAD(degree)
  return degree * math.pi / 180.0
end

local function DEG(radian)
  return radian * 180.0 / math.pi
end

Quat = Object:new()

function Quat.new(self)
  local obj = Object.new(self)
  obj.q = ffi.new("double[?]", 4, 1.0, 0.0, 0.0, 0.0)
  return obj
end

--  qa = qa * qb
function Quat.mulQuat(self, qb)
  local q0 = self.q[0]
  local q1 = self.q[1]
  local q2 = self.q[2]
  local q3 = self.q[3]
  local b0 = qb.q[0]
  local b1 = qb.q[1]
  local b2 = qb.q[2]
  local b3 = qb.q[3]
  self.q[0] = q0 * b0 - q1 * b1 - q2 * b2 - q3 * b3
  self.q[1] = q0 * b1 + q1 * b0 + q2 * b3 - q3 * b2
  self.q[2] = q0 * b2 + q2 * b0 - q1 * b3 + q3 * b1
  self.q[3] = q0 * b3 + q3 * b0 + q1 * b2 - q2 * b1
end

--  qa = qb * qa
function Quat.lmulQuat(self, qb)
  local q0 = self.q[0]
  local q1 = self.q[1]
  local q2 = self.q[2]
  local q3 = self.q[3]
  local b0 = qb.q[0]
  local b1 = qb.q[1]
  local b2 = qb.q[2]
  local b3 = qb.q[3]
  self.q[0] = b0 * q0 - b1 * q1 - b2 * q2 - b3 * q3
  self.q[1] = b0 * q1 + b1 * q0 + b2 * q3 - b3 * q2
  self.q[2] = b0 * q2 + b2 * q0 - b1 * q3 + b3 * q1
  self.q[3] = b0 * q3 + b3 * q0 + b1 * q2 - b2 * q1
end

--  q0 + q1i + q2j + q3k (w = q0)
function Quat.condugate(self)
  --  self.q[0] =  self.q[0]
  self.q[1] = -self.q[1]
  self.q[2] = -self.q[2]
  self.q[3] = -self.q[3]
end

function Quat.normalize(self)
  local q0 = self.q[0]
  local q1 = self.q[1]
  local q2 = self.q[2]
  local q3 = self.q[3]

  local s = math.sqrt(q0*q0 + q1*q1 + q2*q2 + q3*q3)
  self.q[0] = q0 / s
  self.q[1] = q1 / s
  self.q[2] = q2 / s
  self.q[3] = q3 / s
end

function Quat.setRotateX(self, degree)
  local r = RAD(degree) * 0.5
  self.q[0] = math.cos(r)
  self.q[1] = math.sin(r)
  self.q[2] = 0.0
  self.q[3] = 0.0
end

function Quat.setRotateY(self, degree)
  local r = RAD(degree) * 0.5
  self.q[0] = math.cos(r)
  self.q[1] = 0.0
  self.q[2] = math.sin(r)
  self.q[3] = 0.0
end

function Quat.setRotateZ(self, degree)
  local r = RAD(degree) * 0.5
  self.q[0] = math.cos(r)
  self.q[1] = 0.0
  self.q[2] = 0.0
  self.q[3] = math.sin(r)
end

--  convert into Quaternion from Euler Angle(Eest Up North)
function Quat.eulerToQuat(self, head, pitch, bank)
  local cosB = math.cos(RAD(bank ) * 0.5)
  local cosP = math.cos(RAD(pitch) * 0.5)
  local cosH = math.cos(RAD(head ) * 0.5)
  local sinB = math.sin(RAD(bank ) * 0.5)
  local sinP = math.sin(RAD(pitch) * 0.5)
  local sinH = math.sin(RAD(head ) * 0.5)

  local cosBcosP = cosB * cosP
  local sinBsinP = sinB * sinP
  local cosBsinP = cosB * sinP
  local sinBcosP = sinB * cosP

  self.q[0] = cosBcosP * cosH - sinBsinP * sinH
  self.q[1] = cosBsinP * cosH - sinBcosP * sinH
  self.q[2] = cosBcosP * sinH + sinBsinP * cosH
  self.q[3] = sinBcosP * cosH + cosBsinP * sinH
end

function Quat.dotProduct(self, qr)
  local dp = 0
  for i=0, 3 do
    dp = dp + self.q[i] * qr.q[i]
  end
  return dp
end

function Quat.negate(self)
  local q = self.q
  q[0] = -q[0]
  q[1] = -q[1]
  q[2] = -q[2]
  q[3] = -q[3]
end

--  Spherical Linear Iterporation
--  a,b : quaternion, t : 0.0 - 1.0
--  aQuat:slerp(a, b, t)
function Quat.slerp(self, a, b, t)
  local cosp = a.q[0]*b.q[0] + a.q[1]*b.q[1] + a.q[2]*b.q[2] + a.q[3]*b.q[3]
  local p = math.acos(cosp)
  local sinp = math.sin(p)

  local s = sinp
  if (sinp < 0.0) then s = -sinp end

  if (s > 0.0002) then  -- 0.01146 degree
    local scale0 = math.sin((1.0 - t) * p) / sinp
    local scale1 = math.sin(t * p) / sinp
    for i=0, 3 do
      self.q[i] = scale0 * a.q[i] + scale1 * b.q[i]
    end
  else
    for i=0, 3 do
      self.q[i] = b.q[i]
    end
  end
end

function Quat.matrixToQuat(self, m)
  local S
  if (m.mat[0] + m.mat[5] + m.mat[10] > -1.0) then
    self.q[0] = math.sqrt(m.mat[0] + m.mat[5] + m.mat[10] + 1)/2
    S = 4 * self.q[0]
    if (S ~= 0.0) then
      self.q[1] = (m.mat[6] - m.mat[9])/S
      self.q[2] = (m.mat[8] - m.mat[2])/S
      self.q[3] = (m.mat[1] - m.mat[4])/S
    end
  else
    local i = 0
    if (m.mat[5] > m.mat[0]) then
      i=1
      if (m.mat[10] > m.mat[5]) then  i=2 end
    elseif (m.mat[10] > m.mat[0]) then i=2 end

    if (i==0) then
        self.q[1] = math.sqrt(1 + m.mat[0] - m.mat[5] - m.mat[10])/2
        S = 4 * self.q[1]
        if (S ~= 0.0) then
          self.q[0] = (m.mat[6] - m.mat[9])/S
          self.q[2] = (m.mat[4] + m.mat[1])/S
          self.q[3] = (m.mat[8] + m.mat[2])/S
        end
    elseif (i==1) then
        self.q[2] = math.sqrt(1 -m.mat[0] + m.mat[5] - m.mat[10])/2
        S = 4 * self.q[2]
        if (S ~= 0.0) then
          self.q[0] = (m.mat[8]-m.mat[2])/S
          self.q[1] = (m.mat[4]+m.mat[1])/S
          self.q[3] = (m.mat[9]+m.mat[6])/S
        end
    elseif (i==2) then
        self.q[3] = math.sqrt(1 -m.mat[0] - m.mat[5] + m.mat[10])/2
        S = 4 * self.q[3]
        if (S ~= 0.0) then
          self.q[0] = (m.mat[1] - m.mat[4])/S
          self.q[1] = (m.mat[8] + m.mat[2])/S
          self.q[2] = (m.mat[9] + m.mat[6])/S
        end
    end
  end
  self:normalize()
end

function Quat.print(self)
  local q = self.q
  util.printf("% 16.11e % 16.11e % 16.11e % 16.11e\n", q[0], q[1], q[2], q[3])
end

function Quat.clone(self)
   local quat = Quat:new()
  for i=0,3 do quat.q[i] = self.q[i] end
  return quat
end

function Quat.copyFrom(self, quat)
  for i=0,3 do self.q[i] = quat.q[i] end
end

function Quat.check(self)
  local q = self.q
  local nan = false
  for i=0,3 do
    if (q[i]~=q[i]) then nan = true break end
  end
  if nan then
    self:print()
    assert(false, "NaN")
  end
end

function Quat.quatToEuler(self)
  local mat = Matrix:new()
  mat:setByQuat(self)
  return mat:matToEuler()  -- return head, pitch, bank
end
