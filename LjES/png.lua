-- ---------------------------------------------
-- png.lua          2013/03/25
--   Copyright (c) 2013 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

--[[
  png.readPNG(filename, fill)
  png.writePNG(filename, image, bytes, width, height, bpp, coltype)
  png.flipImage(image, width, height, ncol)
]]

local ffi = require "ffi"
libpng = ffi.load("libpng12.so.0")

ffi.cdef[[
typedef struct _IO_FILE FILE;
typedef char charf;
typedef struct z_stream_s z_stream;
typedef long int __jmp_buf[8];
typedef struct  {
    unsigned long int __val[(1024 / (8 * sizeof (unsigned long int)))];
} __sigset_t;

typedef __sigset_t sigset_t;

struct __jmp_buf_tag {
    __jmp_buf __jmpbuf;
    int __mask_was_saved;
    __sigset_t __saved_mask;
};

typedef struct __jmp_buf_tag jmp_buf[1];

typedef const char * png_const_charp;
typedef struct png_struct_def png_struct;
typedef png_struct * png_structp;
typedef png_struct * * png_structpp;

typedef unsigned long png_uint_32;
typedef long png_int_32;
typedef unsigned short png_uint_16;
typedef short png_int_16;
typedef unsigned char png_byte;
typedef size_t png_size_t;
typedef png_int_32 png_fixed_point;
typedef void * png_voidp;
typedef png_byte * png_bytep;
typedef png_uint_32 * png_uint_32p;
typedef png_int_32 * png_int_32p;
typedef png_uint_16 * png_uint_16p;
typedef png_int_16 * png_int_16p;
typedef const char * png_const_charp;
typedef char * png_charp;
typedef png_fixed_point * png_fixed_point_p;
typedef FILE * png_FILE_p;
typedef double * png_doublep;
typedef png_byte ** png_bytepp;
typedef png_uint_32 ** png_uint_32pp;
typedef png_int_32 ** png_int_32pp;
typedef png_uint_16 ** png_uint_16pp;
typedef png_int_16 ** png_int_16pp;
typedef const char ** png_const_charpp;
typedef char ** png_charpp;
typedef png_fixed_point * * png_fixed_point_pp;
typedef double ** png_doublepp;
typedef char * * * png_charppp;
typedef charf * png_zcharp;
typedef charf * * png_zcharpp;
typedef z_stream * png_zstreamp;
extern const char png_libpng_ver[18];
extern const int png_pass_start[7];
extern const int png_pass_inc[7];
extern const int png_pass_ystart[7];
extern const int png_pass_yinc[7];
extern const int png_pass_mask[7];
extern const int png_pass_dsp_mask[7];

typedef struct png_color_struct {
   png_byte red;
   png_byte green;
   png_byte blue;
} png_color;

typedef png_color * png_colorp;
typedef png_color * * png_colorpp;

typedef struct png_color_16_struct {
   png_byte index;
   png_uint_16 red;
   png_uint_16 green;
   png_uint_16 blue;
   png_uint_16 gray;
} png_color_16;
typedef png_color_16 * png_color_16p;
typedef png_color_16 * * png_color_16pp;

typedef struct png_color_8_struct {
   png_byte red;
   png_byte green;
   png_byte blue;
   png_byte gray;
   png_byte alpha;
} png_color_8;

typedef png_color_8 * png_color_8p;
typedef png_color_8 * * png_color_8pp;

typedef struct png_sPLT_entry_struct {
   png_uint_16 red;
   png_uint_16 green;
   png_uint_16 blue;
   png_uint_16 alpha;
   png_uint_16 frequency;
} png_sPLT_entry;

typedef png_sPLT_entry * png_sPLT_entryp;
typedef png_sPLT_entry * * png_sPLT_entrypp;

typedef struct png_sPLT_struct {
   png_charp name;
   png_byte depth;
   png_sPLT_entryp entries;
   png_int_32 nentries;
} png_sPLT_t;

typedef png_sPLT_t * png_sPLT_tp;
typedef png_sPLT_t * * png_sPLT_tpp;

typedef struct png_text_struct {
   int compression;
   png_charp key;
   png_charp text;
   png_size_t text_length;
} png_text;

typedef png_text * png_textp;
typedef png_text * * png_textpp;

typedef struct png_time_struct {
   png_uint_16 year;
   png_byte month;
   png_byte day;
   png_byte hour;
   png_byte minute;
   png_byte second;
} png_time;

typedef png_time * png_timep;
typedef png_time * * png_timepp;

typedef struct png_unknown_chunk_t {
    png_byte name[5];
    png_byte *data;
    png_size_t size;
    png_byte location;
} png_unknown_chunk;

typedef png_unknown_chunk * png_unknown_chunkp;
typedef png_unknown_chunk * * png_unknown_chunkpp;
typedef struct png_info_struct
{
   png_uint_32 width ;
   png_uint_32 height ;
   png_uint_32 valid ;
   png_uint_32 rowbytes ;
   png_colorp palette ;
   png_uint_16 num_palette ;
   png_uint_16 num_trans ;
   png_byte bit_depth ;
   png_byte color_type ;
   png_byte compression_type ;
   png_byte filter_type ;
   png_byte interlace_type ;
   png_byte channels ;
   png_byte pixel_depth ;
   png_byte spare_byte ;
   png_byte signature[8] ;
   float gamma ;
   png_byte srgb_intent ;
   int num_text ;
   int max_text ;
   png_textp text ;
   png_time mod_time ;
   png_color_8 sig_bit ;
   png_bytep trans ;
   png_color_16 trans_values ;
   png_color_16 background ;
   png_int_32 x_offset ;
   png_int_32 y_offset ;
   png_byte offset_unit_type ;
   png_uint_32 x_pixels_per_unit ;
   png_uint_32 y_pixels_per_unit ;
   png_byte phys_unit_type ;
   png_uint_16p hist ;
   float x_white ;
   float y_white ;
   float x_red ;
   float y_red ;
   float x_green ;
   float y_green ;
   float x_blue ;
   float y_blue ;
   png_charp pcal_purpose ;
   png_int_32 pcal_X0 ;
   png_int_32 pcal_X1 ;
   png_charp pcal_units ;
   png_charpp pcal_params ;
   png_byte pcal_type ;
   png_byte pcal_nparams ;
   png_uint_32 free_me ;
   png_unknown_chunkp unknown_chunks ;
   png_size_t unknown_chunks_num ;
   png_charp iccp_name ;
   png_charp iccp_profile ;
   png_uint_32 iccp_proflen ;
   png_byte iccp_compression ;
   png_sPLT_tp splt_palettes ;
   png_uint_32 splt_palettes_num ;
   png_byte scal_unit ;
   double scal_pixel_width ;
   double scal_pixel_height ;
   png_charp scal_s_width ;
   png_charp scal_s_height ;
   png_bytepp row_pointers ;
   png_fixed_point int_gamma ;
   png_fixed_point int_x_white ;
   png_fixed_point int_y_white ;
   png_fixed_point int_x_red ;
   png_fixed_point int_y_red ;
   png_fixed_point int_x_green ;
   png_fixed_point int_y_green ;
   png_fixed_point int_x_blue ;
   png_fixed_point int_y_blue ;
} png_info;

typedef png_info * png_infop;
typedef png_info * * png_infopp;

typedef struct png_row_info_struct {
   png_uint_32 width;
   png_uint_32 rowbytes;
   png_byte color_type;
   png_byte bit_depth;
   png_byte channels;
   png_byte pixel_depth;
} png_row_info;

typedef png_row_info * png_row_infop;
typedef png_row_info * * png_row_infopp;

typedef void ( *png_error_ptr) (png_structp, png_const_charp);

extern png_structp png_create_read_struct(png_const_charp user_png_ver,
  png_voidp error_ptr, png_error_ptr error_fn, png_error_ptr warn_fn);
extern png_infop png_create_info_struct(png_structp png_ptr);
extern void png_init_io(png_structp png_ptr, png_FILE_p fp);
extern void png_read_info(png_structp png_ptr, png_infop info_ptr);
extern png_uint_32 png_get_IHDR(png_structp png_ptr, png_infop info_ptr,
  png_uint_32 *width, png_uint_32 *height, int *bit_depth, int *color_type,
  int *interlace_method, int *compression_method, int *filter_method);
extern void png_set_filler(png_structp png_ptr, png_uint_32 filler,
  int flags);
extern png_voidp png_malloc(png_structp png_ptr, png_uint_32 size);
extern void png_set_rows(png_structp png_ptr, png_infop info_ptr,
  png_bytepp row_pointers);
extern void png_read_image(png_structp png_ptr, png_bytepp image);
extern void png_destroy_read_struct (png_structpp png_ptr_ptr,
  png_infopp info_ptr_ptr, png_infopp end_info_ptr_ptr);
extern png_structp png_create_write_struct(png_const_charp user_png_ver,
  png_voidp error_ptr, png_error_ptr error_fn, png_error_ptr warn_fn);
extern void png_write_info(png_structp png_ptr, png_infop info_ptr);
extern void png_destroy_write_struct(png_structpp png_ptr_ptr,
  png_infopp info_ptr_ptr);
extern void png_write_png (png_structp png_ptr, png_infop info_ptr,
  int transforms, png_voidp params);

]]

