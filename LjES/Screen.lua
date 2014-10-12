-- ---------------------------------------------
-- Screen.lua       2014/10/13
--   Copyright (c) 2013-2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

local ffi = require("ffi")
local bit = require("bit")

local gl = require("gles2")
local bcm = require("bcm")
local egl = require("egl")
local png = require("png")
local util = require("util")

require("Object")

Screen = Object:new()

ffi.cdef[[

struct fb_fix_screeninfo {
    char id[16];
    unsigned long smem_start;
    unsigned int smem_len;
    unsigned int type;
    unsigned int type_aux;
    unsigned int visual;
    unsigned short xpanstep;
    unsigned short ypanstep;
    unsigned short ywrapstep;
    unsigned int line_length;
    unsigned long mmio_start;
    unsigned int mmio_len;
    unsigned int accel;
    unsigned short reserved[3];
};

struct fb_bitfield {
    unsigned int offset;
    unsigned int length;
    unsigned int msb_right;
};

struct fb_var_screeninfo {
    unsigned int xres;
    unsigned int yres;
    unsigned int xres_virtual;
    unsigned int yres_virtual;
    unsigned int xoffset;
    unsigned int yoffset;
    unsigned int bits_per_pixel;
    unsigned int grayscale;
    struct fb_bitfield red;
    struct fb_bitfield green;
    struct fb_bitfield blue;
    struct fb_bitfield transp;
    unsigned int nonstd;
    unsigned int activate;
    unsigned int height;
    unsigned int width;
    unsigned int accel_flags;
    unsigned int pixclock;
    unsigned int left_margin;
    unsigned int right_margin;
    unsigned int upper_margin;
    unsigned int lower_margin;
    unsigned int hsync_len;
    unsigned int vsync_len;
    unsigned int sync;
    unsigned int vmode;
    unsigned int rotate;
    unsigned int reserved[5];
};

int ioctl(int, unsigned long, ...);
int open(const char* filename, int flags);
int close(int fd);
]]

-- get framebufer resolution for checking overscan.
function Screen.fbinfo(self)
  local FBIOGET_VSCREENINFO = 17920 -- 0x4600
  local FBIOPUT_VSCREENINFO = 17921 -- 0x4601
  local FBIOGET_FSCREENINFO = 17922 -- 0x4602
  local O_RDONLY = 0

  local fsinfo = ffi.new("struct fb_fix_screeninfo[1]")
  local vsinfo = ffi.new("struct fb_var_screeninfo[1]")
  local fd = ffi.C.open("/dev/fb0", O_RDONLY)
  ffi.C.ioctl(fd, FBIOGET_FSCREENINFO, fsinfo)
  ffi.C.ioctl(fd, FBIOGET_VSCREENINFO, vsinfo)
  self.fsinfo = fsinfo[0]
  self.vsinfo = vsinfo[0]
  util.printf("x-res:%d\n", self.vsinfo.xres)
  util.printf("y-res:%d\n", self.vsinfo.yres)
  ffi.C.close(fd)
end

function Screen.new(self)
  local obj = Object.new(self)
  obj.fullWidth = 0
  obj.fullHeight = 0
  obj.width = 0
  obj.height = 0
  obj.x = 0
  obj.y = 0
  obj.nativewindow = nil
  obj.majorVersion = 0
  obj.minorVersion = 0
  obj.display = 0
  obj.surface = 0
  obj.overscan = false
  obj.overscanX = 0
  obj.overscanY = 0
  obj.clearColor = {0.0, 0.0, 0.0, 1.0}
  obj.fsinfo = {}
  obj.vsinfo = {}
  return obj
end

function Screen.checkOverscan(self)
  local size = {}

  if self.vsinfo.xres < self.fullWidth then
    self.overscanX = (self.fullWidth - self.vsinfo.xres) / 2
    self.fullWidth = self.vsinfo.xres
    self.overscan = true
  end
  if self.vsinfo.yres < self.fullHeight then
    self.overscanY = (self.fullHeight - self.vsinfo.yres) / 2
    self.fullHeight = self.vsinfo.yres
    self.overscan = true
  end
