-- ---------------------------------------------
-- termios.lua      2013/03/20
--   Copyright (c) 2013 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

--[[
  termios.getTermios()
  termios.setTermios()
  termios.restoreTermios()
  termios.setRawMode()
  termios.resetRawMode()
  termios.noEcho()
  termios.echo()
  termios.noWait()
  termios.wait()
  termios.realtimeKey()
]]

local ffi = require("ffi")
local bit = require("bit")

ffi.cdef[[
typedef unsigned char   cc_t;
typedef unsigned int    speed_t;
typedef unsigned int    tcflag_t;

struct termios
  {
    tcflag_t c_iflag;           /* input mode flags */
    tcflag_t c_oflag;           /* output mode flags */
    tcflag_t c_cflag;           /* control mode flags */
    tcflag_t c_lflag;           /* local mode flags */
    cc_t c_line;                /* line discipline */
    cc_t c_cc[32];              /* control characters */
    speed_t c_ispeed;           /* input speed */
    speed_t c_ospeed;           /* output speed */
  };

int tcgetattr(int fd, struct termios *termios_p);
int tcsetattr(int fd, int optional_actions, const struct termios *termios_p);

]]

local termios = {
  -- c_cc characters
  VINTR    = 0,
  VQUIT    = 1,
  VERASE   = 2,
  VKILL    = 3,
  VEOF     = 4,
  VTIME    = 5,
  VMIN     = 6,
  VSWTC    = 7,
  VSTART   = 8,
  VSTOP    = 9,
  VSUSP    = 10,
  VEOL     = 11,
  VREPRINT = 12,
  VDISCARD = 13,
  VWERASE  = 14,
  VLNEXT   = 15,
  VEOL2    = 16,
  -- c_lflag bits
  ICANON  = 2,
  XCASE   = 4,
  ECHO    = 8,
  ECHOE   = 16,
  ECHOK   = 32,
  ECHONL  = 64,
  NOFLSH  = 128,
  TOSTOP  = 256,
  -- tcsetattr
  TCSANOW     = 0,
  TCSADRAIN   = 1,
  TCSAFLUSH   = 2
}

local bnot, bor, band = bit.bnot, bit.bor, bit.band

termios.old_termios = ffi.new("struct termios[1]")
termios.new_termios = ffi.new("struct termios[1]")
termios.new = nil
termios.old = nil
termios.status = false

function termios.getTermios()
  if termios.status == false then
    ffi.C.tcgetattr(0, termios.old_termios)
    ffi.C.tcgetattr(0, termios.new_termios)
    termios.new = termios.new_termios[0]
    termios.old = termios.old_termios[0]
    termios.status = true
  end
end

function termios.setTermios()
  if termios.status then
    ffi.C.tcsetattr(0, termios.TCSANOW, termios.new_termios)
  end
end

function termios.restoreTermios()
  if termios.status then
    ffi.C.tcsetattr(0, termios.TCSANOW, termios.old_termios)
  end
end

function termios.setRawMode()
  if termios.status then
    termios.new["c_lflag"] = band(termios.new["c_lflag"], bnot(termios.ECHO),
                             bnot(termios.ECHONL), bnot(termios.ICANON))
    termios.new["c_cc"][termios.VTIME] = 0
    termios.new["c_cc"][termios.VMIN] = 1
    termios.setTermios()
  end
end

function termios.resetRawMode()
  if termios.status then
    termios.new["c_lflag"] = bor(termios.new["c_lflag"], termios.ICANON,
                                 termios.ECHO, termios.ECHONL)
    termios.new["c_cc"][termios.VTIME] = 0
    termios.new["c_cc"][termios.VMIN] = 1
    termios.setTermios()
  end
end

function termios.noEcho()
  if termios.status then
    termios.new["c_lflag"] = band(termios.new["c_lflag"],
                             bnot(termios.ECHO), bnot(termios.ECHONL))
    termios.setTermios()
  end
end

function termios.echo()
  if termios.status then
    termios.new["c_lflag"] = bor(termios.new["c_lflag"],
                                 termios.ECHO, termios.ECHONL)
    termios.setTermios()
  end
end

function termios.noWait()
  if termios.status then
    termios.new["c_cc"][termios.VMIN] = 0
    termios.setTermios()
  end
end

function termios.wait()
  if termios.status then
    termios.new["c_cc"][termios.VMIN] = 1
    termios.setTermios()
  end
end

function termios.realtimeKey()
  local key, code
  termios.noWait()
  key = io.read(1)
  if key == nil then
    code = 0
  else
    code = string.byte(key)
  end
  termios.wait()
  return string.char(code)
end

return termios