local png = {
  PNG_LIBPNG_VER_STRING = "1.2.49",
  PNG_COLOR_MASK_COLOR = 2,
  PNG_COLOR_MASK_ALPHA = 4,
  PNG_COLOR_TYPE_RGB_ALPHA = 6,
  PNG_COLOR_TYPE_RGB  = 2,
  PNG_COLOR_TYPE_RGBA = 6,
  PNG_FILLER_AFTER = 1,
  PNG_INTERLACE_NONE = 0,
  PNG_FILTER_TYPE_BASE         = 0,
  PNG_FILTER_TYPE_DEFAULT      = 0,
  PNG_COMPRESSION_TYPE_BASE    = 0,
  PNG_COMPRESSION_TYPE_DEFAULT = 0,

  PNG_TRANSFORM_IDENTITY       = 0x0000,
  PNG_TRANSFORM_STRIP_16       = 0x0001,
  PNG_TRANSFORM_STRIP_ALPHA    = 0x0002,
  PNG_TRANSFORM_PACKING        = 0x0004,
  PNG_TRANSFORM_PACKSWAP       = 0x0008,
  PNG_TRANSFORM_EXPAND         = 0x0010,
  PNG_TRANSFORM_INVERT_MONO    = 0x0020,
  PNG_TRANSFORM_SHIFT          = 0x0040,
  PNG_TRANSFORM_BGR            = 0x0080,
  PNG_TRANSFORM_SWAP_ALPHA     = 0x0100,
  PNG_TRANSFORM_SWAP_ENDIAN    = 0x0200,
  PNG_TRANSFORM_INVERT_ALPHA   = 0x0400,
  PNG_TRANSFORM_STRIP_FILLER   = 0x0800,
  PNG_TRANSFORM_STRIP_FILLER_BEFORE = 0x0800,
  PNG_TRANSFORM_STRIP_FILLER_AFTER  = 0x1000,
  PNG_TRANSFORM_GRAY_TO_RGB    = 0x2000,

  png_create_read_struct   = libpng.png_create_read_struct,
  png_create_info_struct   = libpng.png_create_info_struct,
  png_init_io              = libpng.png_init_io,
  png_read_info            = libpng.png_read_info,
  png_get_IHDR             = libpng.png_get_IHDR,
  png_set_filler           = libpng.png_set_filler,
  png_malloc               = libpng.png_malloc,
  png_set_rows             = libpng.png_set_rows,
  png_read_image           = libpng.png_read_image,
  png_destroy_read_struct  = libpng.png_destroy_read_struct,
  png_create_write_struct  = libpng.png_create_write_struct,
  png_write_info           = libpng.png_write_info,
  png_destroy_write_struct = libpng.png_destroy_write_struct,
  png_write_png            = libpng.png_write_png
}

