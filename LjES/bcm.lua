-- ---------------------------------------------
-- bcm.lua          2014/06/05
--   Copyright (c) 2013-2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

local ffi = require("ffi")
local bcm_host = ffi.load("bcm_host")

ffi.cdef[[

typedef uint32_t DISPMANX_DISPLAY_HANDLE_T;
typedef uint32_t DISPMANX_UPDATE_HANDLE_T;
typedef uint32_t DISPMANX_ELEMENT_HANDLE_T;
typedef uint32_t DISPMANX_RESOURCE_HANDLE_T;
typedef uint32_t DISPMANX_PROTECTION_T;

typedef enum {
    DISPMANX_NO_ROTATE = 0,
    DISPMANX_ROTATE_90 = 1,
    DISPMANX_ROTATE_180 = 2,
    DISPMANX_ROTATE_270 = 3,

    DISPMANX_FLIP_HRIZ = 1 << 16,
    DISPMANX_FLIP_VERT = 1 << 17
} DISPMANX_TRANSFORM_T;

typedef enum {
   VC_IMAGE_ROT0           = 0,
} VC_IMAGE_TRANSFORM_T;

typedef struct {
   int32_t x;
   int32_t y;
   int32_t width;
   int32_t height;
} VC_RECT_T;

struct VC_IMAGE_T;
typedef struct VC_IMAGE_T VC_IMAGE_T;

typedef int EGLint;
typedef unsigned int EGLBoolean;
typedef unsigned int EGLenum;
typedef void *EGLConfig;
typedef void *EGLContext;
typedef void *EGLDisplay;
typedef void *EGLSurface;
typedef void *EGLClientBuffer;
typedef void *EGLNativeDisplayType;
typedef void *EGLNativePixmapType;
typedef void *EGLNativeWindowType;

typedef enum {
  DISPMANX_FLAGS_ALPHA_FROM_SOURCE = 0,
  DISPMANX_FLAGS_ALPHA_FIXED_ALL_PIXELS = 1,
  DISPMANX_FLAGS_ALPHA_FIXED_NON_ZERO = 2,
  DISPMANX_FLAGS_ALPHA_FIXED_EXCEED_0X07 = 3,
  DISPMANX_FLAGS_ALPHA_PREMULT = 1 << 16,
  DISPMANX_FLAGS_ALPHA_MIX = 1 << 17
} DISPMANX_FLAGS_ALPHA_T;

typedef struct {
  DISPMANX_FLAGS_ALPHA_T flags;
  uint32_t opacity;
  VC_IMAGE_T *mask;
} DISPMANX_ALPHA_T;

typedef struct {
  DISPMANX_FLAGS_ALPHA_T flags;
  uint32_t opacity;
  DISPMANX_RESOURCE_HANDLE_T mask;
} VC_DISPMANX_ALPHA_T;

typedef enum {
  DISPMANX_FLAGS_CLAMP_NONE = 0,
  DISPMANX_FLAGS_CLAMP_LUMA_TRANSPARENT = 1,
//#if __VCCOREVER__ >= 0x04000000
  DISPMANX_FLAGS_CLAMP_TRANSPARENT = 2,
  DISPMANX_FLAGS_CLAMP_REPLACE = 3
//#else
//  DISPMANX_FLAGS_CLAMP_CHROMA_TRANSPARENT = 2,
//  DISPMANX_FLAGS_CLAMP_TRANSPARENT = 3
//#endif
} DISPMANX_FLAGS_CLAMP_T;

typedef enum {
  DISPMANX_FLAGS_KEYMASK_OVERRIDE = 1,
  DISPMANX_FLAGS_KEYMASK_SMOOTH = 1 << 1,
  DISPMANX_FLAGS_KEYMASK_CR_INV = 1 << 2,
  DISPMANX_FLAGS_KEYMASK_CB_INV = 1 << 3,
  DISPMANX_FLAGS_KEYMASK_YY_INV = 1 << 4
} DISPMANX_FLAGS_KEYMASK_T;

typedef union {
  struct {
    uint8_t yy_upper;
    uint8_t yy_lower;
    uint8_t cr_upper;
    uint8_t cr_lower;
    uint8_t cb_upper;
    uint8_t cb_lower;
  } yuv;
  struct {
    uint8_t red_upper;
    uint8_t red_lower;
    uint8_t blue_upper;
    uint8_t blue_lower;
    uint8_t green_upper;
    uint8_t green_lower;
  } rgb;
} DISPMANX_CLAMP_KEYS_T;

typedef struct {
  DISPMANX_FLAGS_CLAMP_T mode;
  DISPMANX_FLAGS_KEYMASK_T key_mask;
  DISPMANX_CLAMP_KEYS_T key_value;
  uint32_t replace_value;
} DISPMANX_CLAMP_T;

typedef struct {
   DISPMANX_ELEMENT_HANDLE_T element;
   int width;
   int height;
} EGL_DISPMANX_WINDOW_T;

void bcm_host_init(void);
void bcm_host_deinit(void);

int32_t graphics_get_display_size(const uint16_t display_number,
    uint32_t *width, uint32_t *height);

int vc_dispmanx_rect_set(VC_RECT_T *rect, uint32_t x_offset,
    uint32_t y_offset, uint32_t width, uint32_t height);

DISPMANX_DISPLAY_HANDLE_T vc_dispmanx_display_open(uint32_t device);
int vc_dispmanx_display_close(DISPMANX_DISPLAY_HANDLE_T display);

DISPMANX_UPDATE_HANDLE_T vc_dispmanx_update_start(int32_t priority);

DISPMANX_ELEMENT_HANDLE_T vc_dispmanx_element_add(
    DISPMANX_UPDATE_HANDLE_T update,
    DISPMANX_DISPLAY_HANDLE_T display,
    int32_t layer, const VC_RECT_T *dest_rect,
    DISPMANX_RESOURCE_HANDLE_T src,
    const VC_RECT_T *src_rect, DISPMANX_PROTECTION_T protection,
    VC_DISPMANX_ALPHA_T *alpha,
    DISPMANX_CLAMP_T *clamp, DISPMANX_TRANSFORM_T transform);

int vc_dispmanx_element_change_attributes(
    DISPMANX_UPDATE_HANDLE_T update,
    DISPMANX_ELEMENT_HANDLE_T element,
    uint32_t change_flags,
    int32_t layer,
    uint8_t opacity,
    const VC_RECT_T *dest_rect,
    const VC_RECT_T *src_rect,
    DISPMANX_RESOURCE_HANDLE_T mask,
    VC_IMAGE_TRANSFORM_T transform);

int vc_dispmanx_element_remove(DISPMANX_UPDATE_HANDLE_T update, 
    DISPMANX_ELEMENT_HANDLE_T element );

int vc_dispmanx_update_submit_sync(DISPMANX_UPDATE_HANDLE_T update);

]]

