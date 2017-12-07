-- ---------------------------------------------
-- gles2.lua        2017/12/07
--   Copyright (c) 2013-2017 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

local ffi = require("ffi")
local util = require("util")
libgles2  = ffi.load("brcmGLESv2")

ffi.cdef[[

typedef void             GLvoid;
typedef char             GLchar;
typedef unsigned int     GLenum;
typedef unsigned char    GLboolean;
typedef unsigned int     GLbitfield;
typedef int8_t           GLbyte;
typedef short            GLshort;
typedef int              GLint;
typedef int              GLsizei;
typedef uint8_t          GLubyte;
typedef unsigned short   GLushort;
typedef unsigned int     GLuint;
typedef float            GLfloat;
typedef float            GLclampf;
typedef int32_t          GLfixed;
typedef signed long int  GLintptr;
typedef signed long int  GLsizeiptr;

void    glActiveTexture (GLenum texture);
void    glAttachShader (GLuint program, GLuint shader);
void    glBindAttribLocation (GLuint program, GLuint index,
                  const GLchar* name);
void    glBindBuffer (GLenum target, GLuint buffer);
void    glBindFramebuffer (GLenum target, GLuint framebuffer);
void    glBindRenderbuffer (GLenum target, GLuint renderbuffer);
void    glBindTexture (GLenum target, GLuint texture);
void    glBlendColor (GLclampf red, GLclampf green, GLclampf blue,
                  GLclampf alpha);
void    glBlendEquation ( GLenum mode );
void    glBlendEquationSeparate (GLenum modeRGB, GLenum modeAlpha);
void    glBlendFunc (GLenum sfactor, GLenum dfactor);
void    glBlendFuncSeparate (GLenum srcRGB, GLenum dstRGB,
                  GLenum srcAlpha, GLenum dstAlpha);
void    glBufferData (GLenum target, GLsizeiptr size,
                  const GLvoid* data, GLenum usage);
void    glBufferSubData (GLenum target, GLintptr offset,
                  GLsizeiptr size, const GLvoid* data);
GLenum  glCheckFramebufferStatus (GLenum target);
void    glClear (GLbitfield mask);
void    glClearColor (GLclampf red, GLclampf green, GLclampf blue,
                  GLclampf alpha);
void    glClearDepthf (GLclampf depth);
void    glClearStencil (GLint s);
void    glColorMask (GLboolean red, GLboolean green, GLboolean blue,
                  GLboolean alpha);
void    glCompileShader (GLuint shader);
void    glCompressedTexImage2D (GLenum target, GLint level,
                  GLenum internalformat, GLsizei width, GLsizei height,
                  GLint border, GLsizei imageSize, const GLvoid* data);
void    glCompressedTexSubImage2D (GLenum target, GLint level,
                  GLint xoffset, GLint yoffset, GLsizei width,
                  GLsizei height, GLenum format, GLsizei imageSize,
                  const GLvoid* data);
void    glCopyTexImage2D (GLenum target, GLint level,
                  GLenum internalformat, GLint x, GLint y, GLsizei width,
                  GLsizei height, GLint border);
void    glCopyTexSubImage2D (GLenum target, GLint level, GLint xoffset,
                  GLint yoffset, GLint x, GLint y, GLsizei width,
                  GLsizei height);
GLuint  glCreateProgram (void);
GLuint  glCreateShader (GLenum type);
void    glCullFace (GLenum mode);
void    glDeleteBuffers (GLsizei n, const GLuint* buffers);
void    glDeleteFramebuffers (GLsizei n, const GLuint* framebuffers);
void    glDeleteProgram (GLuint program);
void    glDeleteRenderbuffers (GLsizei n, const GLuint* renderbuffers);
void    glDeleteShader (GLuint shader);
void    glDeleteTextures (GLsizei n, const GLuint* textures);
void    glDepthFunc (GLenum func);
void    glDepthMask (GLboolean flag);
void    glDepthRangef (GLclampf zNear, GLclampf zFar);
void    glDetachShader (GLuint program, GLuint shader);
void    glDisable (GLenum cap);
void    glDisableVertexAttribArray (GLuint index);
void    glDrawArrays (GLenum mode, GLint first, GLsizei count);
void    glDrawElements (GLenum mode, GLsizei count, GLenum type,
                  const GLvoid* indices);
void    glEnable (GLenum cap);
void    glEnableVertexAttribArray (GLuint index);
void    glFinish (void);
void    glFlush (void);
void    glFramebufferRenderbuffer (GLenum target, GLenum attachment,
                  GLenum renderbuffertarget, GLuint renderbuffer);
void    glFramebufferTexture2D (GLenum target, GLenum attachment,
                  GLenum textarget, GLuint texture, GLint level);
void    glFrontFace (GLenum mode);
void    glGenBuffers (GLsizei n, GLuint* buffers);
void    glGenerateMipmap (GLenum target);
void    glGenFramebuffers (GLsizei n, GLuint* framebuffers);
void    glGenRenderbuffers (GLsizei n, GLuint* renderbuffers);
void    glGenTextures (GLsizei n, GLuint* textures);
void    glGetActiveAttrib (GLuint program, GLuint index,
                  GLsizei bufsize, GLsizei* length, GLint* size,
                  GLenum* type, GLchar* name);
void    glGetActiveUniform (GLuint program, GLuint index,
                  GLsizei bufsize, GLsizei* length, GLint* size,
                  GLenum* type, GLchar* name);
void    glGetAttachedShaders (GLuint program, GLsizei maxcount,
                  GLsizei* count, GLuint* shaders);
int     glGetAttribLocation (GLuint program, const GLchar* name);
void    glGetBooleanv (GLenum pname, GLboolean* params);
void    glGetBufferParameteriv (GLenum target, GLenum pname,
                  GLint* params);
GLenum  glGetError (void);
void    glGetFloatv (GLenum pname, GLfloat* params);
void    glGetFramebufferAttachmentParameteriv (GLenum target,
                  GLenum attachment, GLenum pname, GLint* params);
void    glGetIntegerv (GLenum pname, GLint* params);
void    glGetProgramiv (GLuint program, GLenum pname, GLint* params);
void    glGetProgramInfoLog (GLuint program, GLsizei bufsize,
                  GLsizei* length, GLchar* infolog);
void    glGetRenderbufferParameteriv (GLenum target, GLenum pname,
                  GLint* params);
void    glGetShaderiv (GLuint shader, GLenum pname, GLint* params);
void    glGetShaderInfoLog (GLuint shader, GLsizei bufsize,
                  GLsizei* length, GLchar* infolog);
void    glGetShaderPrecisionFormat (GLenum shadertype,
                  GLenum precisiontype, GLint* range, GLint* precision);
void    glGetShaderSource (GLuint shader, GLsizei bufsize,
                  GLsizei* length, GLchar* source);
const GLubyte*  glGetString (GLenum name);
void    glGetTexParameterfv (GLenum target, GLenum pname,
                  GLfloat* params);
void    glGetTexParameteriv (GLenum target, GLenum pname,
                  GLint* params);
void    glGetUniformfv (GLuint program, GLint location,
                  GLfloat* params);
void    glGetUniformiv (GLuint program, GLint location,
                  GLint* params);
int           glGetUniformLocation (GLuint program, const GLchar* name);
void    glGetVertexAttribfv (GLuint index, GLenum pname,
                  GLfloat* params);
void    glGetVertexAttribiv (GLuint index, GLenum pname, GLint* params);
void    glGetVertexAttribPointerv (GLuint index, GLenum pname,
                  GLvoid** pointer);
void    glHint (GLenum target, GLenum mode);
GLboolean     glIsBuffer (GLuint buffer);
GLboolean     glIsEnabled (GLenum cap);
GLboolean     glIsFramebuffer (GLuint framebuffer);
GLboolean     glIsProgram (GLuint program);
GLboolean     glIsRenderbuffer (GLuint renderbuffer);
GLboolean     glIsShader (GLuint shader);
GLboolean     glIsTexture (GLuint texture);
void    glLineWidth (GLfloat width);
void    glLinkProgram (GLuint program);
void    glPixelStorei (GLenum pname, GLint param);
void    glPolygonOffset (GLfloat factor, GLfloat units);
void    glReadPixels (GLint x, GLint y, GLsizei width, GLsizei height,
                  GLenum format, GLenum type, GLvoid* pixels);
void    glReleaseShaderCompiler (void);
void    glRenderbufferStorage (GLenum target, GLenum internalformat,
                  GLsizei width, GLsizei height);
void    glSampleCoverage (GLclampf value, GLboolean invert);
void    glScissor (GLint x, GLint y, GLsizei width, GLsizei height);
void    glShaderBinary (GLsizei n, const GLuint* shaders,
                  GLenum binaryformat, const GLvoid* binary, GLsizei length);
void    glShaderSource (GLuint shader, GLsizei count,
                  const GLchar** string, const GLint* length);
void    glStencilFunc (GLenum func, GLint ref, GLuint mask);
void    glStencilFuncSeparate (GLenum face, GLenum func, GLint ref,
                  GLuint mask);
void    glStencilMask (GLuint mask);
void    glStencilMaskSeparate (GLenum face, GLuint mask);
void    glStencilOp (GLenum fail, GLenum zfail, GLenum zpass);
void    glStencilOpSeparate (GLenum face, GLenum fail, GLenum zfail,
                  GLenum zpass);
void    glTexImage2D (GLenum target, GLint level, GLint internalformat,
                  GLsizei width, GLsizei height, GLint border, GLenum format,
                  GLenum type, const GLvoid* pixels);
void    glTexParameterf (GLenum target, GLenum pname, GLfloat param);
void    glTexParameterfv (GLenum target, GLenum pname,
                  const GLfloat* params);
void    glTexParameteri (GLenum target, GLenum pname, GLint param);
void    glTexParameteriv (GLenum target, GLenum pname,
                  const GLint* params);
void    glTexSubImage2D (GLenum target, GLint level, GLint xoffset,
                  GLint yoffset, GLsizei width, GLsizei height, GLenum format,
                  GLenum type, const GLvoid* pixels);
void    glUniform1f (GLint location, GLfloat x);
void    glUniform1fv (GLint location, GLsizei count, const GLfloat* v);
void    glUniform1i (GLint location, GLint x);
void    glUniform1iv (GLint location, GLsizei count, const GLint* v);
void    glUniform2f (GLint location, GLfloat x, GLfloat y);
void    glUniform2fv (GLint location, GLsizei count, const GLfloat* v);
void    glUniform2i (GLint location, GLint x, GLint y);
void    glUniform2iv (GLint location, GLsizei count, const GLint* v);
void    glUniform3f (GLint location, GLfloat x, GLfloat y, GLfloat z);
void    glUniform3fv (GLint location, GLsizei count, const GLfloat* v);
void    glUniform3i (GLint location, GLint x, GLint y, GLint z);
void    glUniform3iv (GLint location, GLsizei count, const GLint* v);
void    glUniform4f (GLint location, GLfloat x, GLfloat y, GLfloat z,
                  GLfloat w);
void    glUniform4fv (GLint location, GLsizei count, const GLfloat* v);
void    glUniform4i (GLint location, GLint x, GLint y, GLint z,
                  GLint w);
void    glUniform4iv (GLint location, GLsizei count, const GLint* v);
void    glUniformMatrix2fv (GLint location, GLsizei count,
                  GLboolean transpose, const GLfloat* value);
void    glUniformMatrix3fv (GLint location, GLsizei count,
                  GLboolean transpose, const GLfloat* value);
void    glUniformMatrix4fv (GLint location, GLsizei count,
                  GLboolean transpose, const GLfloat* value);
void    glUseProgram (GLuint program);
void    glValidateProgram (GLuint program);
void    glVertexAttrib1f (GLuint indx, GLfloat x);
void    glVertexAttrib1fv (GLuint indx, const GLfloat* values);
void    glVertexAttrib2f (GLuint indx, GLfloat x, GLfloat y);
void    glVertexAttrib2fv (GLuint indx, const GLfloat* values);
void    glVertexAttrib3f (GLuint indx, GLfloat x, GLfloat y, GLfloat z);
void    glVertexAttrib3fv (GLuint indx, const GLfloat* values);
void    glVertexAttrib4f (GLuint indx, GLfloat x, GLfloat y, GLfloat z,
                  GLfloat w);
void    glVertexAttrib4fv (GLuint indx, const GLfloat* values);
void    glVertexAttribPointer (GLuint indx, GLint size, GLenum type,
                  GLboolean normalized, GLsizei stride, const GLvoid* ptr);
void    glViewport (GLint x, GLint y, GLsizei width, GLsizei height);
]]

