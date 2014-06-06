-- ---------------------------------------------
-- Shape.lua       2014/06/05
--   Copyright (c) 2013-2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

local ffi = require("ffi")
local gl  = require("gles2")
local util = require("util")

require("Skeleton")

Shape = Object:new()

function Shape.new(self)
  local obj = Object.new(self)
  obj.isHidden = false
  obj.tx_mode = 0    -- sphere
  obj.tx_axis = 0
  obj.tx_su =   1.0
  obj.tx_sv =   1.0
  obj.tx_offu = 0.0
  obj.tx_offv = 0.0
  obj.vertexCount = 0
  obj.positionArray  = {}
  obj.normalArray  = {}
  obj.indicesArray   = {}
  obj.texCoordsArray = {}
  obj.altVertices  = {}
  obj.shaderParam = {}
  obj.vbo = 0
  obj.vObj = nil
  obj.ibo = 0
  obj.iObj = nil
  obj.indexCount = 0
  obj.hasSkeleton = false
  obj.skeleton = nil
  obj.bindex = {}
  obj.weight = {}
  obj.autoCalcNormals = true
  obj.box = {
    minx = 1.0E10, maxx = -1.0E10,
    miny = 1.0E10, maxy = -1.0E10,
    minz = 1.0E10, maxz = -1.0E10
  }
  obj.anim = nil
  return obj
end

function Shape.ClassShader(shader)
  Shape.shader = shader    -- set Shader class instance
end

function Shape.ClassTexture(texture)
  Shape.texture = texture  -- set Texture class instance
end

function Shape.updateBoundingBox(self, x, y, z)
  local box = self.box
  if box.minx > x then box.minx = x end
  if box.maxx < x then box.maxx = x end
  if box.miny > y then box.miny = y end
  if box.maxy < y then box.maxy = y end
  if box.minz > z then box.minz = z end
  if box.maxz < z then box.maxz = z end
end

function Shape.getBoundingBox(self)
  return self.box
end

function Shape.printBoundingBox(self)
  local bbox = self.box
  util.printf(" X: %10.5f -- %10.5f    center:%10.5f, size:%10.5f\n",
    bbox.minx, bbox.maxx, (bbox.maxx+bbox.minx)/2, bbox.maxx - bbox.minx)
  util.printf(" Y: %10.5f -- %10.5f    center:%10.5f, size:%10.5f\n",
    bbox.miny, bbox.maxy, (bbox.maxy+bbox.miny)/2, bbox.maxy - bbox.miny)
  util.printf(" Z: %10.5f -- %10.5f    center:%10.5f, size:%10.5f\n",
    bbox.minz, bbox.maxz, (bbox.maxz+bbox.minz)/2, bbox.maxz - bbox.minz)
end

function Shape.setAutoCalcNormals(self, flag)
  self.autoCalcNormals = flag
end

function Shape.referShape(self, shape)
  self.vbo = shape.vbo
  self.ibo = shape.ibo
  self.indexCount = shape.indexCount
  self.vertexCount = shape.vertexCount
end

function Shape.copyShaderParamsFromShape(self, shape)
  util.copyTable(self.shaderParam, shape.shaderParam)
end

function Shape.setAnimation(self, anim)
  self.anim = anim
end

function Shape.getAnimation(self)
  return self.anim -- if no animation exists then return nil.
end

function Shape.getVertexCount(self)
  return self.vertexCount
end

function Shape.getTriangleCount(self)
  return self.indexCount / 3
end

function Shape.shaderParameter(self, key, value)
  self.shaderParam[key] = value
end

function Shape.setShader(self, shader)
  self.shader = shader     -- set Shader class instance
end

function Shape.setTexture(self, texture)
  self.texture = texture   -- set Texture class instance
end

function Shape.setTextureMappingMode(self, mode)
  self.tx_mode = mode
end

function Shape.setTextureMappingAxis(self, axis)
  self.tx_axis = axis
end

function Shape.setTextureScale(self, scale_u, scale_v)
  self.tx_su = scale_u
  self.tx_sv = scale_v
end

