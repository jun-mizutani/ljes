-- ---------------------------------------------
-- Collada.lua     2014/04/25
--   Copyright (c) 2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------
package.path = "../LjES/?.lua;" .. package.path

require "Object"
util = require("util")
require("Stack")
require("Mesh")
require("Frame")
require("Animation")

Collada = Object:new()

Collada.ID = {
                       COLLADA =    1,
                   IDREF_array =    2,
                    Name_array =    3,
                      accessor =    4,
                  adapt_thresh =    5,
                         alpha =    6,
                       ambient =    7,
                     animation =    8,
                animation_clip =    9,
                      annotate =   10,
                    area_shape =   11,
                     area_size =   12,
                    area_sizey =   13,
                    area_sizez =   14,
                      argument =   15,
                         array =   16,
                  aspect_ratio =   17,
                         asset =   18,
           atm_distance_factor =   19,
         atm_extinction_factor =   20,
                 atm_turbidity =   21,
                          att1 =   22,
                          att2 =   23,
                    attachment =   24,
                        author =   25,
                authoring_tool =   26,
           backscattered_light =   27,
                          bias =   28,
                          bind =   29,
                 bind_material =   30,
             bind_shape_matrix =   31,
             bind_vertex_input =   32,
                         blinn =   33,
                          blue =   34,
                    bool_array =   35,
                           box =   36,
                       buffers =   37,
                       bufflag =   38,
                       bufsize =   39,
                       buftype =   40,
                        camera =   41,
                       capsule =   42,
                       channel =   43,
                       clipend =   44,
                       clipsta =   45,
                          code =   46,
                         color =   47,
                   color_clear =   48,
                  color_target =   49,
  common_color_or_texture_type =   50,
    common_float_or_param_type =   51,
              compiler_options =   52,
               compiler_target =   53,
                compressthresh =   54,
                 connect_param =   55,
                      constant =   56,
          constant_attenuation =   57,
                   contributor =   58,
              control_vertices =   59,
                    controller =   60,
                   convex_mesh =   61,
                       created =   62,
                      cylinder =   63,
                   depth_clear =   64,
                  depth_target =   65,
                       diffuse =   66,
                   directional =   67,
                          dist =   68,
                  double_sided =   69,
                          draw =   70,
                        effect =   71,
                      emission =   72,
                        energy =   73,
                         extra =   74,
                  falloff_type =   75,
                    filtertype =   76,
                          flag =   77,
                         float =   78,
                   float_array =   79,
                   force_field =   80,
                         gamma =   81,
                      geometry =   82,
                         green =   83,
                halo_intensity =   84,
            horizon_brightness =   85,
                         image =   86,
                        imager =   87,
           index_of_refraction =   88,
                     init_from =   89,
                         input =   90,
            instance_animation =   91,
               instance_camera =   92,
           instance_controller =   93,
               instance_effect =   94,
          instance_force_field =   95,
             instance_geometry =   96,
                instance_light =   97,
             instance_material =   98,
                 instance_node =   99,
     instance_physics_material =  100,
        instance_physics_model =  101,
        instance_physics_scene =  102,
           instance_rigid_body =  103,
     instance_rigid_constraint =  104,
         instance_visual_scene =  105,
                     int_array =  106,
                        joints =  107,
                       lambert =  108,
    vivlibrary_animation_clips =  109,
            library_animations =  110,
               library_cameras =  111,
           library_controllers =  112,
               library_effects =  113,
          library_force_fields =  114,
            library_geometries =  115,
                library_images =  116,
                library_lights =  117,
             library_materials =  118,
                 library_nodes =  119,
     library_physics_materials =  120,
        library_physics_models =  121,
        library_physics_scenes =  122,
         library_visual_scenes =  123,
                         light =  124,
            linear_attenuation =  125,
                         lines =  126,
                    linestrips =  127,
                        lookat =  128,
                      material =  129,
                        matrix =  130,
                          mesh =  131,
                          mode =  132,
                      modified =  133,
                         morph =  134,
                      newparam =  135,
                          node =  136,
                        optics =  137,
                  orthographic =  138,
                             p =  139,
                         param =  140,
                   perspective =  141,
                         phong =  142,
              physics_material =  143,
                 physics_model =  144,
                 physics_scene =  145,
                         plane =  146,
                         point =  147,
                      polygons =  148,
                      polylist =  149,
                profile_COMMON =  150,
         quadratic_attenuation =  151,
                      ray_samp =  152,
               ray_samp_method =  153,
                 ray_samp_type =  154,
                     ray_sampy =  155,
                     ray_sampz =  156,
                           red =  157,
                ref_attachment =  158,
                  reflectivity =  159,
                    rigid_body =  160,
              rigid_constraint =  161,
                        rotate =  162,
                          samp =  163,
                       sampler =  164,
                     sampler2D =  165,
                         scale =  166,
                         scene =  167,
                  shadhalostep =  168,
                      shadow_b =  169,
                      shadow_g =  170,
                      shadow_r =  171,
                  shadspotsize =  172,
                         shape =  173,
                     shininess =  174,
                      skeleton =  175,
                          skew =  176,
                          skin =  177,
                sky_colorspace =  178,
                  sky_exposure =  179,
                   skyblendfac =  180,
                  skyblendtype =  181,
                          soft =  182,
                        source =  183,
                      specular =  184,
                        sphere =  185,
                        spline =  186,
                          spot =  187,
                     spotblend =  188,
                      spotsize =  189,
                        spread =  190,
                sun_brightness =  191,
               sun_effect_type =  192,
                 sun_intensity =  193,
                      sun_size =  194,
                       surface =  195,
               tapered_capsule =  196,
              tapered_cylinder =  197,
                       targets =  198,
                     technique =  199,
              technique_common =  200,
                     translate =  201,
                   transparent =  202,
                  transparency =  203,
                     triangles =  204,
                       trifans =  205,
                     tristrips =  206,
                          type =  207,
                          unit =  208,
                       up_axis =  209,
                             v =  210,
                        vcount =  211,
                vertex_weights =  212,
                      vertices =  213,
                  visual_scene =  214,
                          xfov =  215,
                          yfov =  216,
                          zfar =  217,
                         znear =  218,
                    YF_dofdist =  219,
                        shiftx =  220,
                        shifty =  221,
          ambient_diffuse_lock =  222,
  ambient_diffuse_texture_lock =  223,
      apply_reflection_dimming =  224,
         diffuse_specular_lock =  225,
                     dim_level =  226,
               extended_shader =  227,
                  opacity_type =  228,
              reflection_level =  229,
                    reflective =  230,
                        shader =  231,
                        soften =  232,
                   source_data =  233,
          use_self_illum_color =  234,
                     wire_size =  235,
                    wire_units =  236,
}

