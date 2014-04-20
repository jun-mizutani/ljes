-- ---------------------------------------------
--  Mesh.lua       2014/03/23
--   for collada.lua
--   Copyright (c) 2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

require("Object")
util = require("util")

Mesh = Object:new()

function Mesh.new(self, frame)
  local obj = Object.new(self)
  obj.frame = frame
  obj.verts = {}
  obj.polygons = {}
  obj.texure_cood = {}
  obj.joint_names = {}
  obj.skinweights = {}
  obj.bind_shape_matrix = nil
  obj.nMaxSkinWeightsPerVertex = 0
  obj.nMaxSkinWeightsPerFace = 0
  obj.nBones = 0
  obj.hasNormals = false
  obj.normals = {}
  obj.box = {
    minx = 1.0E10, maxx = -1.0E10,
    miny = 1.0E10, maxy = -1.0E10,
    minz = 1.0E10, maxz = -1.0E10
  }

  return obj
end

function Mesh.setName(self, name)
  self.name = name
end

function Mesh.getName(self)
  return self.name
end

function Mesh.setVertices(self, verts)
  self.verts = verts
end

function Mesh.getVertices(self)
  return self.verts
end

function Mesh.setPolygons(self, polygons)
  self.polygons = polygons
end

function Mesh.getPolygons(self)
  return self.polygons
end

function Mesh.setTextureCoord(self, texure_coord)
  self.texure_cood = texure_coord
end

function Mesh.getTextureCoord(self)
  return self.texure_cood
end

function Mesh.setSkinWeights(self, skin_weights)
  -- skin_weights :
  -- { {bone_index, weight, bone_index, weight, ..}, .. }
  self.skinweights = skin_weights
end

function Mesh.getSkinWeights(self)
  return self.skinweights
end

function Mesh.setNormals(self, normals)
  self.hasNormals = true
  self.normals = normals
end

function Mesh.getNormals(self)
  return self.normals
end

function Mesh.setJointNames(self, joint_names)
  self.joint_names = joint_names
end

function Mesh.getJointNames(self)
  return self.joint_names
end

function Mesh.setBindPoseMatrices(self, bindPoseMatrices)
  self.bindPoseMatrices = bindPoseMatrices
end

-- get inverse bind shape matrices from collada file
function Mesh.getBindPoseMatrices(self)
  return self.bindPoseMatrices
end

function Mesh.setBindShapeMatrix(self, bind_shape_matrix)
  self.bind_shape_matrix = bind_shape_matrix
end

function Mesh.getBindShapeMatrix(self)
  return self.bind_shape_matrix
end

function Mesh.updateBoundingBox(self, x, y, z)
  local box = self.box
  if box.minx > x then box.minx = x end
  if box.maxx < x then box.maxx = x end
  if box.miny > y then box.miny = y end
  if box.maxy < y then box.maxy = y end
  if box.minz > z then box.minz = z end
  if box.maxz < z then box.maxz = z end
end

function Mesh.printInfo(self)
  local verts = self.verts
  local normals = self.normals
  local tex_table = self.texure_cood
  local polygons = self.polygons
  local joint_names = self.joint_names
  local skinweights = self.skinweights
  local bind_shape_matrix = self.bind_shape_matrix

  util.printf("Mesh:---- %s ----\n",i , self.name)
  util.printf("vertices    = %d\n", #verts/3)
  util.printf("normals     = %d\n", #normals/3)
  for m = 1, #tex_table do
    local tex = tex_table[m]
    util.printf("texture     = %d\n", #tex/2)
  end
  util.printf("polygons    = %d\n", #polygons)

  util.printf("bind_shape_matrix\n")
  bind_shape_matrix:print()
  util.printf("bone count  = %d\n", #joint_names)
  for n = 1, #joint_names do
    util.printf("[%3d]  %s\n", n - 1, joint_names[n])
  end

  for i = 0, #verts/3 - 1 do
   self:updateBoundingBox(verts[i*3+1], verts[i*3+2], verts[i*3+3])
  end
  local bbox = self.box
  util.printf(" X: %10.5f -- %10.5f    center:%10.5f, size:%10.5f\n",
    bbox.minx, bbox.maxx, (bbox.maxx+bbox.minx)/2, bbox.maxx - bbox.minx)
  util.printf(" Y: %10.5f -- %10.5f    center:%10.5f, size:%10.5f\n",
    bbox.miny, bbox.maxy, (bbox.maxy+bbox.miny)/2, bbox.maxy - bbox.miny)
  util.printf(" Z: %10.5f -- %10.5f    center:%10.5f, size:%10.5f\n",
    bbox.minz, bbox.maxz, (bbox.maxz+bbox.minz)/2, bbox.maxz - bbox.minz)
end