function Shape.endShape(self)
  if self.autoCalcNormals then
    -- Normalize normal vectors.
    local x, y, z, d
    for i=1, #self.normalArray do
      x, y, z = unpack(self.normalArray[i])
      d = math.sqrt(x * x + y * y + z * z)
      if (d > 0.0) then
        self.normalArray[i] = {x/d, y/d, z/d}
      end
    end
  end
  -- Create Vertex Buffer Object.
  if self.hasSkeleton then
    local vObj_len = self.vertexCount * 16
    self.vObj = ffi.new("float[?]", vObj_len)
    for i = 1, self.vertexCount do
      local j = (i-1) * 16
      self.vObj[j   ] = self.positionArray[i][1]
      self.vObj[j+ 1] = self.positionArray[i][2]
      self.vObj[j+ 2] = self.positionArray[i][3]
      self.vObj[j+ 3] = self.normalArray[i][1]
      self.vObj[j+ 4] = self.normalArray[i][2]
      self.vObj[j+ 5] = self.normalArray[i][3]
      self.vObj[j+ 6] = self.texCoordsArray[i][1]
      self.vObj[j+ 7] = self.texCoordsArray[i][2]

      local boneNumber = self.bindex[i]
      local weight = self.weight[i]
      local n = #boneNumber
      local default = -1
      for k = 1, n do          -- n <= 4
        if (default < 0) and (boneNumber[k] < 40) then
          default = boneNumber[k]
        end
        if boneNumber[k] < 40 then
          self.vObj[j+ 8 + (k-1)] = boneNumber[k]
          self.vObj[j+12 + (k-1)] = weight[k]
        else
          self.vObj[j+ 8 + (k-1)] = default
          self.vObj[j+12 + (k-1)] = weight[k]
        end
      end

      if default < 0 then
        local bone
        local bone_num = boneNumber[1]
        if bone_num == nil then
          util.printf("vertex[%d] has no weight.\n", i)
          bone_num = 0
        else
          repeat
            bone = self.skeleton:getBoneFromJointNo(bone_num)
            if bone.parent == nil then
              bone_num = 0
            else
              bone_num = self.skeleton:getJointFromBone(bone.parent)
              if bone_num == nil then bone_num = 0 end
            end
          until (bone_num < 40)
        end
        n = 1
        self.vObj[j+ 8] = bone_num
        self.vObj[j+12] = 1.0
      end
      if n < 4 then
        for k = n+1, 4 do
          self.vObj[j+ 8 + (k-1)] = 0
          self.vObj[j+12 + (k-1)] = 0.0
        end
      end

    end
    local var = ffi.new("uint32_t[1]")
    gl.genBuffers(1, var)
    self.vbo = var[0]
    gl.bindBuffer(gl.ARRAY_BUFFER, self.vbo)
    gl.bufferData(gl.ARRAY_BUFFER, vObj_len * 4, self.vObj, gl.STATIC_DRAW)
  else
    local vObj_len = self.vertexCount * 8
    self.vObj = ffi.new("float[?]", vObj_len)
    for i = 1, self.vertexCount do
      local j = (i-1) * 8
      self.vObj[j  ] = self.positionArray[i][1]
      self.vObj[j+1] = self.positionArray[i][2]
      self.vObj[j+2] = self.positionArray[i][3]
      self.vObj[j+3] = self.normalArray[i][1]
      self.vObj[j+4] = self.normalArray[i][2]
      self.vObj[j+5] = self.normalArray[i][3]
      self.vObj[j+6] = self.texCoordsArray[i][1]
      self.vObj[j+7] = self.texCoordsArray[i][2]
    end
    local var = ffi.new("uint32_t[1]")
    gl.genBuffers(1, var)
    self.vbo = var[0]
    gl.bindBuffer(gl.ARRAY_BUFFER, self.vbo)
    gl.bufferData(gl.ARRAY_BUFFER, vObj_len * 4, self.vObj, gl.STATIC_DRAW)
  end

  -- Create Index Buffer Object.
  self.indexCount = #self.indicesArray * 3
  self.iObj = ffi.new("uint16_t[?]", self.indexCount)
  local j
  for i = 1, #self.indicesArray do
    j = (i-1) * 3
    self.iObj[j  ] = self.indicesArray[i][1]
    self.iObj[j+1] = self.indicesArray[i][2]
    self.iObj[j+2] = self.indicesArray[i][3]
  end
  local var = ffi.new("uint32_t[1]")
  gl.genBuffers(1, var)
  self.ibo = var[0]
  gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, self.ibo)
  gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, self.indexCount * 2, self.iObj,
                gl.STATIC_DRAW)
  return self.vertexCount