Collada.elementName = {
  COLLADA = Collada.ID.COLLADA,
  IDREF_array = Collada.ID.IDREF_array,
  Name_array = Collada.ID.Name_array,
  accessor = Collada.ID.accessor,
  adapt_thresh = Collada.ID.adapt_thresh,
  alpha = Collada.ID.alpha,
  ambient = Collada.ID.ambient,
  animation = Collada.ID.animation,
  animation_clip = Collada.ID.animation_clip,
  annotate = Collada.ID.annotate,
  area_shape = Collada.ID.area_shape,
  area_size = Collada.ID.area_size,
  area_sizey = Collada.ID.area_sizey,
  area_sizez = Collada.ID.area_sizez,
  argument = Collada.ID.argument,
  array = Collada.ID.array,
  aspect_ratio = Collada.ID.aspect_ratio,
  asset = Collada.ID.asset,
  atm_distance_factor = Collada.ID.atm_distance_factor,
  atm_extinction_factor = Collada.ID.atm_extinction_factor,
  atm_turbidity = Collada.ID.atm_turbidity,
  att1 = Collada.ID.att1,
  att2 = Collada.ID.att2,
  attachment = Collada.ID.attachment,
  author = Collada.ID.author,
  authoring_tool = Collada.ID.authoring_tool,
  backscattered_light = Collada.ID.backscattered_light,
  bias = Collada.ID.bias,
  bind = Collada.ID.bind,
  bind_material = Collada.ID.bind_material,
  bind_shape_matrix = Collada.ID.bind_shape_matrix,
  bind_vertex_input = Collada.ID.bind_vertex_input,
  blinn = Collada.ID.blinn,
  blue = Collada.ID.blue,
  bool_array = Collada.ID.bool_array,
  box = Collada.ID.box,
  buffers = Collada.ID.buffers,
  bufflag = Collada.ID.bufflag,
  bufsize = Collada.ID.bufsize,
  buftype = Collada.ID.buftype,
  camera = Collada.ID.camera,
  capsule = Collada.ID.capsule,
  channel = Collada.ID.channel,
  clipend = Collada.ID.clipend,
  clipsta = Collada.ID.clipsta,
  code = Collada.ID.code,
  color = Collada.ID.color,
  color_clear = Collada.ID.color_clear,
  color_target = Collada.ID.color_target,
  common_color_or_texture_type = Collada.ID.common_color_or_texture_type,
  common_float_or_param_type = Collada.ID.common_float_or_param_type,
  compiler_options = Collada.ID.compiler_options,
  compiler_target = Collada.ID.compiler_target,
  compressthresh = Collada.ID.compressthresh,
  connect_param = Collada.ID.connect_param,
  constant = Collada.ID.constant,
  constant_attenuation = Collada.ID.constant_attenuation,
  contributor = Collada.ID.contributor,
  control_vertices = Collada.ID.control_vertices,
  controller = Collada.ID.controller,
  convex_mesh = Collada.ID.convex_mesh,
  created = Collada.ID.created,
  cylinder = Collada.ID.cylinder,
  depth_clear = Collada.ID.depth_clear,
  depth_target = Collada.ID.depth_target,
  diffuse = Collada.ID.diffuse,
  directional = Collada.ID.directional,
  dist = Collada.ID.dist,
  double_sided = Collada.ID.double_sided,
  draw = Collada.ID.draw,
  effect = Collada.ID.effect,
  emission = Collada.ID.emission,
  energy = Collada.ID.energy,
  extra = Collada.ID.extra,
  falloff_type = Collada.ID.falloff_type,
  filtertype = Collada.ID.filtertype,
  flag = Collada.ID.flag,
  float = Collada.ID.float,
  float_array = Collada.ID.float_array,
  force_field = Collada.ID.force_field,
  gamma = Collada.ID.gamma,
  geometry = Collada.ID.geometry,
  green = Collada.ID.green,
  halo_intensity = Collada.ID.halo_intensity,
  horizon_brightness = Collada.ID.horizon_brightness,
  image = Collada.ID.image,
  imager = Collada.ID.imager,
  index_of_refraction = Collada.ID.index_of_refraction,
  init_from = Collada.ID.init_from,
  input = Collada.ID.input,
  instance_animation = Collada.ID.instance_animation,
  instance_camera = Collada.ID.instance_camera,
  instance_controller = Collada.ID.instance_controller,
  instance_effect = Collada.ID.instance_effect,
  instance_force_field = Collada.ID.instance_force_field,
  instance_geometry = Collada.ID.instance_geometry,
  instance_light = Collada.ID.instance_light,
  instance_material = Collada.ID.instance_material,
  instance_node = Collada.ID.instance_node,
  instance_physics_material = Collada.ID.instance_physics_material,
  instance_physics_model = Collada.ID.instance_physics_model,
  instance_physics_scene = Collada.ID.instance_physics_scene,
  instance_rigid_body = Collada.ID.instance_rigid_body,
  instance_rigid_constraint = Collada.ID.instance_rigid_constraint,
  instance_visual_scene = Collada.ID.instance_visual_scene,
  int_array = Collada.ID.int_array,
  joints = Collada.ID.joints,
  lambert = Collada.ID.lambert,
  vivlibrary_animation_clips = Collada.ID.vivlibrary_animation_clips,
  library_animations = Collada.ID.library_animations,
  library_cameras = Collada.ID.library_cameras,
  library_controllers = Collada.ID.library_controllers,
  library_effects = Collada.ID.library_effects,
  library_force_fields = Collada.ID.library_force_fields,
  library_geometries = Collada.ID.library_geometries,
  library_images = Collada.ID.library_images,
  library_lights = Collada.ID.library_lights,
  library_materials = Collada.ID.library_materials,
  library_nodes = Collada.ID.library_nodes,
  library_physics_materials = Collada.ID.library_physics_materials,
  library_physics_models = Collada.ID.library_physics_models,
  library_physics_scenes = Collada.ID.library_physics_scenes,
  library_visual_scenes = Collada.ID.library_visual_scenes,
  light = Collada.ID.light,
  linear_attenuation = Collada.ID.linear_attenuation,
  lines = Collada.ID.lines,
  linestrips = Collada.ID.linestrips,
  lookat = Collada.ID.lookat,
  material = Collada.ID.material,
  matrix = Collada.ID.matrix,
  mesh = Collada.ID.mesh,
  mode = Collada.ID.mode,
  modified = Collada.ID.modified,
  morph = Collada.ID.morph,
  newparam = Collada.ID.newparam,
  node = Collada.ID.node,
  optics = Collada.ID.optics,
  orthographic = Collada.ID.orthographic,
  p = Collada.ID.p,
  param = Collada.ID.param,
  perspective = Collada.ID.perspective,
  phong = Collada.ID.phong,
  physics_material = Collada.ID.physics_material,
  physics_model = Collada.ID.physics_model,
  physics_scene = Collada.ID.physics_scene,
  plane = Collada.ID.plane,
  point = Collada.ID.point,
  polygons = Collada.ID.polygons,
  polylist = Collada.ID.polylist,
  profile_COMMON = Collada.ID.profile_COMMON,
  quadratic_attenuation = Collada.ID.quadratic_attenuation,
  ray_samp = Collada.ID.ray_samp,
  ray_samp_method = Collada.ID.ray_samp_method,
  ray_samp_type = Collada.ID.ray_samp_type,
  ray_sampy = Collada.ID.ray_sampy,
  ray_sampz = Collada.ID.ray_sampz,
  red = Collada.ID.red,
  ref_attachment = Collada.ID.ref_attachment,
  reflectivity = Collada.ID.reflectivity,
  rigid_body = Collada.ID.rigid_body,
  rigid_constraint = Collada.ID.rigid_constraint,
  rotate = Collada.ID.rotate,
  samp = Collada.ID.samp,
  sampler = Collada.ID.sampler,
  sampler2D = Collada.ID.sampler2D,
  scale = Collada.ID.scale,
  scene = Collada.ID.scene,
  shadhalostep = Collada.ID.shadhalostep,
  shadow_b = Collada.ID.shadow_b,
  shadow_g = Collada.ID.shadow_g,
  shadow_r = Collada.ID.shadow_r,
  shadspotsize = Collada.ID.shadspotsize,
  shape = Collada.ID.shape,
  shininess = Collada.ID.shininess,
  skeleton = Collada.ID.skeleton,
  skew = Collada.ID.skew,
  skin = Collada.ID.skin,
  sky_colorspace = Collada.ID.sky_colorspace,
  sky_exposure = Collada.ID.sky_exposure,
  skyblendfac = Collada.ID.skyblendfac,
  skyblendtype = Collada.ID.skyblendtype,
  soft = Collada.ID.soft,
  source = Collada.ID.source,
  specular = Collada.ID.specular,
  sphere = Collada.ID.sphere,
  spline = Collada.ID.spline,
  spot = Collada.ID.spot,
  spotblend = Collada.ID.spotblend,
  spotsize = Collada.ID.spotsize,
  spread = Collada.ID.spread,
  sun_brightness = Collada.ID.sun_brightness,
  sun_effect_type = Collada.ID.sun_effect_type,
  sun_intensity = Collada.ID.sun_intensity,
  sun_size = Collada.ID.sun_size,
  surface = Collada.ID.surface,
  tapered_capsule = Collada.ID.tapered_capsule,
  tapered_cylinder = Collada.ID.tapered_cylinder,
  targets = Collada.ID.targets,
  technique = Collada.ID.technique,
  technique_common = Collada.ID.technique_common,
  translate = Collada.ID.translate,
  transparent = Collada.ID.transparent,
  transparency = Collada.ID.transparency,
  triangles = Collada.ID.triangles,
  trifans = Collada.ID.trifans,
  tristrips = Collada.ID.tristrips,
  type = Collada.ID.type,
  unit = Collada.ID.unit,
  up_axis = Collada.ID.up_axis,
  v = Collada.ID.v,
  vcount = Collada.ID.vcount,
  vertex_weights = Collada.ID.vertex_weights,
  vertices = Collada.ID.vertices,
  visual_scene = Collada.ID.visual_scene,
  xfov = Collada.ID.xfov,
  yfov = Collada.ID.yfov,
  zfar = Collada.ID.zfar,
  znear = Collada.ID.znear,
  YF_dofdist = Collada.ID.YF_dofdist,
  shiftx = Collada.ID.shiftx,
  shifty = Collada.ID.shifty,
  ambient_diffuse_lock = Collada.ID.ambient_diffuse_lock,
  ambient_diffuse_texture_lock =  Collada.ID.ambient_diffuse_texture_lock,
  apply_reflection_dimming = Collada.ID.apply_reflection_dimming,
  diffuse_specular_lock = Collada.ID.diffuse_specular_lock,
  dim_level = Collada.ID.dim_level,
  extended_shader = Collada.ID.extended_shader,
  opacity_type = Collada.ID.opacity_type,
  reflection_level = Collada.ID.reflection_level,
  reflective = Collada.ID.reflective,
  shader = Collada.ID.shader,
  soften = Collada.ID.soften,
  source_data = Collada.ID.source_data,
  use_self_illum_color = Collada.ID.use_self_illum_color,
  wire_size = Collada.ID.wire_size,
  wire_units = Collada.ID.wire_units,
}