end

function Screen.checkSize(self, w, h, x, y)
  local size = {}

  if (w > 0) then
    if w < self.fullWidth then
      size.width = w
    else
      size.width = self.fullWidth
      if self.overscan then
        size.x = self.overscanX
      else
        size.x = 0
      end
    end
  elseif (w == 0) then
    size.width = self.fullWidth
    size.x = 0
  elseif (w < 0) then
    size.width = self.fullWidth + w
    x = - w/2
    if size.width <=0 then
      size.width = self.fullWidth
      size.x = 0
    end
  end

  if (h > 0) then
    if h < self.fullHeight then
      size.height = h
    else
      size.height = self.fullHeight
      size.y = 0
    end
  elseif (h == 0) then
    size.height = self.fullHeight
    size.y = 0
  elseif (h < 0) then
    size.height = self.fullHeight + h
    y = - h/2
    if size.height <= 0 then
      size.height =self.fullHeight
      size.y = 0
    end
  end

  if (x < 0) then
    size.x = (self.fullWidth - size.width) / 2
  else
    size.x = x
  end

  if (y < 0) then
    size.y = (self.fullHeight - size.height) / 2
  else
    size.y = y
  end

  if self.overscan then
    size.x = size.x + self.overscanX
    size.y = size.y + self.overscanY
  end

  return size.width, size.height, size.x, size.y
end

function Screen.bcm_init(self, w, h, x, y)
  bcm.bcm_host_init()
  self.init = {width = w, height = h, offsetx = x, offsety = y}

  local ww = ffi.new("uint32_t[1]")
  local hh = ffi.new("uint32_t[1]")
  local s = bcm.graphics_get_display_size(0, ww, hh)
  self.fullWidth = ww[0]
  self.fullHeight = hh[0]

  self:checkOverscan()
  self.width, self.height, self.x, self.y = self:checkSize(w, h, x, y)

  local VC_DISPMANX_ALPHA_T = ffi.typeof("VC_DISPMANX_ALPHA_T")
  local EGL_DISPMANX_WINDOW_T = ffi.typeof("EGL_DISPMANX_WINDOW_T")

  local dst_rect = bcm.VC_RECT_T(self.x, self.y, self.width, self.height)
  local src_rect = bcm.VC_RECT_T(0, 0, bit.lshift(self.width, 16),
                                   bit.lshift(self.height,16))
  local dispman_display = bcm.vc_dispmanx_display_open(0)
  local dispman_update = bcm.vc_dispmanx_update_start(0)

  -- local alpha = VC_DISPMANX_ALPHA_T(1, 255, 0)
  -- local dispman_element = bcm.vc_dispmanx_element_add(dispman_update,
  --       dispman_display, 0, dst_rect, 0, src_rect, 0, alpha, nil, 0)

  local dispman_element = bcm.vc_dispmanx_element_add(dispman_update,
      dispman_display, 0, dst_rect, 0, src_rect, 0, nil, nil, 0)
  bcm.vc_dispmanx_update_submit_sync(dispman_update)

  self.dispman_display = dispman_display
  self.element = dispman_element
  self.nativewindow = EGL_DISPMANX_WINDOW_T(dispman_element,
                             self.width, self.height)
end

function Screen.deinit(self)
  bcm.bcm_host_deinit()
end

function Screen.restoreSize(self)
  local ini = self.init
  self:move(ini.width, ini.height, ini.offsetx, ini.offsety)
end

function Screen.move(self, w, h, x, y)
  local size = {}
  size.width, size.height, size.x, size.y = self:checkSize(w, h, x, y)

  local dst_rect = bcm.VC_RECT_T(size.x, size.y, size.width, size.height)
  local dispman_update = bcm.vc_dispmanx_update_start(0)

  local res = bcm.vc_dispmanx_element_change_attributes(dispman_update,
                self.element, bcm.ELEMENT_CHANGE_DEST_RECT, 0,
                0, dst_rect, nil, 0, 0)
  bcm.vc_dispmanx_update_submit_sync(dispman_update)
