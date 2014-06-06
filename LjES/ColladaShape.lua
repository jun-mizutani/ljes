-- ---------------------------------------------
-- ColladaShape.lua 2014/03/23
--   Copyright (c) 2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

package.path = "../LjES/?.lua;" .. package.path

require("Collada")
require("Shape")

ColladaShape = Collada:new()

function ColladaShape.new(self)
  local obj = Collada.new(self)
  return obj
end

-- ----------------------------
-- setBones called from setShape
-- ----------------------------
function ColladaShape.setBones(self, mesh, shape, verts, newindex)
  local joint_names = mesh:getJointNames()
  if #joint_names == 0 then return end
  self:printf("bone count  = %d\n", #joint_names)

  local skeleton = shape:getSkeleton()
  local skinweights = mesh:getSkinWeights()
  local ibp_matrices = mesh:getBindPoseMatrices()
  local bind_shape_matrix = mesh:getBindShapeMatrix()

  local found = false
  local frame = self.rootFrame:findFrame(joint_names[1])
  repeat
    local count = frame:getNoOfBones(joint_names)
    if count < #joint_names then
      frame = frame.parent
    else
      found = true
    end
  until found or (frame == nil)
  self:printf("bone root = %s\n", frame:getName())
  frame:copyToBone(joint_names, bind_shape_matrix, skeleton, 
                   nil, 0, self.printflag)

  skeleton:setBoneOrder(joint_names)
  skeleton:bindRestPose()
  shape:shaderParameter("has_bone", 1)

  -- register skin weights
  -- skinweights = {
  --   {bone_idx, weight, bone_idx, weight, .. }
  --   {bone_idx, weight, bone_idx, weight, .. }
  --   ..
  -- }
  local vert_count = #verts / 3
  for i = 1, vert_count  do
    for n = 1, #newindex[i] do
      local vindex = newindex[i][n]
      local sw = skinweights[i]
      local weight_count = #sw / 2
      local tmp = {}
      local min = 1.0
      local imin = 0
      for j = 0, weight_count - 1 do
        local bone = sw[j * 2 + 1]
        local weight = sw[j * 2 + 2]
        if j < 4 then
          if weight < min then min = weight; imin = j+1 end
          table.insert(tmp, {bone, weight})
        else
          if weight > min then
            tmp[imin] = {bone, weight}
            min = 1.0
            imin = 0
            for m = 1, #tmp do
              if tmp[m][2] < min then
                min = tmp[m][2]
                imin = m
              end
            end
          end
        end
      end
      -- normalize
      local total_weight = 0
      for m = 1, #tmp do
        total_weight = total_weight + tmp[m][2]
      end
      for m = 1, #tmp do
        shape:addVertexWeight(vindex, tmp[m][1], tmp[m][2] / total_weight)
      end
    end  -- for n = 1, #newindex[i] do
  end    -- for i = 1, vert_count  do
end

-- ----------------------------
-- setShape called from makeShapes
-- ----------------------------
function ColladaShape.setShape(self, nmesh, bone_enable, texture_select)
  local mesh = self.meshes[nmesh]
  local verts = mesh:getVertices()
  local normals = mesh:getNormals()
  local tex_table = mesh:getTextureCoord()
  local polygons = mesh:getPolygons()
  local bind_shape_matrix = mesh:getBindShapeMatrix()
  local originx, originy, originz

  if bind_shape_matrix ~= nil then
    originx, originy, originz = unpack(bind_shape_matrix:getPosition())
  else
    originx, originy, originz = 0, 0, 0
  end

  self:printf("[%d]---- %s ----\n",nmesh , self.meshes[nmesh]:getName())
  self:printf("vertices    = %d\n", #verts/3)
  self:printf("normals     = %d\n", #normals/3)

  local select
  if texture_select > #tex_table then
    select = #tex_table
  else
    select = texture_select
  end

  for m = 1, #tex_table do
    local tex = tex_table[m]
    self:printf("texture     = %d\n", #tex/2)
  end
  self:printf("polygons    = %d\n", #polygons)

  local shape = Shape:new()
  shape:setAutoCalcNormals(false)
  shape:setTextureMappingMode(-1)

  local joints = mesh:getJointNames()
  if bone_enable and (#joints > 0) then
    local skeleton = Skeleton:new()
    shape:setSkeleton(skeleton)
  end

  -- conversion table from pos_index to final-vert-indices for weight
  -- ex. newindex[pos_index] = {8, 10, 12}
  local newindex = {}
  for i = 1, #verts/3 do
    table.insert(newindex, {})
  end

  local pos_index, nrm_index, tex_index
  local x, y, z, u, v, nx, ny, nz, h
  for i = 1, #polygons do
    local indices = {}
    for j = 1, #polygons[i] do
      pos_index = polygons[i][j][1]
      nrm_index = polygons[i][j][2]
      tex_index = polygons[i][j][3]
      x =  verts[pos_index * 3 + 1] + originx
      z = -verts[pos_index * 3 + 2] - originy
      y =  verts[pos_index * 3 + 3] + originz
      nx = normals[nrm_index * 3 + 1]
      nz = - normals[nrm_index * 3 + 2]
      ny = normals[nrm_index * 3 + 3]
      if #tex_table > 0 then
        if (#tex_table[select] > 0) then
          u = tex_table[select][tex_index * 2 + 1]
          v = tex_table[select][tex_index * 2 + 2]
          h = shape:addVertexPosUV({x, y, z}, {u, v})
        end
      else
        h = shape:addVertex(x, y, z)
      end
      shape:setVertNormal(h, nx, ny, nz)
      table.insert(indices, h - 1)
      -- register h to conversion table
      table.insert(newindex[pos_index+1], h)
    end
    shape:addPlane(indices)
  end

  if bone_enable and (#joints > 0) then
    self:setBones(mesh, shape, verts, newindex)
    shape:setAnimation(self.anim)
    local skeleton = shape:getSkeleton()
    self.anim:setData(skeleton, bind_shape_matrix)
  end

  return shape
end

-- ----------------------------
-- makeShapes
-- ----------------------------
function ColladaShape.makeShapes(self, bone_enable, verbose, tex_select)
  self.printflag = verbose
  if self.mesh_count == 0 then return nil end

  -- if multi-texture, select one of these.
  local texture_select = 1
  if tex_select then
    if tex_select > 1 and tex_select <= 3 then
      texture_select = tex_select  -- for multi-texture: 1 or 2 or 3
    end
  end

  local shapes = {}
  local shape
  for k = 1, self.mesh_count do
    shape = self:setShape(k, bone_enable, texture_select)
    shape:endShape()
    table.insert(shapes, shape)
  end

  return shapes
end