end

function Shape.releaseObjects(self)
  self.positionArray  = {}
  self.normalArray  = {}
  self.indicesArray   = {}
  self.texCoordsArray = {}
  self.altVertices  = {}
  self.vObj = {}
  self.iObj = {}
  self.bindex = {}
  self.weight = {}
end

function Shape.setSkeleton(self, skeleton)
  self.skeleton = skeleton
  self.hasSkeleton = true
end

function Shape.getSkeleton(self)
  return self.skeleton
end

function Shape.hide(self, true_or_false)
  self.isHidden = true_or_false
end

function Shape.draw(self, modelview, normal)
  if self.isHidden then return end  -- 2013/07/21

  local shd = self.shader
  shd:useProgram()
  shd:setModelViewMatrix(modelview)
  shd:setNormalMatrix(normal)
  if self.hasSkeleton then
    shd:setMatrixPalette(self.skeleton:updateMatrixPalette())
  end
  shd:doParameter(self.shaderParam)

  gl.bindBuffer(gl.ARRAY_BUFFER, self.vbo)
  gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, self.ibo)
  gl.enableVertexAttribArray(shd.aPosition)
  gl.enableVertexAttribArray(shd.aNormal)
  gl.enableVertexAttribArray(shd.aTexCoord)
  if self.hasSkeleton then
    gl.enableVertexAttribArray(shd.aIndex)
    gl.enableVertexAttribArray(shd.aWeight)
    gl.vertexAttribPointer(shd.aPosition, 3, gl.FLOAT, gl.FALSE, 4*16,
      ffi.cast("const void *", 0))
    gl.vertexAttribPointer(shd.aNormal,   3, gl.FLOAT, gl.FALSE, 4*16,
      ffi.cast("const void *", 3*4))
    gl.vertexAttribPointer(shd.aTexCoord, 2, gl.FLOAT, gl.FALSE, 4*16,
      ffi.cast("const void *", 6*4))
    gl.vertexAttribPointer(shd.aIndex,    4, gl.FLOAT, gl.FALSE, 4*16,
      ffi.cast("const void *", 8*4))
    gl.vertexAttribPointer(shd.aWeight,   4, gl.FLOAT, gl.FALSE, 4*16,
      ffi.cast("const void *", 12*4))
  else
    if shd.aWeight ~= nil then
      gl.disableVertexAttribArray(shd.aIndex)
      gl.disableVertexAttribArray(shd.aWeight)
    end
    gl.vertexAttribPointer(shd.aPosition, 3, gl.FLOAT, gl.FALSE, 4*8,
      ffi.cast("const void *", 0))
    gl.vertexAttribPointer(shd.aNormal,   3, gl.FLOAT, gl.FALSE, 4*8,
      ffi.cast("const void *", 3*4))
    gl.vertexAttribPointer(shd.aTexCoord, 2, gl.FLOAT, gl.FALSE, 4*8,
      ffi.cast("const void *", 6*4))
  end
  gl.drawElements(gl.TRIANGLES, self.indexCount, gl.UNSIGNED_SHORT,
    ffi.cast("const void *", 0))
end

function Shape.setVertex(self, x, y, z)
  table.insert(self.positionArray, {x, y, z})
  table.insert(self.normalArray, {0, 0, 0})
  self.vertexCount = self.vertexCount + 1
  if self.hasSkeleton then
    table.insert(self.bindex, {})
    table.insert(self.weight, {})
  end
  self:updateBoundingBox(x, y, z)
  return self.vertexCount
end

function Shape.addVertex(self, x, y, z)
  local vcount = self:setVertex(x, y, z)
  self:calcUV(x, y, z)
  return vcount
end

function Shape.addVertexUV(self, x, y, z, u, v)
  local vcount = self:setVertex(x, y, z)
  table.insert(self.texCoordsArray, {u, v})
  return vcount
end

function Shape.addVertexPosUV(self, pos, uv)
  local vcount = self:setVertex(unpack(pos))
  table.insert(self.texCoordsArray, uv)
  return vcount
end

function Shape.setVertNormal(self, vn, x, y, z)
  self.normalArray[vn] = {x, y, z}
end

function Shape.getVertNormal(self, vn)
 return self.normalArray[vn]
end

function Shape.getVertPosition(self, vn)
  return self.positionArray[vn]
