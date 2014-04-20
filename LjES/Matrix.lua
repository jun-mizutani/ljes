-- ---------------------------------------------
-- Matrix.lua       2013/03/20
--   Copyright (c) 2013 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

--[[
  Matrix:new()
  Matrix:makeUnit()
  Matrix:set(row, column, val)
  Matrix:get(row, column)
  Matrix:copy()
  Matrix:convFloat()
  Matrix:setByQuat(quat)
  Matrix:setByEuler(head, pitch, bank)
  Matrix:matToEuler()
  Matrix:position(position)
  Matrix:getPosition()
  Matrix:mul(mb)
  Matrix:lmul(mb)
  Matrix:makeProjectionMatrix(near, far, hfov, ratio)
  Matrix:makeProjectionMatrixWH(near, far, width, height)
  Matrix:makeProjectionMatrixOrtho(near, far, width, height)
  Matrix:makeView(w)
  Matrix:tmul3x3Vector(v)
  Matrix:mul3x3Vector(v)
  Matrix:mulVector(v)
  Matrix:print()
]]

ffi = require "ffi"
require "Object"

local function RAD(degree)
  return degree * math.pi / 180.0
end

local function DEG(radian)
  return radian * 180.0 / math.pi
end

Matrix = Object:new()

function Matrix.new(self)
  local obj = Object.new(self)
  obj.mat = ffi.new("double[?]", 16, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0,
                                     0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
  return obj
end

function Matrix.makeUnit(self)
  for i=0, 15 do self.mat[i] = 0.0 end
  self.mat[0] = 1.0; self.mat[5] = 1.0
  self.mat[10]= 1.0; self.mat[15] = 1.0
end

function Matrix.set(self, row, column, val)
  self.mat[column * 4 + row] = val
end

function Matrix.get(self, row, column)
  return self.mat[column * 4 + row]
end

function Matrix.copy(self)
  local obj = Matrix:new()
  for i=0,15 do obj.mat[i] = self.mat[i] end
  return obj
end

function Matrix.convFloat(self)
  local fm4x4 = ffi.new("float[16]", 1)
  for i=0,15 do fm4x4[i] = self.mat[i] end
  return fm4x4
end

function Matrix.setByQuat(self, quat)
  local a = self.mat
  local q0 = quat.q[0]
  local q1 = quat.q[1]
  local q2 = quat.q[2]
  local q3 = quat.q[3]
  local q1_2 = q1 + q1
  local q2_2 = q2 + q2
  local q3_2 = q3 + q3
  local q01 = q0 * q1_2
  local q02 = q0 * q2_2
  local q03 = q0 * q3_2
  local q11 = q1 * q1_2
  local q12 = q1 * q2_2
  local q13 = q1 * q3_2
  local q22 = q2 * q2_2
  local q23 = q2 * q3_2
  local q33 = q3 * q3_2
  a[0] = 1 - (q22 + q33)  --  b11
  a[1] = q12 + q03        --  b21
  a[2] = q13 - q02        --  b31
  a[4] = q12 - q03        --  b12
  a[5] = 1 - (q11 + q33)  --  b22
  a[6] = q23 + q01        --  b32
  a[8] = q13 + q02        --  b13
  a[9] = q23 - q01        --  b23
  a[10]= 1 - (q11 + q22)  --  b33
  a[3] = 0.0; a[7] = 0.0; a[11] = 0.0;
  a[12] = 0.0; a[13] = 0.0; a[14] = 0.0; -- position
  a[15] = 1.0
end

function Matrix.setByEuler(self, head, pitch, bank)
  local a = self.mat
  local cosB = math.cos(RAD(bank ))
  local cosP = math.cos(RAD(pitch))
  local cosH = math.cos(RAD(head ))
  local sinB = math.sin(RAD(bank ))
  local sinP = math.sin(RAD(pitch))
  local sinH = math.sin(RAD(head ))

  local cosPcosB = cosB * cosP
  local sinPsinB = sinB * sinP
  local sinPcosB = cosB * sinP
  local cosPsinB = sinB * cosP

  a[0] = cosH*cosB - sinH*sinPsinB
  a[1] = cosH*sinB + sinPcosB*sinH
  a[2] = - cosP * sinH
  a[4] = - cosPsinB
  a[5] = cosPcosB
  a[6] = sinP
  a[8] = cosH * sinPsinB + cosB * sinH
  a[9] = sinH * sinB - cosH * sinPcosB
  a[10]= cosP * cosH
  a[3] = 0.0; a[7] = 0.0; a[11] = 0.0;
  a[12] = 0.0; a[13] = 0.0; a[14] = 0.0; -- position
  a[15] = 1.0
end

function Matrix.matToEuler(self)
  local rz = DEG(-math.atan(self.mat[4] / self.mat[5]))  --  bank
  local rx = DEG(math.asin(self.mat[6]))                 --  pitch
  local ry = DEG(-math.atan(self.mat[2] / self.mat[10])) --  head
  return ry, rx, rz             --  [head, pitch, bank]
end

-- position : {x, y, z}
function Matrix.position(self, position)
  self.mat[12] = position[1]
  self.mat[13] = position[2]
  self.mat[14] = position[3]
end

function Matrix.getPosition(self)
  return {self.mat[12], self.mat[13], self.mat[14]}
end

--  ma = ma * mb
--                             b0    b4    b8     b12
--                             b1    b5    b9     b13
--                             b2    b6    b10    b14
--                             b3(0) b7(0) b11(0) b15(1)
-- --------------------------+------------------------------
--  a0    a4    a8     a12     m0    m4    m8     m12
--  a1    a5    a9     a13     m1    m5    m9     m13
--  a2    a6    a10    a14     m2    m6    m10    m14
--  a3(0) a7(0) a11(0) a15(1)  m3    m7    m11    m15
function Matrix.mul(self, mb)
  local a = self.mat
  local a0 =a[ 0]; local a1 =a[ 1]; local a2 =a[ 2]; local a3 =a[ 3]
  local a4 =a[ 4]; local a5 =a[ 5]; local a6 =a[ 6]; local a7 =a[ 7]
  local a8 =a[ 8]; local a9 =a[ 9]; local a10=a[10]; local a11=a[11]
  local a12=a[12]; local a13=a[13]; local a14=a[14]; local a15=a[15]
  local b0 = mb.mat[ 0]; local b1 = mb.mat[ 1]
  local b2 = mb.mat[ 2]; local b3 = mb.mat[ 3]
  local b4 = mb.mat[ 4]; local b5 = mb.mat[ 5]
  local b6 = mb.mat[ 6]; local b7 = mb.mat[ 7]
  local b8 = mb.mat[ 8]; local b9 = mb.mat[ 9]
  local b10= mb.mat[10]; local b11= mb.mat[11]
  local b12= mb.mat[12]; local b13= mb.mat[13]
  local b14= mb.mat[14]; local b15= mb.mat[15]

  a[ 0] = a0 * b0 + a4 * b1 +  a8 * b2 + a12 * b3
  a[ 1] = a1 * b0 + a5 * b1 +  a9 * b2 + a13 * b3
  a[ 2] = a2 * b0 + a6 * b1 + a10 * b2 + a14 * b3
  a[ 3] = a3 * b0 + a7 * b1 + a11 * b2 + a15 * b3
  a[ 4] = a0 * b4 + a4 * b5 +  a8 * b6 + a12 * b7
  a[ 5] = a1 * b4 + a5 * b5 +  a9 * b6 + a13 * b7
  a[ 6] = a2 * b4 + a6 * b5 + a10 * b6 + a14 * b7
  a[ 7] = a3 * b4 + a7 * b5 + a11 * b6 + a15 * b7
  a[ 8] = a0 * b8 + a4 * b9 +  a8 * b10+ a12 * b11
  a[ 9] = a1 * b8 + a5 * b9 +  a9 * b10+ a13 * b11
  a[10] = a2 * b8 + a6 * b9 + a10 * b10+ a14 * b11
  a[11] = a3 * b8 + a7 * b9 + a11 * b10+ a15 * b11
  a[12] = a0 * b12+ a4 * b13+  a8 * b14+ a12 * b15
  a[13] = a1 * b12+ a5 * b13+  a9 * b14+ a13 * b15
  a[14] = a2 * b12+ a6 * b13+ a10 * b14+ a14 * b15
  a[15] = a3 * b12+ a7 * b13+ a11 * b14+ a15 * b15
  return self
end

--  ma = mb * ma
function Matrix.lmul(self, mb)
  local a = self.mat
  local a0 =a[ 0]; local a1 =a[ 1]; local a2 =a[ 2]
  local a4 =a[ 4]; local a5 =a[ 5]; local a6 =a[ 6]
  local a8 =a[ 8]; local a9 =a[ 9]; local a10=a[10]
  local a12=a[12]; local a13=a[13]; local a14=a[14]
  local b0 =mb.mat[ 0]; local b1 =mb.mat[ 1]; local b2 =mb.mat[ 2]
  local b4 =mb.mat[ 4]; local b5 =mb.mat[ 5]; local b6 =mb.mat[ 6]
  local b8 =mb.mat[ 8]; local b9 =mb.mat[ 9]; local b10=mb.mat[10]
  local b12=mb.mat[12]; local b13=mb.mat[13]; local b14=mb.mat[14]

  a[ 0] = b0 * a0 + b4 * a1 +  b8 * a2
  a[ 1] = b1 * a0 + b5 * a1 +  b9 * a2
  a[ 2] = b2 * a0 + b6 * a1 + b10 * a2
  a[ 4] = b0 * a4 + b4 * a5 +  b8 * a6
  a[ 5] = b1 * a4 + b5 * a5 +  b9 * a6
  a[ 6] = b2 * a4 + b6 * a5 + b10 * a6
  a[ 8] = b0 * a8 + b4 * a9 +  b8 * a10
  a[ 9] = b1 * a8 + b5 * a9 +  b9 * a10
  a[10] = b2 * a8 + b6 * a9 + b10 * a10
  a[12] = b0 * a12+ b4 * a13+  b8 * a14+ b12
  a[13] = b1 * a12+ b5 * a13+  b9 * a14+ b13
  a[14] = b2 * a12+ b6 * a13+ b10 * a14+ b14
  return self
end

--  set Projection Matrix
--  fov = Horizontal field of view angle (degree)
--  r = Width / Height
--  w = 2n/Width, h = 2n/Height
--
--   2n/w    0      0         0
--     0   2n/h     0         0
--     0     0  -(f+n)/(f-n) -2fn/(f-n)
--     0     0     -1         0
function Matrix.makeProjectionMatrix(self, near, far, hfov, ratio)
  local w = 1.0 / math.tan(hfov * 0.5 * math.pi / 180)
  local h = w * ratio
  local q = 1.0 / (far - near)

  self:makeUnit()
  self.mat[0] = w
  self.mat[5] = h
  self.mat[10]= -(far + near) * q
  self.mat[11]= -1.0
  self.mat[14]= -2 * far * near * q
  self.mat[15]= 0.0
end

function Matrix.makeProjectionMatrixWH(self, near, far, width, height)
  local q = 1.0 / (far - near)
  self:makeUnit()
  self.mat[0] = 2 * near / width
  self.mat[5] = 2 * near / height
  self.mat[10]= -(far + near) * q
  self.mat[11]= -1.0
  self.mat[14]= -2 * far * near * q
  self.mat[15]= 0.0
end

--  Orthographic
function Matrix.makeProjectionMatrixOrtho(self, near, far, width, height)
  local q = 1.0 / (far - near)
  self:makeUnit()
  self.mat[0] = 2.0 / (width*2)
  self.mat[5] = 2.0 / (height*2)
  self.mat[10]= -2 * q
  self.mat[14]= (far + near) * q
end

--  w : model matrix (local to world)
function Matrix.makeView(self, w)
  local m = self.mat
  local w12 = w.mat[12]
  local w13 = w.mat[13]
  local w14 = w.mat[14]
  --  transposed matrix
  m[0]=w.mat[0]; m[4]=w.mat[1]; m[8]=w.mat[2]
  m[1]=w.mat[4]; m[5]=w.mat[5]; m[9]=w.mat[6]
  m[2]=w.mat[8]; m[6]=w.mat[9]; m[10]=w.mat[10]
  --  copy
  m[7] = w.mat[7]
  m[3] = w.mat[3]
  m[11] = w.mat[11]
  --  translation
  m[12] = -(m[0]*w12 + m[4]*w13 + m[8]*w14)
  m[13] = -(m[1]*w12 + m[5]*w13 + m[9]*w14)
  m[14] = -(m[2]*w12 + m[6]*w13 + m[10]*w14)
  m[15] =  w.mat[15]
end

-- v : {x, y, z}
function Matrix.tmul3x3Vector(self, v)
  local m = self.mat
  local x = m[0]*v[1]+m[1]*v[2]+m[2]*v[3]
  local y = m[4]*v[1]+m[5]*v[2]+m[6]*v[3]
  local z = m[8]*v[1]+m[9]*v[2]+m[10]*v[3]
  return {x, y, z}
end

-- v : {x, y, z}
function Matrix.mul3x3Vector(self, v)
  local m = self.mat
  local x = m[0]*v[1]+m[4]*v[2]+m[8]*v[3]
  local y = m[1]*v[1]+m[5]*v[2]+m[9]*v[3]
  local z = m[2]*v[1]+m[6]*v[2]+m[10]*v[3]
  return {x, y, z}
end

-- v : {x, y, z}
function Matrix.mulVector(self, v)
  local m = self.mat
  local x = m[0]*v[1]+m[4]*v[2]+m[8]*v[3]+m[12]
  local y = m[1]*v[1]+m[5]*v[2]+m[9]*v[3]+m[13]
  local z = m[2]*v[1]+m[6]*v[2]+m[10]*v[3]+m[14]
  local w = m[3]*v[1]+m[7]*v[2]+m[11]*v[3]+m[15]
  return {x/w, y/w, z/w}
end

function Matrix.print(self)
  local m = self.mat
  local fmt = "% 16.11e % 16.11e % 16.11e % 16.11e"
  print( string.format(fmt, m[0], m[4], m[8],  m[12]))
  print( string.format(fmt, m[1], m[5], m[9],  m[13]))
  print( string.format(fmt, m[2], m[6], m[10], m[14]))
  print( string.format(fmt, m[3], m[7], m[11], m[15]))
end