function Collada.new(self)
  local obj = Object.new(self)
  obj.start_pos = 1
  obj.collada_text = ""
  obj.OPEN  = 1
  obj.CLOSE = 2
  obj.EMPTY = 3
  obj.mesh_count = 0
  obj.current = 1
  obj.skin_count = 0
  obj.meshes = {}
  obj.rootFrame = Frame:new(nil, "root")
  obj.anim = Animation:new("ColladaAnimation")
  return obj
end

function Collada.printf(self, fmt, ...)
  if self.printflag then
    util.printf(fmt, ...)
  end
end

function Collada.getMeshes(self)
  return self.meshes
end

function Collada.getMeshCount(self)
  return self.mesh_count
end

function Collada.releaseMeshes(self)
  self.meshes = {}
  self.mesh_count = 0
end

-- ----------------------------
-- getNextTag
-- ----------------------------
function Collada.parseText(self, string_to_parse)
  local data = {}
  for s in string_to_parse:gmatch('[^%s<>]+') do
    table.insert(data, s)
  end
  return data
end

function Collada.parseArgs(self, string_to_parse)
  local arg = {}
  string.gsub(string_to_parse, "([%w_]+)=([%\"'])(.-)%2",
    function (attribute_name, delim, value)
      arg[attribute_name] = value
    end)
  return arg