-- ---------------------------------------------------------------------
-- Read image from PNG file.
-- image, bytes, width, height, bpp, ncol = readPNG(filename, fill)
-- ---------------------------------------------------------------------
function png.readPNG(filename, fill)
  local ncol = 4
  local width = ffi.new("uint32_t[1]")
  local height = ffi.new("uint32_t[1]")
  --local width = ffi.new("uint64_t[1]")
  --local height = ffi.new("uint64_t[1]")

  local bpp = ffi.new("uint32_t[1]")
  local color_type = ffi.new("uint32_t[1]")
  local interlace_type = ffi.new("uint32_t[1]")

  local fh, err = io.open(filename, "rb")
  if fh == nil then
    print(err)
    return nil
  end
  local png_ptr = libpng.png_create_read_struct(
                     png.PNG_LIBPNG_VER_STRING, nil, nil, nil)
  local info_ptr = libpng.png_create_info_struct(png_ptr)
  libpng.png_init_io(png_ptr, fh)
  libpng.png_read_info(png_ptr, info_ptr)
  libpng.png_get_IHDR(png_ptr, info_ptr, width, height, bpp,
                 color_type, interlace_type, nil, nil)
  if (color_type[0] == png.PNG_COLOR_TYPE_RGB) then
    if fill ~= 0 then
      libpng.png_set_filler(png_ptr, 255, png.PNG_FILLER_AFTER)
    else
      ncol = 3
    end
  end
  local row_pointers = ffi.new('png_bytep[?]', height[0])
  local buflen = width[0] * height[0] * (bpp[0]/8 * ncol)
  local image = ffi.new("unsigned char[?]", buflen)
  for i = 0, tonumber(height[0] - 1) do
    row_pointers[i] = ffi.cast('png_bytep', image
                + (i * width[0] * (bpp[0] / 8 * ncol)))
  end
  libpng.png_set_rows(png_ptr, info_ptr, row_pointers)
  libpng.png_read_image(png_ptr, row_pointers)

  local end_info
  if png_ptr ~= nil then
    libpng.png_destroy_read_struct(ffi.new('png_structp[1]', png_ptr),
      ffi.new('png_infop[1]', info_ptr), ffi.new('png_infop[1]', end_info))
  end
  fh:close()
  return image, buflen, width[0], height[0], bpp[0], ncol