local gl = {
  ACTIVE_ATTRIBUTES = 0x8B89,
  ACTIVE_ATTRIBUTE_MAX_LENGTH = 0x8B8A,
  ACTIVE_TEXTURE = 0x84E0,
  ACTIVE_UNIFORMS = 0x8B86,
  ACTIVE_UNIFORM_MAX_LENGTH = 0x8B87,
  ALIASED_LINE_WIDTH_RANGE = 0x846E,
  ALIASED_POINT_SIZE_RANGE = 0x846D,
  ALPHA = 0x1906,
  ALPHA_BITS = 0x0D55,
  ALWAYS = 0x0207,
  ARRAY_BUFFER = 0x8892,
  ARRAY_BUFFER_BINDING = 0x8894,
  ATTACHED_SHADERS = 0x8B85,
  BACK = 0x0405,
  BLEND = 0x0BE2,
  BLEND_COLOR = 0x8005,
  BLEND_DST_ALPHA = 0x80CA,
  BLEND_DST_RGB = 0x80C8,
  BLEND_EQUATION = 0x8009,
  BLEND_EQUATION_ALPHA = 0x883D,
  BLEND_EQUATION_RGB = 0x8009,
  BLEND_SRC_ALPHA = 0x80CB,
  BLEND_SRC_RGB = 0x80C9,
  BLUE_BITS = 0x0D54,
  BOOL = 0x8B56,
  BOOL_VEC2 = 0x8B57,
  BOOL_VEC3 = 0x8B58,
  BOOL_VEC4 = 0x8B59,
  BUFFER_SIZE = 0x8764,
  BUFFER_USAGE = 0x8765,
  BYTE = 0x1400,
  CCW = 0x0901,
  CLAMP_TO_EDGE = 0x812F,
  COLOR_ATTACHMENT0 = 0x8CE0,
  COLOR_BUFFER_BIT = 0x00004000,
  COLOR_CLEAR_VALUE = 0x0C22,
  COLOR_WRITEMASK = 0x0C23,
  COMPILE_STATUS = 0x8B81,
  COMPRESSED_TEXTURE_FORMATS = 0x86A3,
  CONSTANT_ALPHA = 0x8003,
  CONSTANT_COLOR = 0x8001,
  CULL_FACE = 0x0B44,
  CULL_FACE_MODE = 0x0B45,
  CURRENT_PROGRAM = 0x8B8D,
  CURRENT_VERTEX_ATTRIB = 0x8626,
  CW = 0x0900,
  DECR = 0x1E03,
  DECR_WRAP = 0x8508,
  DELETE_STATUS = 0x8B80,
  DEPTH_ATTACHMENT = 0x8D00,
  DEPTH_BITS = 0x0D56,
  DEPTH_BUFFER_BIT = 0x00000100,
  DEPTH_CLEAR_VALUE = 0x0B73,
  DEPTH_COMPONENT = 0x1902,
  DEPTH_COMPONENT16 = 0x81A5,
  DEPTH_COMPONENT24_OES = 0x81A6,
  DEPTH_COMPONENT32_OES = 0x81A7,
  DEPTH_FUNC = 0x0B74,
  DEPTH_RANGE = 0x0B70,
  DEPTH_TEST = 0x0B71,
  DEPTH_WRITEMASK = 0x0B72,
  DITHER = 0x0BD0,
  DONT_CARE = 0x1100,
  DST_ALPHA = 0x0304,
  DST_COLOR = 0x0306,
  DYNAMIC_DRAW = 0x88E8,
  ELEMENT_ARRAY_BUFFER = 0x8893,
  ELEMENT_ARRAY_BUFFER_BINDING = 0x8895,
  EQUAL = 0x0202,
  EXTENSIONS = 0x1F03,
  FALSE = 0,
  FASTEST = 0x1101,
  FIXED = 0x140C,
  FLOAT = 0x1406,
  FLOAT_MAT2 = 0x8B5A,
  FLOAT_MAT3 = 0x8B5B,
  FLOAT_MAT4 = 0x8B5C,
  FLOAT_VEC2 = 0x8B50,
  FLOAT_VEC3 = 0x8B51,
  FLOAT_VEC4 = 0x8B52,
  FRAGMENT_SHADER = 0x8B30,
  FRAMEBUFFER = 0x8D40,
  FRAMEBUFFER_ATTACHMENT_OBJECT_NAME = 0x8CD1,
  FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE = 0x8CD0,
  FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE = 0x8CD3,
  FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL = 0x8CD2,
  FRAMEBUFFER_BINDING = 0x8CA6,
  FRAMEBUFFER_COMPLETE = 0x8CD5,
  FRAMEBUFFER_INCOMPLETE_ATTACHMENT = 0x8CD6,
  FRAMEBUFFER_INCOMPLETE_DIMENSIONS = 0x8CD9,
  FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT = 0x8CD7,
  FRAMEBUFFER_UNSUPPORTED = 0x8CDD,
  FRONT = 0x0404,
  FRONT_AND_BACK = 0x0408,
  FRONT_FACE = 0x0B46,
  FUNC_ADD = 0x8006,
  FUNC_REVERSE_SUBTRACT = 0x800B,
  FUNC_SUBTRACT = 0x800A,
  GENERATE_MIPMAP_HINT = 0x8192,
  GEQUAL = 0x0206,
  GREATER = 0x0204,
  GREEN_BITS = 0x0D53,
  HIGH_FLOAT = 0x8DF2,
  HIGH_INT = 0x8DF5,
  IMPLEMENTATION_COLOR_READ_FORMAT = 0x8B9B,
  IMPLEMENTATION_COLOR_READ_TYPE = 0x8B9A,
  INCR = 0x1E02,
  INCR_WRAP = 0x8507,
  INFO_LOG_LENGTH = 0x8B84,
  INT = 0x1404,
  INT_VEC2 = 0x8B53,
  INT_VEC3 = 0x8B54,
  INT_VEC4 = 0x8B55,
  INVALID_ENUM = 0x0500,
  INVALID_FRAMEBUFFER_OPERATION = 0x0506,
  INVALID_OPERATION = 0x0502,
  INVALID_VALUE = 0x0501,
  INVERT = 0x150A,
  KEEP = 0x1E00,
  LEQUAL = 0x0203,
  LESS = 0x0201,
  LINEAR = 0x2601,
  LINEAR_MIPMAP_LINEAR = 0x2703,
  LINEAR_MIPMAP_NEAREST = 0x2701,
  LINES = 0x0001,
  LINE_LOOP = 0x0002,
  LINE_STRIP = 0x0003,
  LINE_WIDTH = 0x0B21,
  LINK_STATUS = 0x8B82,
  LOW_FLOAT = 0x8DF0,
  LOW_INT = 0x8DF3,
  LUMINANCE = 0x1909,
  LUMINANCE_ALPHA = 0x190A,
  MAX_COMBINED_TEXTURE_IMAGE_UNITS = 0x8B4D,
  MAX_CUBE_MAP_TEXTURE_SIZE = 0x851C,
  MAX_FRAGMENT_UNIFORM_VECTORS = 0x8DFD,
  MAX_RENDERBUFFER_SIZE = 0x84E8,
  MAX_TEXTURE_IMAGE_UNITS = 0x8872,
  MAX_TEXTURE_SIZE = 0x0D33,
  MAX_VARYING_VECTORS = 0x8DFC,
  MAX_VERTEX_ATTRIBS = 0x8869,
  MAX_VERTEX_TEXTURE_IMAGE_UNITS = 0x8B4C,
  MAX_VERTEX_UNIFORM_VECTORS = 0x8DFB,
  MAX_VIEWPORT_DIMS = 0x0D3A,
  MEDIUM_FLOAT = 0x8DF1,
  MEDIUM_INT = 0x8DF4,
  MIRRORED_REPEAT = 0x8370,
  NEAREST = 0x2600,
  NEAREST_MIPMAP_LINEAR = 0x2702,
  NEAREST_MIPMAP_NEAREST = 0x2700,
  NEVER = 0x0200,
  NICEST = 0x1102,
  NONE = 0,
  NOTEQUAL = 0x0205,
  NO_ERROR = 0,
  NUM_COMPRESSED_TEXTURE_FORMATS = 0x86A2,
  NUM_SHADER_BINARY_FORMATS = 0x8DF9,
  ONE = 1,
  ONE_MINUS_CONSTANT_ALPHA = 0x8004,
  ONE_MINUS_CONSTANT_COLOR = 0x8002,
  ONE_MINUS_DST_ALPHA = 0x0305,
  ONE_MINUS_DST_COLOR = 0x0307,
  ONE_MINUS_SRC_ALPHA = 0x0303,
  ONE_MINUS_SRC_COLOR = 0x0301,
  OUT_OF_MEMORY = 0x0505,
  PACK_ALIGNMENT = 0x0D05,
  POINTS = 0x0000,
  POLYGON_OFFSET_FACTOR = 0x8038,
  POLYGON_OFFSET_FILL = 0x8037,
  POLYGON_OFFSET_UNITS = 0x2A00,
  RED_BITS = 0x0D52,
  RENDERBUFFER = 0x8D41,
  RENDERBUFFER_ALPHA_SIZE = 0x8D53,
  RENDERBUFFER_BINDING = 0x8CA7,
  RENDERBUFFER_BLUE_SIZE = 0x8D52,
  RENDERBUFFER_DEPTH_SIZE = 0x8D54,
  RENDERBUFFER_GREEN_SIZE = 0x8D51,
  RENDERBUFFER_HEIGHT = 0x8D43,
  RENDERBUFFER_INTERNAL_FORMAT = 0x8D44,
  RENDERBUFFER_RED_SIZE = 0x8D50,
  RENDERBUFFER_STENCIL_SIZE = 0x8D55,
  RENDERBUFFER_WIDTH = 0x8D42,
  RENDERER = 0x1F01,
  REPEAT = 0x2901,
  REPLACE = 0x1E01,
  RGB = 0x1907,
  RGB565 = 0x8D62,
  RGB5_A1 = 0x8057,
  RGBA = 0x1908,
  RGBA4 = 0x8056,
  SAMPLER_2D = 0x8B5E,
  SAMPLER_CUBE = 0x8B60,
  SAMPLES = 0x80A9,
  SAMPLE_ALPHA_TO_COVERAGE = 0x809E,
  SAMPLE_BUFFERS = 0x80A8,
  SAMPLE_COVERAGE = 0x80A0,
  SAMPLE_COVERAGE_INVERT = 0x80AB,
  SAMPLE_COVERAGE_VALUE = 0x80AA,
  SCISSOR_BOX = 0x0C10,
  SCISSOR_TEST = 0x0C11,
  SHADER_BINARY_FORMATS = 0x8DF8,
  SHADER_COMPILER = 0x8DFA,
  SHADER_SOURCE_LENGTH = 0x8B88,
  SHADER_TYPE = 0x8B4F,
  SHADING_LANGUAGE_VERSION = 0x8B8C,
  SHORT = 0x1402,
  SRC_ALPHA = 0x0302,
  SRC_ALPHA_SATURATE = 0x0308,
  SRC_COLOR = 0x0300,
  STATIC_DRAW = 0x88E4,
  STENCIL_ATTACHMENT = 0x8D20,
  STENCIL_BACK_FAIL = 0x8801,
  STENCIL_BACK_FUNC = 0x8800,
  STENCIL_BACK_PASS_DEPTH_FAIL = 0x8802,
  STENCIL_BACK_PASS_DEPTH_PASS = 0x8803,
  STENCIL_BACK_REF = 0x8CA3,
  STENCIL_BACK_VALUE_MASK = 0x8CA4,
  STENCIL_BACK_WRITEMASK = 0x8CA5,
  STENCIL_BITS = 0x0D57,
  STENCIL_BUFFER_BIT = 0x00000400,
  STENCIL_CLEAR_VALUE = 0x0B91,
  STENCIL_FAIL = 0x0B94,
  STENCIL_FUNC = 0x0B92,
  STENCIL_INDEX = 0x1901,
  STENCIL_INDEX8 = 0x8D48,
  STENCIL_PASS_DEPTH_FAIL = 0x0B95,
  STENCIL_PASS_DEPTH_PASS = 0x0B96,
  STENCIL_REF = 0x0B97,
  STENCIL_TEST = 0x0B90,
  STENCIL_VALUE_MASK = 0x0B93,
  STENCIL_WRITEMASK = 0x0B98,
  STREAM_DRAW = 0x88E0,
  SUBPIXEL_BITS = 0x0D50,
  TEXTURE = 0x1702,
  TEXTURE0 = 0x84C0,
  TEXTURE1 = 0x84C1,
  TEXTURE10 = 0x84CA,
  TEXTURE11 = 0x84CB,
  TEXTURE12 = 0x84CC,
  TEXTURE13 = 0x84CD,
  TEXTURE14 = 0x84CE,
  TEXTURE15 = 0x84CF,
  TEXTURE16 = 0x84D0,
  TEXTURE17 = 0x84D1,
  TEXTURE18 = 0x84D2,
  TEXTURE19 = 0x84D3,
  TEXTURE2 = 0x84C2,
  TEXTURE20 = 0x84D4,
  TEXTURE21 = 0x84D5,
  TEXTURE22 = 0x84D6,
  TEXTURE23 = 0x84D7,
  TEXTURE24 = 0x84D8,
  TEXTURE25 = 0x84D9,
  TEXTURE26 = 0x84DA,
  TEXTURE27 = 0x84DB,
  TEXTURE28 = 0x84DC,
  TEXTURE29 = 0x84DD,
  TEXTURE3 = 0x84C3,
  TEXTURE30 = 0x84DE,
  TEXTURE31 = 0x84DF,
  TEXTURE4 = 0x84C4,
  TEXTURE5 = 0x84C5,
  TEXTURE6 = 0x84C6,
  TEXTURE7 = 0x84C7,
  TEXTURE8 = 0x84C8,
  TEXTURE9 = 0x84C9,
  TEXTURE_2D = 0x0DE1,
  TEXTURE_BINDING_2D = 0x8069,
  TEXTURE_BINDING_CUBE_MAP = 0x8514,
  TEXTURE_CUBE_MAP = 0x8513,
  TEXTURE_CUBE_MAP_NEGATIVE_X = 0x8516,
  TEXTURE_CUBE_MAP_NEGATIVE_Y = 0x8518,
  TEXTURE_CUBE_MAP_NEGATIVE_Z = 0x851A,
  TEXTURE_CUBE_MAP_POSITIVE_X = 0x8515,
  TEXTURE_CUBE_MAP_POSITIVE_Y = 0x8517,
  TEXTURE_CUBE_MAP_POSITIVE_Z = 0x8519,
  TEXTURE_MAG_FILTER = 0x2800,
  TEXTURE_MIN_FILTER = 0x2801,
  TEXTURE_WRAP_S = 0x2802,
  TEXTURE_WRAP_T = 0x2803,
  TRIANGLES = 0x0004,
  TRIANGLE_FAN = 0x0006,
  TRIANGLE_STRIP = 0x0005,
  TRUE = 1,
  UNPACK_ALIGNMENT = 0x0CF5,
  UNSIGNED_BYTE = 0x1401,
  UNSIGNED_INT = 0x1405,
  UNSIGNED_SHORT = 0x1403,
  UNSIGNED_SHORT_4_4_4_4 = 0x8033,
  UNSIGNED_SHORT_5_5_5_1 = 0x8034,
  UNSIGNED_SHORT_5_6_5 = 0x8363,
  VALIDATE_STATUS = 0x8B83,
  VENDOR = 0x1F00,
  VERSION = 0x1F02,
  VERTEX_ATTRIB_ARRAY_BUFFER_BINDING = 0x889F,
  VERTEX_ATTRIB_ARRAY_ENABLED = 0x8622,
  VERTEX_ATTRIB_ARRAY_NORMALIZED = 0x886A,
  VERTEX_ATTRIB_ARRAY_POINTER = 0x8645,
  VERTEX_ATTRIB_ARRAY_SIZE = 0x8623,
  VERTEX_ATTRIB_ARRAY_STRIDE = 0x8624,
  VERTEX_ATTRIB_ARRAY_TYPE = 0x8625,
  VERTEX_SHADER = 0x8B31,
  VIEWPORT = 0x0BA2,
  ZERO = 0,
  activeTexture = libgles2.glActiveTexture,
  attachShader = libgles2.glAttachShader,
  bindAttribLocation = libgles2.glBindAttribLocation,
  bindBuffer = libgles2.glBindBuffer,
  bindFramebuffer = libgles2.glBindFramebuffer,
  bindRenderbuffer = libgles2.glBindRenderbuffer,
  bindTexture = libgles2.glBindTexture,
  blendColor = libgles2.glBlendColor,
  blendEquation = libgles2.glBlendEquation,
  blendEquationSeparate = libgles2.glBlendEquationSeparate,
  blendFunc = libgles2.glBlendFunc,
  blendFuncSeparate = libgles2.glBlendFuncSeparate,
  bufferData = libgles2.glBufferData,
  bufferSubData = libgles2.glBufferSubData,
  checkFramebufferStatus = libgles2.glCheckFramebufferStatus,
  clear = libgles2.glClear,
  clearColor = libgles2.glClearColor,
  clearDepthf = libgles2.glClearDepthf,
  clearStencil = libgles2.glClearStencil,
  colorMask = libgles2.glColorMask,
  compileShader = libgles2.glCompileShader,
  compressedTexImage2D = libgles2.glCompressedTexImage2D,
  compressedTexSubImage2D = libgles2.glCompressedTexSubImage2D,
  copyTexImage2D = libgles2.glCopyTexImage2D,
  copyTexSubImage2D = libgles2.glCopyTexSubImage2D,
  createProgram = libgles2.glCreateProgram,
  createShader = libgles2.glCreateShader,
  cullFace = libgles2.glCullFace,
  deleteBuffers = libgles2.glDeleteBuffers,
  deleteFramebuffers = libgles2.glDeleteFramebuffers,
  deleteProgram = libgles2.glDeleteProgram,
  deleteRenderbuffers = libgles2.glDeleteRenderbuffers,
  deleteShader = libgles2.glDeleteShader,
  deleteTextures = libgles2.glDeleteTextures,
  depthFunc = libgles2.glDepthFunc,
  depthMask = libgles2.glDepthMask,
  depthRangef = libgles2.glDepthRangef,
  detachShader = libgles2.glDetachShader,
  disable = libgles2.glDisable,
  disableVertexAttribArray = libgles2.glDisableVertexAttribArray,
  drawArrays = libgles2.glDrawArrays,
  drawElements = libgles2.glDrawElements,
  enable = libgles2.glEnable,
  enableVertexAttribArray = libgles2.glEnableVertexAttribArray,
  finish = libgles2.glFinish,
  flush = libgles2.glFlush,
  framebufferRenderbuffer = libgles2.glFramebufferRenderbuffer,
  framebufferTexture2D = libgles2.glFramebufferTexture2D,
  frontFace = libgles2.glFrontFace,
  genBuffers = libgles2.glGenBuffers,
  generateMipmap = libgles2.glGenerateMipmap,
  genFramebuffers = libgles2.glGenFramebuffers,
  genRenderbuffers = libgles2.glGenRenderbuffers,
  genTextures = libgles2.glGenTextures,
  getActiveAttrib = libgles2.glGetActiveAttrib,
  getActiveUniform = libgles2.glGetActiveUniform,
  getAttachedShaders = libgles2.glGetAttachedShaders,
  getAttribLocation = libgles2.glGetAttribLocation,
  getBooleanv = libgles2.glGetBooleanv,
  getBufferParameteriv = libgles2.glGetBufferParameteriv,
  getError = libgles2.glGetError,
  getFloatv = libgles2.glGetFloatv,
  getFramebufferAttachmentParameteriv = 
    libgles2.glGetFramebufferAttachmentParameteriv,
  getIntegerv = libgles2.glGetIntegerv,
  getProgramiv = libgles2.glGetProgramiv,
  getProgramInfoLog = libgles2.glGetProgramInfoLog,
  getRenderbufferParameteriv = libgles2.glGetRenderbufferParameteriv,
  getShaderiv = libgles2.glGetShaderiv,
  getShaderInfoLog = libgles2.glGetShaderInfoLog,
  getShaderPrecisionFormat = libgles2.glGetShaderPrecisionFormat,
  getShaderSource = libgles2.glGetShaderSource,
  getString = libgles2.glGetString,
  getTexParameterfv = libgles2.glGetTexParameterfv,
  getTexParameteriv = libgles2.glGetTexParameteriv,
  getUniformfv = libgles2.glGetUniformfv,
  getUniformiv = libgles2.glGetUniformiv,
  getUniformLocation = libgles2.glGetUniformLocation,
  getVertexAttribfv = libgles2.glGetVertexAttribfv,
  getVertexAttribiv = libgles2.glGetVertexAttribiv,
  getVertexAttribPointerv = libgles2.glGetVertexAttribPointerv,
  hint = libgles2.glHint,
  isBuffer = libgles2.glIsBuffer,
  isEnabled = libgles2.glIsEnabled,
  isFramebuffer = libgles2.glIsFramebuffer,
  isProgram = libgles2.glIsProgram,
  isRenderbuffer = libgles2.glIsRenderbuffer,
  isShader = libgles2.glIsShader,
  isTexture = libgles2.glIsTexture,
  lineWidth = libgles2.glLineWidth,
  linkProgram = libgles2.glLinkProgram,
  pixelStorei = libgles2.glPixelStorei,
  polygonOffset = libgles2.glPolygonOffset,
  readPixels = libgles2.glReadPixels,
  releaseShaderCompiler = libgles2.glReleaseShaderCompiler,
  renderbufferStorage = libgles2.glRenderbufferStorage,
  sampleCoverage = libgles2.glSampleCoverage,
  scissor = libgles2.glScissor,
  shaderBinary = libgles2.glShaderBinary,
  shaderSource = libgles2.glShaderSource,
  stencilFunc = libgles2.glStencilFunc,
  stencilFuncSeparate = libgles2.glStencilFuncSeparate,
  stencilMask = libgles2.glStencilMask,
  stencilMaskSeparate = libgles2.glStencilMaskSeparate,
  stencilOp = libgles2.glStencilOp,
  stencilOpSeparate = libgles2.glStencilOpSeparate,
  texImage2D = libgles2.glTexImage2D,
  texParameterf = libgles2.glTexParameterf,
  texParameterfv = libgles2.glTexParameterfv,
  texParameteri = libgles2.glTexParameteri,
  texParameteriv = libgles2.glTexParameteriv,
  texSubImage2D = libgles2.glTexSubImage2D,
  uniform1f = libgles2.glUniform1f,
  uniform1fv = libgles2.glUniform1fv,
  uniform1i = libgles2.glUniform1i,
  uniform1iv = libgles2.glUniform1iv,
  uniform2f = libgles2.glUniform2f,
  uniform2fv = libgles2.glUniform2fv,
  uniform2i = libgles2.glUniform2i,
  uniform2iv = libgles2.glUniform2iv,
  uniform3f = libgles2.glUniform3f,
  uniform3fv = libgles2.glUniform3fv,
  uniform3i = libgles2.glUniform3i,
  uniform3iv = libgles2.glUniform3iv,
  uniform4f = libgles2.glUniform4f,
  uniform4fv = libgles2.glUniform4fv,
  uniform4i = libgles2.glUniform4i,
  uniform4iv = libgles2.glUniform4iv,
  uniformMatrix2fv = libgles2.glUniformMatrix2fv,
  uniformMatrix3fv = libgles2.glUniformMatrix3fv,
  uniformMatrix4fv = libgles2.glUniformMatrix4fv,
  useProgram = libgles2.glUseProgram,
  validateProgram = libgles2.glValidateProgram,
  vertexAttrib1f = libgles2.glVertexAttrib1f,
  vertexAttrib1fv = libgles2.glVertexAttrib1fv,
  vertexAttrib2f = libgles2.glVertexAttrib2f,
  vertexAttrib2fv = libgles2.glVertexAttrib2fv,
  vertexAttrib3f = libgles2.glVertexAttrib3f,
  vertexAttrib3fv = libgles2.glVertexAttrib3fv,
  vertexAttrib4f = libgles2.glVertexAttrib4f,
  vertexAttrib4fv = libgles2.glVertexAttrib4fv,
  vertexAttribPointer = libgles2.glVertexAttribPointer,
  viewport = libgles2.glViewport,
}

function gl.checkError(message)
  local err = gl.getError()
  if (err == gl.INVALID_ENUM) then
    util.printf("%s : GL_INVALID_ENUM\n", message)
  elseif (err == gl.INVALID_VALUE) then
    util.printf("%s : GL_INVALID_VALUE\n", message)
  elseif (err == gl.INVALID_OPERATION) then
    util.printf("%s : GL_INVALID_OPERATION\n", message)
  elseif (err == gl.OUT_OF_MEMORY) then
    util.printf("%s : GL_OUT_OF_MEMORY\n", message)
  elseif (err == gl.NO_ERROR) then
    util.printf("%s : GL_NO_ERROR\n", message)
  end
end

return gl