end

function Collada.getNextTag(self)
  local closing_tag, element_name, attributes, empty_tag
  local find_pos, end_pos = 1, 1
  local tag_type
  local tag = {}

  find_pos, end_pos, closing_tag, element_name, attributes, empty_tag =
    string.find(self.collada_text, "<(%/?)([%?%w_]+)(.-)(%/?)>", self.start_pos)

  if not find_pos then return nil end
  tag.element = self.elementName[element_name]
  tag.elementName = element_name
  local text = string.sub(self.collada_text, self.start_pos, find_pos - 1)
  if not string.find(text, "^%s*$") then
    tag.data = self:parseText(text)
  end

  if empty_tag == "/" then tag.type = self.EMPTY
  elseif closing_tag == "/" then tag.type = self.CLOSE
  else tag.type = self.OPEN end

  tag.args = self:parseArgs(attributes)
  self.start_pos = end_pos + 1
  return tag
end

-- ----------------------------
-- skip
-- ----------------------------
function Collada.skip(self, tag)
  local t
  repeat
    t = self:getNextTag()
  until t.element == tag.element and t.type == self.CLOSE
end

function Collada.skipToClosingTag(self, element)
  local tag
  local stack = Stack:new()
  stack:push(element)
  repeat
    tag = self:getNextTag()
    if tag.type == self.OPEN then
      stack:push(tag.element)
    elseif tag.type == self.CLOSE then
      if stack:top() == tag.element then
        stack:pop()
      else
        util.printf("Error : closing %s\n", tag.elementName)
      end
    end
  until tag.element == element and tag.type == self.CLOSE
end

-- ----------------------------
-- <asset>
-- ----------------------------
function Collada.asset(self, tag)
  if tag.type == self.EMPTY then return end
  self:skipToClosingTag(self.ID.asset)
end

-- ----------------------------
-- <library_cameras>
-- ----------------------------
function Collada.library_cameras(self, tag)
  if tag.type == self.EMPTY then return end
  self:skipToClosingTag(self.ID.library_cameras)
end

-- ----------------------------
-- <library_lights>
-- ----------------------------
function Collada.library_lights(self, tag)
  if tag.type == self.EMPTY then return end
  self:skipToClosingTag(self.ID.library_lights)
end

-- ----------------------------
-- <library_images>
-- ----------------------------
function Collada.library_images(self, tag)
  if tag.type == self.EMPTY then return end
  self:skipToClosingTag(self.ID.library_images)
end

-- ----------------------------
-- <library_effects>
-- ----------------------------
function Collada.library_effects(self, tag)
  if tag.type == self.EMPTY then return end
  self:skipToClosingTag(self.ID.library_effects)
end

-- ----------------------------
-- <library_materials>
-- ----------------------------
function Collada.library_materials(self, tag)
  if tag.type == self.EMPTY then return end
  self:skipToClosingTag(self.ID.library_materials)
end