end

-- ---------------------------------------------------------------------
-- Write image into PNG file.
-- writePNG(filename, image, width, height, bpp, ncol)
-- if ncol == 3 then RGB else RGBA
-- ---------------------------------------------------------------------
function png.writePNG(filename, image, width, height, bpp, ncol)
  local fh = io.open(filename, "wb")

  local png_ptr = libpng.png_create_write_struct(
                          png.PNG_LIBPNG_VER_STRING, nil, nil, nil)
  local info_ptr = libpng.png_create_info_struct(png_ptr)
  if ncol ~= 3 then ncol = 4 end

  libpng.png_init_io(png_ptr, fh)
  info_ptr.width = width
  info_ptr.height = height
  info_ptr.bit_depth = bpp
  if ncol == 3 then
    info_ptr.color_type = png.PNG_COLOR_TYPE_RGB
  else
    info_ptr.color_type = png.PNG_COLOR_TYPE_RGBA
  end
  info_ptr.interlace_type = png.PNG_INTERLACE_NONE
  info_ptr.compression_type = png.PNG_COMPRESSION_TYPE_DEFAULT
  info_ptr.filter_type = png.PNG_FILTER_TYPE_DEFAULT
  local row_pointers = ffi.new('png_bytep[?]', height)
  for i=0, height-1 do
    row_pointers[i] = ffi.cast('png_bytep', image + (i*width*(bpp/8*ncol)))
  end
  libpng.png_set_rows(png_ptr, info_ptr, row_pointers);
  libpng.png_write_png(png_ptr, info_ptr, png.PNG_TRANSFORM_IDENTITY, nil)
  libpng.png_destroy_write_struct(ffi.new('png_structp[1]', png_ptr),
                                    ffi.new('png_infop[1]', info_ptr))
end

function png.flipImage(image, width, height, ncol)
  local n = math.floor((height - 1) / 2)
  for y = 0, n do
    local bottom = height - 1 - y
    for x = 0, width - 1 do
      local m = (y * width + x) * ncol
      local k = (bottom * width + x) * ncol
      image[m  ], image[k  ] = image[k  ], image[m  ]
      image[m+1], image[k+1] = image[k+1], image[m+1]
      image[m+2], image[k+2] = image[k+2], image[m+2]
      if ncol == 4 then
        image[m+3], image[k+3] = image[k+3], image[m+3]
      end
    end
  end
end

return png