end

-- vn:vertex_no=1.. ind:bone_index=0.. wt:weight=0.0..1.0
function Shape.addVertexWeight(self, vn, ind, wt)
  if not self.hasSkeleton then return end
  if not self.bindex[vn] then
     util.printf("#self.bindex = %d\n", #self.bindex)
     util.printf("addVertexWeight[%d] == nil\n", vn)
  end
  if #self.bindex[vn] < 4 then
    table.insert(self.bindex[vn], ind)
    table.insert(self.weight[vn], wt)
  else
    util.printf("vert[%d] bone[%d] weight: %f\n", vn, ind, wt)
  end
end

function Shape.checkAltVertex(self, p)
  for i=1, #self.altVertices do
    if (p == self.altVertices[i][1]) then
      return self.altVertices[i][2]
    end
  end
  return -1
end

function Shape.addTriangle(self, p0, p1, p2)
  local p1_new = p1
  local p2_new = p2

  local x0, y0, z0 = unpack(self.positionArray[p0])
  local x1, y1, z1 = unpack(self.positionArray[p1])
  local x2, y2, z2 = unpack(self.positionArray[p2])

  local u0, v0 = unpack(self.texCoordsArray[p0])
  local u1, v1 = unpack(self.texCoordsArray[p1])
  local u2, v2 = unpack(self.texCoordsArray[p2])

  if ((self.tx_mode == 0) and (math.abs(u1 - u0) > 0.5)) then
    if (u1 < u0) then
      u1 = u1 + 1
    else
      u1 = u1 - 1
    end
    local np = self:checkAltVertex(p1)
    if (np < 0) then
      p1_new = self:addVertexPosUV(self:getVertPosition(p1), {u1, v1})
      if self.hasSkeleton then
        self.bindex[p1_new] = self.bindex[p1]
        self.weight[p1_new] = self.weight[p1]
      end
      table.insert(self.altVertices, {p1, p1_new})
    else
      p1_new = np
    end
  end
  if ((self.tx_mode == 0) and (math.abs(u2 - u1) > 0.5)) then
    if (u2 < u1) then
      u2 = u2 + 1
    else
      u2 = u2 - 1
    end
    local np = self:checkAltVertex(p2)
    if (np < 0) then
      p2_new = self:addVertexPosUV(self:getVertPosition(p2),{u2,v2})
      if self.hasSkeleton then
        self.bindex[p2_new] = self.bindex[p2]
        self.weight[p2_new] = self.weight[p2]
      end
      table.insert(self.altVertices, {p2, p2_new})
    else
      p2_new = np
    end
  end
  table.insert(self.indicesArray, {p0-1, p1_new-1, p2_new-1})

  if self.autoCalcNormals then
    local nx = (y1-y0)*(z2-z1) - (z1-z0)*(y2-y1)
    local ny = (z1-z0)*(x2-x1) - (x1-x0)*(z2-z1)
    local nz = (x1-x0)*(y2-y1) - (y1-y0)*(x2-x1)
    self.normalArray[p0][1] = self.normalArray[p0][1] + nx
    self.normalArray[p0][2] = self.normalArray[p0][2] + ny
    self.normalArray[p0][3] = self.normalArray[p0][3] + nz
    self.normalArray[p1][1] = self.normalArray[p1][1] + nx
    self.normalArray[p1][2] = self.normalArray[p1][2] + ny
    self.normalArray[p1][3] = self.normalArray[p1][3] + nz
    self.normalArray[p2][1] = self.normalArray[p2][1] + nx
    self.normalArray[p2][2] = self.normalArray[p2][2] + ny
    self.normalArray[p2][3] = self.normalArray[p2][3] + nz

    for i=1, #self.altVertices do
      self.normalArray[ self.altVertices[i][2] ] =
          self.normalArray[ self.altVertices[i][1] ]
    end
  end
end

function Shape.addPlane(self, indices)
  for i = 1, #indices-2 do
    self:addTriangle(indices[1]+1, indices[i+1]+1, indices[i+2]+1)
  end
end

function Shape.calcUV(self, x, y, z)
  local u = 0
  local v = 0
  local pi = math.pi

  if (self.tx_mode == 0) then
    if (self.tx_axis == 0) or (self.tx_axis == 1) then
      -- around y
      u =  math.atan2(-z, x)
      v =  math.atan2(math.sqrt(x*x+z*z), y)
    elseif (self.tx_axis == -1) then
      -- around -y
      u =  math.atan2(z, x)
      v =  math.atan2(math.sqrt(x*x+z*z), -y)
    elseif (self.tx_axis == 2) then
      -- around x
      u =  math.atan2(z, y)
      v =  math.atan2(math.sqrt(y*y+z*z), x)
    elseif (self.tx_axis == -2) then
      -- around -x
      u =  math.atan2(-z, y)
      v =  math.atan2(math.sqrt(y*y+z*z), -x)
    elseif (self.tx_axis == 3) then
      -- around z
      u =  math.atan2(y, x)
      v =  math.atan2(math.sqrt(x*x+y*y), z)
    elseif (self.tx_axis == -3) then
      -- around -z
      u =  math.atan2(-y, x)
      v =  math.atan2(math.sqrt(x*x+y*y), -z)
    end
    if (u < 0.0) then
      u = u + pi * 2
    end
    u = u / (pi * 2)
    v = 1 - v / pi
  elseif (self.tx_mode == 1) then
    if (self.tx_axis == 0) or (self.tx_axis == 1) then
      -- along -z
      u = x / self.tx_su + self.tx_offu
      v = y / self.tx_sv + self.tx_offv
    elseif (self.tx_axis == -1) then
      -- along z
      u = -(x / self.tx_su + self.tx_offu)
      v = y / self.tx_sv + self.tx_offv
    elseif (self.tx_axis == 2)  then
      -- along -x
      u = -(z / self.tx_su + self.tx_offu)
      v = y / self.tx_sv + self.tx_offv
    elseif (self.tx_axis == -2)  then
      -- along x
      u = z / self.tx_su + self.tx_offu
      v = y / self.tx_sv + self.tx_offv
    elseif (self.tx_axis == 3)  then
      -- along -y
      u = x / self.tx_su + self.tx_offu
      v = -(z / self.tx_sv + self.tx_offv)
    elseif (self.tx_axis == -3)  then
      -- along y
      u = x / self.tx_su + self.tx_offu
      v = z / self.tx_sv + self.tx_offv
    end
  end
  table.insert(self.texCoordsArray, {u, v})
end

-- Solid of revolution around y-axis
function Shape.revolution(self, latitude, longitude, verts, spherical)
  local n = latitude + 1

  for i= 0, n-1 do
    local k = i * 2 + 1  -- index++
    if (spherical) then
      self:addVertex(verts[k], verts[k+1], 0)
    else
      self:addVertexUV(verts[k],verts[k+1], 0,
               0, 1-(i/latitude))
    end
  end
  local T = math.pi * 2 / longitude
  for j = 1, longitude+1 do
    for i = 0, n-1 do
      local k = i * 2 + 1  -- index++
      if (spherical) then
        self:addVertex(verts[k] * math.cos(T*j), verts[k+1],
                - verts[k] * math.sin(T*j))
      else
        self:addVertexUV(verts[k] * math.cos(T*j), verts[k+1],
            - verts[k] * math.sin(T*j), j / longitude,
                 1 - (i/latitude))
      end
    end
  end

  for j = 0, longitude-2 do
    for i = 0, latitude-1 do
      self:addPlane(
        { j * n + i,
          j * n + i + 1,
          (j + 1) * n + i + 1,
          (j + 1) * n + i
        })
    end
  end
  --  m-1 to 0
  for i = 0, latitude-1 do
    self:addPlane(
      { (longitude-1) * n + i,
        (longitude-1) * n + i + 1,
        i + 1,
        i
      })
  end
end

function Shape.sphere(self, radius, latitude, longitude)
  local vertices = {}
  local pi = math.pi
  local r = radius
  table.insert(vertices, r/10000.0)  --  x axis   TOP
  table.insert(vertices, r)          --  y axis
  for i = 1, latitude-1 do
    table.insert(vertices, r * math.sin(i*pi/latitude))
    table.insert(vertices, r * math.cos(i*pi/latitude))
  end
  table.insert(vertices, r/10000.0)  --  x axis   BOTTOM
  table.insert(vertices, -r)         --  y axis
  self:revolution(latitude, longitude, vertices, true)
end

function Shape.donut(self, radius, radiusTube, latitude, longitude)
  local vertices = {}
  local pi = math.pi
  local r = radius
  local r2 = radiusTube
  for i=0, latitude do
    table.insert(vertices, r + r2*math.cos(2*pi*(0.5 - i/latitude)))
    table.insert(vertices, r2*math.sin(2*pi*(0.5 - i/latitude)))
  end
  self:revolution(latitude, longitude, vertices, false)
end

function Shape.cone(self, height, radius, n)
  local vertices = {}
  table.insert(vertices,  0.0001 )     --  x axis   TOP
  table.insert(vertices,  height )     --  y axis
  table.insert(vertices,  radius )     --  x axis
  table.insert(vertices,  0.0 )        --  y axis
  table.insert(vertices,  0.0001 )     --  x axis
  table.insert(vertices,  0.0)         --  y axis
  self:revolution(2, n, vertices, true)
end

function Shape.truncated_cone(self, height, radiusTop, radiusBottom, n)
  local vertices = {}
  table.insert(vertices,  0.0001 )     --  x axis   TOP
  table.insert(vertices,  height )     --  y axis
  table.insert(vertices,  radiusTop )  --  x axis
  table.insert(vertices,  height )     --  y axis
  table.insert(vertices,  radiusBottom )  --  x axis
  table.insert(vertices,  -height )    --  y axis
  table.insert(vertices,  0.0001 )     --  x axis   BOTTOM
  table.insert(vertices,  -height )    --  y axis
  self:revolution(3, n, vertices, true)
end

function Shape.double_cone(self, height, radius, n)
  local vertices = {}
  table.insert(vertices,  0.0001 )    --  x axis   TOP
  table.insert(vertices,  height )    --  y axis
  table.insert(vertices,  radius )    --  x axis
  table.insert(vertices,  0.0 )       --  y axis
  table.insert(vertices,  0.0001 )    --  x axis   BOTTOM < origin
  table.insert(vertices,  -height )   --  y axis
  self:revolution(2, n, vertices, true)
end

function Shape.prism(self, height, radius, n)
  local vertices = {}
  table.insert(vertices,  0.0001 )    --  x axis   TOP
  table.insert(vertices,  height )    --  y axis
  table.insert(vertices,  radius )    --  x axis
  table.insert(vertices,  height )    --  y axis
  table.insert(vertices,  radius )    --  x axis
  table.insert(vertices,  -height )   --  y axis
  table.insert(vertices,  0.0001 )    --  x axis   BOTTOM
  table.insert(vertices,  -height )   --  y axis
  self:revolution(3, n, vertices, true)
end

function Shape.arrow(self, length, head, width, n)
  local vertices = {}
  table.insert(vertices, 0.0001)        --  x axis   TOP
  table.insert(vertices, length)        --  y axis
  table.insert(vertices, width * 3)     --  x axis
  table.insert(vertices, length - head) --  y axis
  table.insert(vertices, width)         --  x axis
  table.insert(vertices, length - head) --  y axis
  table.insert(vertices, width)         --  x axis
  table.insert(vertices, 0)             --  y axis
  table.insert(vertices, 0.0001 )       --  x axis   BOTTOM
  table.insert(vertices, 0)             --  y axis
  self:revolution(4, n, vertices, true)
end

function Shape.cuboid(self, size_x, size_y, size_z)
  local sx = size_x / 2.0
  local sy = size_y / 2.0
  local sz = size_z / 2.0
  self:addVertex(-sx,  sy, -sz) --  vertex 0  0 ---- 3 -sz
  self:addVertex(-sx, -sy, -sz) --  vertex 1  |     |
  self:addVertex( sx, -sy, -sz) --  vertex 2  |     |
  self:addVertex( sx,  sy, -sz) --  vertex 3  1 ---- 2

  self:addVertex(-sx,  sy, -sz) --  vertex 4    4 ---- 5
  self:addVertex( sx,  sy, -sz) --  vertex 5   /      /
  self:addVertex( sx,  sy,  sz) --  vertex 6  7 ----- 6
  self:addVertex(-sx,  sy,  sz) --  vertex 7

  self:addVertex( sx,  sy, -sz) --  vertex 8       _ 8
  self:addVertex( sx, -sy, -sz) --  vertex 9    11   |
  self:addVertex( sx, -sy,  sz) --  vertex 10    | _ 9
  self:addVertex( sx,  sy,  sz) --  vertex 11   10

  self:addVertex(-sx,  sy, -sz) --  vertex 12     _ 12
  self:addVertex(-sx,  sy,  sz) --  vertex 13  13   |
  self:addVertex(-sx, -sy,  sz) --  vertex 14   | _ 15
  self:addVertex(-sx, -sy, -sz) --  vertex 15  14

  self:addVertex(-sx, -sy, -sz) --  vertex 16
  self:addVertex(-sx, -sy,  sz) --  vertex 17
  self:addVertex( sx, -sy,  sz) --  vertex 18   _ - 16 ---- 19
  self:addVertex( sx, -sy, -sz) --  vertex 19  17 ---- 18 - ~

  self:addVertex(-sx,  sy,  sz) --  vertex 20  20 ---- 21
  self:addVertex( sx,  sy,  sz) --  vertex 21    |     |
  self:addVertex( sx, -sy,  sz) --  vertex 22    |     |
  self:addVertex(-sx, -sy,  sz) --  vertex 23  23 ---- 22 sz

  self:addPlane({ 3,  2,  1,  0})
  self:addPlane({ 7,  6,  5,  4})
  self:addPlane({11, 10,  9,  8})
  self:addPlane({15, 14, 13, 12})
  self:addPlane({19, 18, 17, 16})
  self:addPlane({23, 22, 21, 20})
end

function Shape.mapCuboid(self, size_x, size_y, size_z)
  local sx = size_x / 2.0
  local sy = size_y / 2.0
  local sz = size_z / 2.0
  self:addVertexUV(-sx,  sy, -sz, 0.25, 0.75) --  vtx 0  0 ---- 3 -sz
  self:addVertexUV(-sx, -sy, -sz, 0.25, 1.00) --  vtx 1  | back |
  self:addVertexUV( sx, -sy, -sz, 0.50, 1.00) --  vtx 2  |      |
  self:addVertexUV( sx,  sy, -sz, 0.50, 0.75) --  vtx 3  1 ---- 2

  self:addVertexUV(-sx,  sy, -sz, 0.25, 0.75) --  vtx 4   4 ---- 5
  self:addVertexUV( sx,  sy, -sz, 0.50, 0.75) --  vtx 5   / top  /
  self:addVertexUV( sx,  sy,  sz, 0.50, 0.50) --  vtx 6  7 ----- 6
  self:addVertexUV(-sx,  sy,  sz, 0.25, 0.50) --  vtx 7

  self:addVertexUV( sx,  sy, -sz, 0.50, 0.75) --  vtx 8     _ 8
  self:addVertexUV( sx, -sy, -sz, 0.75, 0.75) --  vtx 9  11   | right
  self:addVertexUV( sx, -sy,  sz, 0.75, 0.50) --  vtx 10  | _ 9
  self:addVertexUV( sx,  sy,  sz, 0.50, 0.50) --  vtx 11   10

  self:addVertexUV(-sx,  sy, -sz, 0.25, 0.75) --  vtx 12    _ 12
  self:addVertexUV(-sx,  sy,  sz, 0.25, 0.50) --  vtx 13  13   |  left
  self:addVertexUV(-sx, -sy,  sz, 0.00, 0.50) --  vtx 14   | _ 15
  self:addVertexUV(-sx, -sy, -sz, 0.00, 0.75) --  vtx 15  14

  self:addVertexUV(-sx, -sy, -sz, 0.25, 0.00) --  vtx 16    bottom
  self:addVertexUV(-sx, -sy,  sz, 0.25, 0.25) --  vtx 17
  self:addVertexUV( sx, -sy,  sz, 0.50, 0.25) --  vtx 18  _ - 16 ---- 19
  self:addVertexUV( sx, -sy, -sz, 0.50, 0.00) --  vtx 19  17 ---- 18 - ~

  self:addVertexUV(-sx,  sy,  sz, 0.25, 0.50) --  vtx 20  20 ---- 21
  self:addVertexUV( sx,  sy,  sz, 0.50, 0.50) --  vtx 21   |front |
  self:addVertexUV( sx, -sy,  sz, 0.50, 0.25) --  vtx 22   |      |
  self:addVertexUV(-sx, -sy,  sz, 0.25, 0.25) --  vtx 23  23 ---- 22 sz

  self:addPlane({ 3,  2,  1,  0})
  self:addPlane({ 7,  6,  5,  4})
  self:addPlane({11, 10,  9,  8})
  self:addPlane({15, 14, 13, 12})
  self:addPlane({19, 18, 17, 16})
  self:addPlane({23, 22, 21, 20})
end

function Shape.cube(self, size)
  self:cuboid(size, size, size)
end

function Shape.mapCube(self, size)
  self:mapCuboid(size, size, size)
end

function Shape.simpleBone(self, a)
  self:addVertex( 0, 10*a, 0) -- tail (y)
  self:addVertex( 0,  a,   a)
  self:addVertex( 0,  0,   0) -- head (origin)
  self:addVertex( 0,  a,  -a)
  self:addVertex( 3*a, a,  0) -- (x)
  self:addVertex( 0,  2*a,  0)
  self:addVertex(-a,  a,   0)
  self:addVertex( 0,  0,   0)
  self:addVertex( 0, 10*a, 0)
  self:addVertex( 0,  a,   a)
  self:addVertex( 0,  0,   0)
  self:addVertex( 0,  a,  -a)
  self:addVertex( 3*a, a,  0)
  self:addVertex( 0,  2*a,  0)
  self:addVertex(-a,  a,   0)
  self:addVertex( 0,  0,   0)
  self:addPlane({  0, 1, 2, 3})
  self:addPlane({  4, 5, 6, 7})
  self:addPlane({ 11,10, 9, 8})
  self:addPlane({ 15,14,13,12})
  self:endShape()
end

function Shape.listVertex(self, vn)
  local size = 8
  local v = self.vObj
  if self.hasSkeleton then size = 16 end
  local j = (vn - 1) * size
  util.printf("Vertex No. = %d\n", vn)
  util.printf("  Position x : %f,  y : %f,  z : %f\n", v[j], v[j+1], v[j+2])
  util.printf("  Normal   x : %f,  y : %f,  z : %f\n", v[j+3], v[j+4], v[j+5])
  util.printf("  Texture  u : %f,  v : %f\n", v[j+6], v[j+7])

  if self.hasSkeleton then
     local sum_weights = 0
     local wcount = 0
     for i=12, 15 do
       sum_weights = sum_weights + v[j+i]
       if v[j+i] > 0.00001 then wcount = wcount + 1 end
     end
     util.printf("  [1] index = %f,  weight = %f\n", v[j+ 8], v[j+12])
     util.printf("  [2] index = %f,  weight = %f\n", v[j+ 9], v[j+13])
     util.printf("  [3] index = %f,  weight = %f\n", v[j+10], v[j+14])
     util.printf("  [4] index = %f,  weight = %f\n", v[j+11], v[j+15])
     if (sum_weights < 0.95) or (sum_weights > 1.05) then
       util.printf(">>")
     end
     util.printf(" [%d] sum of weights(%d)  -->  %f\n",
                 vn , wcount, sum_weights)
  end
end

function Shape.listVertexAll(self)
  for i = 1, self.vertexCount do
    self:listVertex(i)
  end
  if self.hasSkeleton then
    self.skeleton:updateMatrixPalette()
    for i = 1, #self.skeleton.boneOrder do
      util.printf("  bone : %s\n", self.skeleton.boneOrder[i].name)
      local n = (i-1) * 12
      local pal = self.skeleton.matrixPalette
      local fmt = "% 16.14f % 16.14f % 16.14f % 16.14f\n"
      for j=0, 2 do
        local k = n + j * 4
        util.printf(fmt, pal[k], pal[k+1], pal[k+2], pal[k+3])
      end
    end
  end
end

function Shape.printVertex(self)
  local function p(format, n, value )
    util.printf(format, n, unpack(value))
  end
  local function ptab3(title, tab)
    util.printf("count: %d\n", #tab)
    for i=1, #tab do
      p(title .. "(%3d) %12f  %12f  %12f  \n", i, tab[i])
    end
  end
  local function ptab2(title, tab)
    util.printf("count: %d\n", #tab)
    for i=1, #tab do
      p(title .. "(%3d) %12f  %12f   \n", i, tab[i])
    end
  end

  ptab3("position: ", self.positionArray)
  ptab3("normal  : ", self.normalArray)
  ptab2("texture : ", self.texCoordsArray)
  ptab3("index   : ", self.indicesArray)
end