local bcm = {
  ELEMENT_CHANGE_LAYER     = 1,
  ELEMENT_CHANGE_OPACITY   = 2,
  ELEMENT_CHANGE_DEST_RECT = 4,
  ELEMENT_CHANGE_SRC_RECT  = 8,
  ELEMENT_CHANGE_MASK_RESOURCE = 16,
  ELEMENT_CHANGE_TRANSFORM = 32,

  VC_RECT_T = ffi.typeof("VC_RECT_T"),
  VC_DISPMANX_ALPHA_T = ffi.typeof("VC_DISPMANX_ALPHA_T"),
  EGL_DISPMANX_WINDOW_T = ffi.typeof("EGL_DISPMANX_WINDOW_T"),
  bcm_host_init = bcm_host.bcm_host_init,
  bcm_host_deinit = bcm_host.bcm_host_deinit,
  graphics_get_display_size = bcm_host.graphics_get_display_size,
  vc_dispmanx_display_open = bcm_host.vc_dispmanx_display_open,
  vc_dispmanx_display_close = bcm_host.vc_dispmanx_display_close,
  vc_dispmanx_update_start = bcm_host.vc_dispmanx_update_start,
  vc_dispmanx_element_add = bcm_host.vc_dispmanx_element_add,
  vc_dispmanx_element_remove = bcm_host.vc_dispmanx_element_remove,
  vc_dispmanx_element_change_attributes =
      bcm_host.vc_dispmanx_element_change_attributes,
  vc_dispmanx_update_submit_sync = bcm_host.vc_dispmanx_update_submit_sync
}

return bcm