end

function Screen.egl_init(self)
  local CONTEXT = ffi.new('int[3]', {egl.CONTEXT_CLIENT_VERSION, 2,
                                     egl.NONE})
  local attrib = ffi.new('int[11]', {egl.RED_SIZE, 8,
      egl.GREEN_SIZE, 8, egl.BLUE_SIZE, 8, egl.ALPHA_SIZE, 8,
      egl.DEPTH_SIZE, 24, egl.NONE})

  local numConfigs = ffi.new('int[1]')
  local config = ffi.new('void *[1]')
  local display = egl.getDisplay(ffi.cast("EGLDisplay",egl.DEFAULT_DISPLAY))
  assert(display, "eglGetDisplay failed.")

  local major = ffi.new("uint32_t[1]")
  local minor = ffi.new("uint32_t[1]")
  local res = egl.initialize(display, major, minor)
  assert(res ~= 0, "eglInitialize failed.")
  self.majorVersion = major[0]
  self.minorVersion = minor[0]

  res = egl.chooseConfig(display, attrib, config, 1, numConfigs)
  assert(res ~= 0, "eglChooseConfig failed.")
  local surface = egl.createWindowSurface(display, config[0],
                  self.nativewindow, nil)

  assert(surface, "eglCreateWindowSurface failed.")

  local context = egl.createContext(display, config[0], nil, CONTEXT)
  assert(context, "eglCreateContext failed.")

  res = egl.makeCurrent(display, surface, surface, context)
  assert(res ~= 0, "eglMakeCurrent failed.")

  self.frames = 0
  self.display = display
  self.surface = surface
  return true
end

function Screen.setClearColor(self, r, g, b, alpha)
  self.clearColor = {r, g, b, alpha}
end

function Screen.cullFace(self)
  gl.cullFace(gl.BACK)
  gl.frontFace(gl.CCW)
  gl.enable(gl.CULL_FACE)
  gl.enable(gl.DEPTH_TEST)
end

function Screen.init(self, w, h, x, y)
  self:fbinfo()
  self:bcm_init(w, h, x, y)
  self:egl_init()
  self:cullFace()
end

function Screen.getFrameCount(self)
  return self.frames
end

function Screen.getAspect(self)
  return self.width / self.height
end

function Screen.getWidth(self)
  return self.width
end

function Screen.getHeight(self)
  return self.height
end

function Screen.resetFrameCount(self)
  self.frames = 0
end

function Screen.viewport(self)
  gl.viewport(0, 0, self.width, self.height)
end

function Screen.clear(self)
  gl.bindFramebuffer(gl.FRAMEBUFFER, 0)
  gl.viewport(0, 0, self.width, self.height)
  gl.clearColor(unpack(self.clearColor))
  gl.clear(gl.COLOR_BUFFER_BIT + gl.DEPTH_BUFFER_BIT)
end

function Screen.clearDepthBuffer(self)
  gl.bindFramebuffer(gl.FRAMEBUFFER, 0)
  gl.viewport(0, 0, self.width, self.height)
  gl.clear(gl.DEPTH_BUFFER_BIT)
end

function Screen.update(self)
  self.frames = self.frames + 1
  egl.swapBuffers(self.display, self.surface)
end

function Screen.swapInterval(self, interval)
  if interval >=0 and interval <= 10 then
    -- If interval ~= 0 then framerate = 60 / interval.
    -- If interval == 0 then no vsync.
    egl.swapInterval(self.display, interval)
  end
end

function Screen.screenShot(self, filename)
  local w = self.width
  local h = self.height
  local buflen = w * h * 3
  local buf = ffi.new("uint8_t[?]", buflen)
  gl.readPixels(0, 0, w, h, gl.RGB, gl.UNSIGNED_BYTE, buf)
  if filename == nil then
    filename = "ss" .. os.date("%Y%m%d_%H%M%S") .. ".png"
  end
  png.flipImage(buf, w, h, 3)
  png.writePNG(filename, buf, w, h, 8, 3)
end