-- ----------------------------
-- <source>
-- ----------------------------
function Collada.getNumList(self, tag_id)
  local t
  local data_list = {}
  t = self:getNextTag()
  if t.element == tag_id and t.type == self.CLOSE then
    for i = 1, #t.data do
      table.insert(data_list, tonumber(t.data[i]))
    end
  end
  return data_list
end

function Collada.getList(self, tag_id)
  local t
  local data_list
  t = self:getNextTag()
  if t.element == tag_id and t.type == self.CLOSE then
    data_list = t.data
  end
  return data_list
end

function Collada.source(self)
  local t
  local data_list
  repeat
    t = self:getNextTag()
    if t.element == self.ID.float_array then
      if t.type ~= self.EMPTY then
        data_list = self:getNumList(self.ID.float_array)
        self:printf("float_array: %d floats\n", #data_list)
      else
        data_list = {}
      end
    elseif t.element == self.ID.Name_array then
      if t.type ~= self.EMPTY then
        data_list = self:getList(self.ID.Name_array)
        self:printf("Name_array: %d words\n", #data_list)
      else
        data_list = {}
      end
    elseif t.element == self.ID.technique_common then
      t = self:getNextTag()
      if t.element == self.ID.accessor then
        repeat
          t = self:getNextTag()
          if t.element == self.ID.param then
            self:printf("<param name=%s>\n", t.args.name)
          end
        until t.element == self.ID.accessor and t.type == self.CLOSE
      end
      t = self:getNextTag()
      if t.element == self.ID.technique_common then
        if t.type ~= 2 then
          util.printf("Error : expect </technique_common>, found <%s>\n",
                       t.elementName)
          assert(false)
        end
      end
    end
  until t.element == self.ID.source and t.type == self.CLOSE
  return data_list
end

function Collada.getPolygonData(self, p, pointer, data_count)
  local position, normal, tex_uv1, tex_uv2, tex_uv3, color
  if data_count == 6 then
    position = p[pointer + 1]
    normal   = p[pointer + 2]
    tex_uv1  = p[pointer + 3]
    tex_uv2  = p[pointer + 4]
    tex_uv3  = p[pointer + 5]
    color    = p[pointer + 6]
    return {position, normal, tex_uv1, tex_uv2, tex_uv3, color}
  elseif data_count == 5 then
    position  = p[pointer + 1]
    normal    = p[pointer + 2]
    tex_uv1   = p[pointer + 3]
    tex_uv2   = p[pointer + 4]
    color     = p[pointer + 5]
    return {position, normal, tex_uv1, tex_uv2, color}
  elseif data_count == 4 then
    position = p[pointer + 1]
    normal   = p[pointer + 2]
    tex_uv1  = p[pointer + 3]
    color    = p[pointer + 4]
    return {position, normal, tex_uv1, color}
  elseif data_count == 3 then
    position = p[pointer + 1]
    normal   = p[pointer + 2]
    tex_uv1  = p[pointer + 3]
    return {position, normal, tex_uv1}
  elseif data_count == 2 then
    position = p[pointer + 1]
    normal   = p[pointer + 2]
    return {position, normal}
  elseif data_count == 1 then
    position = p[pointer + 1]
    return {position}
  end
end

-- ----------------------------
-- <mesh>
-- ----------------------------
function Collada.geo_mesh(self, id)
  local t
  local find_pos, end_pos
  local positions, normals, texture_uvs, colors
  local textures = {}
  local polygons = {}
  self.mesh_count = self.mesh_count + 1
  self.current = self.mesh_count
  table.insert(self.meshes, Mesh:new(nil))
  self.meshes[self.current]:setName(id)

  repeat
    t = self:getNextTag()

    if t.element == self.ID.source then
      self:printf("<%s id=%s>\n", t.elementName, t.args.id)
      find_pos, end_pos = string.find(t.args.id, "%-position")
      if find_pos ~= nil then
        positions = self:source()
      else
        find_pos, end_pos = string.find(t.args.id, "%-normal")
        if find_pos ~= nil then
          normals = self:source()
        else
          find_pos, end_pos = string.find(t.args.id, "%-color")
          if find_pos ~= nil then
            colors = self:source()
          else
            find_pos, end_pos = string.find(t.args.id, "%-map")
            if find_pos == nil then
              find_pos, end_pos = string.find(t.args.id, "%-uv")
            end
            if find_pos ~= nil then
              texture_uvs = self:source()
              table.insert(textures, texture_uvs)
            end
          end
        end
      end

    elseif t.element == self.ID.vertices then
      self:printf("<%s>\n", t.elementName)
      repeat
        t = self:getNextTag()
        if t.element == self.ID.input and t.type == self.EMPTY then
          self:printf("<%s semantic=%s>\n", t.elementName,
                     t.args.semantic)
        end
      until t.element == self.ID.vertices and t.type == self.CLOSE

    elseif t.element == self.ID.polylist then
      local max_offset = 0
      local offset
      local vcount, p
      local input_count = 0
      repeat
        t = self:getNextTag()
        if t.element == self.ID.input and t.type == self.EMPTY then
          offset = tonumber(t.args.offset)
          self:printf("<%s semantic=%s offset=%d >\n", t.elementName,
                     t.args.semantic,  offset)
          input_count = input_count + 1
          if offset > max_offset then max_offset = offset end
        elseif t.element == self.ID.vcount and t.type == self.OPEN then
          vcount = self:getNumList(self.ID.vcount)
        elseif t.element == self.ID.p and t.type == self.OPEN then
          p = self:getNumList(self.ID.p)
        end
      until t.element == self.ID.polylist and t.type == self.CLOSE
      local vcount_sum = 0
      local stride = max_offset + 1
      for i = 1, #vcount do
        local polygon = {}
        for k = 0, vcount[i] - 1 do
          local data = self:getPolygonData(p, vcount_sum + k * stride, stride)
          table.insert(polygon, data)
        end
        vcount_sum = vcount_sum + (vcount[i] * stride)
        table.insert(polygons, polygon)
      end
      self:printf("<polylist> input=%d  vertices=%d polygons=%d\n",
                   input_count, #vcount, #polygons)

    elseif t.element == self.ID.triangles then
      self:printf("<%s>\n", t.elementName)
      local max_offset = 0
      local offset
      local p
      local input_count = 0
      repeat
        t = self:getNextTag()
        if t.element == self.ID.input and t.type == self.EMPTY then
          offset = tonumber(t.args.offset)
          self:printf("<%s semantic=%s offset=%d >\n", t.elementName,
                     t.args.semantic,  offset)
          input_count = input_count + 1
          if offset > max_offset then max_offset = offset end
        elseif t.element == self.ID.p and t.type == self.OPEN then
          p = self:getNumList(self.ID.p)
        elseif t.element == self.ID.p and t.type == self.EMPTY then
      p = {}
        end
      until t.element == self.ID.triangles and t.type == self.CLOSE
      local vcount_sum = 0
      local stride = max_offset + 1
      for i = 1, 3 do
        local polygon = {}
        for k = 0, 2 do
          local data = self:getPolygonData(p, vcount_sum + k*stride, stride)
          table.insert(polygon, data)
        end
        vcount_sum = vcount_sum + stride * 3
        table.insert(polygons, polygon)
      end
      self:printf("<triangles> input=%d  vertices=%d polygons=%d\n",
           input_count, vcount_sum, #polygons)

    elseif t.element == self.ID.lines then
      self:skipToClosingTag(self.ID.lines)
    elseif t.element == self.ID.linestrips then
      self:skipToClosingTag(self.ID.linestrips)
    else
      if t.type ~= self.CLOSE then
        util.printf("Error : <%s>\n", t.elementName)
        assert(false)
      end
    end
  until t.element == self.ID.mesh and t.type == self.CLOSE

  self.meshes[self.current]:setName(id)
  if #positions > 0 then self.meshes[self.current]:setVertices(positions) end
  if #normals > 0   then self.meshes[self.current]:setNormals(normals) end
  if #textures > 0 then self.meshes[self.current]:setTextureCoord(textures) end
  if #polygons > 0  then self.meshes[self.current]:setPolygons(polygons) end

end

-- ----------------------------
-- <extra>
-- ----------------------------
function Collada.extra(self, tag)
  local t
  self:printf("<%s>\n", tag.elementName)
  repeat
    t = self:getNextTag()
    self:printf("<%s>\n", t.elementName)
  until t.element == self.ID.extra and t.type == self.CLOSE
end

-- ----------------------------
-- <library_geometries>
-- ----------------------------
function Collada.library_geometries(self, tag)
  local t
  local geo_id
  if tag.type == self.EMPTY then return end
  repeat
    t = self:getNextTag()
    if t.element == self.ID.geometry and t.type == self.OPEN then
      geo_id = t.args.id
      t = self:getNextTag()
      if t.element == self.ID.mesh then
         self:geo_mesh(geo_id)
      elseif t.element == self.ID.extra then
         self:extra(t)
      elseif t.element == self.ID.geometry then
        if t.type ~= self.CLOSE then
          util.printf("Error : <%s>\n", t.elementName)
          assert(false)
        end
      end
    end
  until t.element == self.ID.library_geometries and t.type == self.CLOSE
end

-- ----------------------------
-- <skin>
-- ----------------------------
function Collada.controller_skin(self, source_name)
  local t
  local find_pos, end_pos
  local joint_names, bind_poses, skin_weights
  local vcount, v
  local bind_shape_matrix = Matrix:new()
  self.skin_count = self.skin_count + 1

  repeat
    t = self:getNextTag()

    if t.element == self.ID.source then
      find_pos, end_pos = string.find(t.args.id, "%-skin%d*%-joints$")
      if find_pos ~= nil then
        joint_names = self:source()
      else
        find_pos, end_pos = string.find(t.args.id, "%-skin%d*%-bind_poses$")
        if find_pos ~= nil then
          bind_poses = self:source()
        else
          find_pos, end_pos = string.find(t.args.id, "%-skin%d*%-weights$")
          if find_pos ~= nil then
            skin_weights = self:source()
          end
        end
      end

    elseif t.element == self.ID.bind_shape_matrix  and t.type == self.OPEN then
      bind_shape_matrix:setBulk(self:getNumList(self.ID.bind_shape_matrix))
      bind_shape_matrix:transpose()
      self:printf("<%s>\n", t.elementName)
      if self.printflag then bind_shape_matrix:print() end
    elseif t.element == self.ID.joints then
      self:printf("<%s>\n", t.elementName)
      repeat
        t = self:getNextTag()
        if t.element == self.ID.input and t.type == self.EMPTY then
          self:printf("<%s semantic=%s>\n", t.elementName, t.args.semantic)
        end
      until t.element == self.ID.joints and t.type == self.CLOSE

    elseif t.element == self.ID.vertex_weights then
      self:printf("<%s>\n", t.elementName)
      repeat
        t = self:getNextTag()
        if t.element == self.ID.input and t.type == self.EMPTY then
          self:printf("<%s semantic=%s>\n", t.elementName, t.args.semantic)
        elseif t.element == self.ID.vcount and t.type == self.OPEN then
          vcount = self:getNumList(self.ID.vcount)
        elseif t.element == self.ID.v and t.type == self.OPEN then
          v = self:getNumList(self.ID.v)
        end
      until t.element == self.ID.vertex_weights and t.type == self.CLOSE

    else
      if t.type ~= self.CLOSE then
        util.printf("Error : <%s>\n", t.elementName)
        assert(false)
      end
    end
  until t.element == self.ID.skin and t.type == self.CLOSE

  local skinweights = {}
  if #vcount > 0 then
    local index = 0
    for i = 1, #vcount do
      local temp = {}
      for j = 1, vcount[i] do
        -- v = { bone_idx, sw_idx, bone_idx, sw_idx, .. }
        table.insert(temp, v[index * 2 + 1])  -- bone index
        table.insert(temp, skin_weights[ v[index * 2 + 2] + 1])
        index = index + 1
      end
      table.insert(skinweights, temp)
    end
    for i = 1, self.mesh_count do
      local id_name = "#" .. self.meshes[i]:getName()
      if source_name == id_name then
        -- found
        self.meshes[i]:setSkinWeights(skinweights)
        self.meshes[i]:setJointNames(joint_names)
        local bindPoseMatrices = {}
        for n = 1, #joint_names do
           local m = Matrix:new()
           local tmp = {}
           for j = 1, 16 do
             table.insert(tmp, bind_poses[(n-1) * 16 + j])
           end
           m:setBulk(tmp)
           m:transpose() -- inverse bind-pose matrix
           table.insert(bindPoseMatrices, m)
        end
        self.meshes[i]:setBindPoseMatrices( bindPoseMatrices )
        self.meshes[i]:setBindShapeMatrix(bind_shape_matrix)
        break
      end
    end
  end
end

-- ----------------------------
-- <library_controllers>
-- ----------------------------
function Collada.library_controllers(self, tag)
  local t
  if tag.type == self.EMPTY then return end
  repeat
    t = self:getNextTag()
    if t.element == self.ID.controller and t.type == self.OPEN then
      self:printf("<controller id=\"%s\">\n", t.args.id)
      t = self:getNextTag()
      if t.element == self.ID.skin and t.type == self.OPEN then
         self:controller_skin(t.args.source)
      elseif t.element == self.ID.controller then
        if t.type ~= self.CLOSE then
          util.printf("Error : <%s>\n", t.elementName)
          assert(false)
        end
      end
    end
  until t.element == self.ID.library_controllers and t.type == self.CLOSE
end

-- ----------------------------
-- <node>
-- ----------------------------
function Collada.node(self, tag, parent_frame)
  local t
  local frame = Frame:new(parent_frame, tag.args.id)
  frame:setType(tag.args.type)
  repeat
    t = self:getNextTag()
    if t.element == self.ID.matrix and t.type == self.OPEN then
      -- node local matrix
      local mat = Matrix:new()
      local m = self:getNumList(self.ID.matrix)
      mat:setBulk(m)
      mat:transpose()
      if self.printflag then mat:print() end
      frame:setByMatrix(mat)
    elseif t.element == self.ID.translate and t.type == self.OPEN then
      self:getNumList(self.ID.translate)
    elseif t.element == self.ID.rotate and t.type == self.OPEN then
      self:getNumList(self.ID.rotate)
    elseif t.element == self.ID.scale and t.type == self.OPEN then
      self:getNumList(self.ID.scale)
    elseif t.element == self.ID.node and t.type == self.OPEN then
      self:printf("<node id=\"%s\" type=\"%s\">\n", t.args.id, t.args.type)
      self:node(t, frame)
    elseif t.element == self.ID.instance_controller
           and t.type == self.OPEN then
      repeat
        t = self:getNextTag()
        if t.element == self.ID.skeleton and t.type == self.OPEN then
          self:getList(self.ID.skeleton)
        elseif t.element == self.ID.bind_material and t.type == self.OPEN then
          -- skip
          self:skipToClosingTag(self.ID.bind_material)
        end
      until t.element == self.ID.instance_controller and t.type == self.CLOSE
    end
  until t.element == self.ID.node and t.type == self.CLOSE
end

-- ----------------------------
-- <library_visual_scenes>
-- ----------------------------
function Collada.library_visual_scenes(self, tag)
  local t
  if tag.type == self.EMPTY then return end
  t = self:getNextTag()
  if t.element == self.ID.visual_scene and t.type == self.OPEN then
    repeat
      t = self:getNextTag()
      if t.element == self.ID.node then
         self:printf("<node id=\"%s\" type=\"%s\">\n", t.args.id, t.args.type)
         self:node(t, self.rootFrame)
      elseif t.element == self.ID.visual_scene then
        if t.type ~= self.CLOSE then
          util.printf("Error : <%s>\n", t.elementName)
          assert(false)
        end
      end
    until t.element == self.ID.library_visual_scenes and t.type == self.CLOSE
  end
end

function Collada.checkAnimationType(self, id)
  local find_pos, end_pos, axis
  local type = 0 -- 0:position, 1:rotation, 2:matrix, 3:scale
  find_pos, end_pos, axis = string.find(id, "location[%_%.](%c)%-output")
  if find_pos == nil then
    find_pos, end_pos, axis = string.find(id, "euler[%_%.](%c)%-output")
    type = 1
    if find_pos == nil then
      find_pos, end_pos, axis = string.find(id, "scale[%_%.](%c)%-output")
      type = 3
      if find_pos == nil then
        find_pos, end_pos, axis = string.find(id, "matrix%-output")
        type = 2
        if find_pos == nil then
          type = -1
        end
      end
    end
  end
  return type, axis
end

-- ----------------------------
-- <animation>
-- ----------------------------
function Collada.animation(self, tag, parent)
  local t
  local find_pos, end_pos
  local times, output
  local bone_name
  local kind = nil
  local axis = nil
  local anim_id = tag.args.id
  self:printf("<animation id=\"%s\" type=\"%s\">\n", anim_id, tag.args.type)
  if tag.args.id ~= nil then
    bone_name = string.match(anim_id, "Armature[%d_]+([%w_]+)_pose_matrix$")
  end
  repeat
    t = self:getNextTag()
    if t.element == self.ID.source then
      find_pos, end_pos = string.find(t.args.id, "%-input")
      if find_pos ~= nil then
        times = self:source()
      else
        find_pos, end_pos = string.find(t.args.id, "%-output")
        if find_pos ~= nil then
          kind, axis = self:checkAnimationType(t.args.id)
          output = self:source()
        else -- other sources are ignored.
          self:skipToClosingTag(self.ID.source)
        end
      end
    elseif t.element == self.ID.sampler and t.type == self.OPEN then
      if t.type ~= self.EMPTY then
        self:skipToClosingTag(self.ID.sampler)
      end
    elseif t.element == self.ID.channel then
      if t.type ~= self.EMPTY then
        self:skipToClosingTag(self.ID.channel)
      end
    elseif t.element == self.ID.asset and t.type == self.OPEN then
      self:asset(t)
    elseif t.element == self.ID.extra and t.type == self.OPEN then
      self:extra(t)
    elseif t.element == self.ID.animation and t.type == self.OPEN then
      self:animation(t, parent)
    end
  until t.element == self.ID.animation and t.type == self.CLOSE
  return times, output, kind, axis, bone_name
end

-- ----------------------------
-- <library_animations>
-- ----------------------------
function Collada.library_animations(self, tag)
  local t
  local times, output, bone_name
  local kind = nil
  local axis = nil
  local anim = self.anim

  if tag.type == self.EMPTY then return end
  repeat
    t = self:getNextTag()
    if t.element == self.ID.animation and t.type == self.OPEN then
      local loc, rot, scale
      if t.args.id ~= nil then
        loc = string.match(t.args.id, "_location")
        rot = string.match(t.args.id, "_rotation_euler")
        scale = string.match(t.args.id, "_scale")
      end
      if (loc ~= nil) or (rot ~= nil) or (scale ~= nil) then
        self:skipToClosingTag(self.ID.animation)
      else
        local bone_poses = {}
        times, output, kind, axis, bone_name = self:animation(t, nil)
        self:printf("%s #key = %d, #output = %d, type:%s, axis:%s\n",
                bone_name, #times, #output, kind, axis)
        -- We assume <source> is pose_matrix, not location or rotation.
        if kind == 2 then -- pose_matrix
          for i = 1, #times do
            local mat = Matrix:new()
            mat:setBulkWithOffset(output, (i - 1) * 16)
            mat:transpose()
            table.insert(bone_poses, mat)
          end
        end
        anim:setTimes(times)
        anim:addBoneName(bone_name)
        anim:setBonePoses(bone_poses)
      end
    elseif t.element == self.ID.animation then
      if t.type ~= self.CLOSE then
        util.printf("Error : <%s>\n", t.elementName)
        assert(false)
      end
    elseif tag.element == self.ID.asset and tag.type == self.OPEN then
      self:asset(tag)
    elseif t.element == self.ID.extra then
      self:extra(t)
    end
  until t.element == self.ID.library_animations and t.type == self.CLOSE
end

-- ----------------------------
-- <scene>
-- ----------------------------
function Collada.scene(self, tag)
  if tag.type == self.EMPTY then return end
  self:skipToClosingTag(self.ID.scene)
end

function Collada.getAnimation(self)
  return self.anim
end

-- ----------------------------
-- parse
-- ----------------------------
function Collada.parse(self, text, verbose)
  local stack = Stack:new()
  local tree = {}
  local data
  local context
  local skipElement = false
  local tag

  self.printflag = verbose
  self.collada_text = text
  tag = self:getNextTag()
  if tag.elementName ~= "?xml" then
    util.printf("Error : The file is not XML format.\n")
    return false
  end
  tag = self:getNextTag()
  if tag.element ~= self.ID.COLLADA then
    util.printf("Error : The file is not COLLADA format.\n")
    return false
  end

  repeat
    tag = self:getNextTag()
    if tag.element == self.ID.asset then
      self:asset(tag)
    elseif tag.element == self.ID.library_cameras then
      self:library_cameras(tag)
    elseif tag.element == self.ID.library_lights then
      self:library_lights(tag)
    elseif tag.element == self.ID.library_images then
      self:library_images(tag)
    elseif tag.element == self.ID.library_effects then
      self:library_effects(tag)
    elseif tag.element == self.ID.library_materials then
      self:library_materials(tag)
    elseif tag.element == self.ID.library_geometries then
      self:library_geometries(tag)
    elseif tag.element == self.ID.library_controllers then
      self:library_controllers(tag)
    elseif tag.element == self.ID.library_visual_scenes then
      self:library_visual_scenes(tag)
    elseif tag.element == self.ID.library_animations then
      self:library_animations(tag)
    elseif tag.element == self.ID.scene then
      self:scene(tag)
    else
      if tag.element ~= self.ID.COLLADA then
        util.printf("Error : find <%s>\n", tag.elementName)
        return false
      end
    end
  until tag.element == self.ID.COLLADA  and tag.type == self.CLOSE
  return self.anim:close()
end
