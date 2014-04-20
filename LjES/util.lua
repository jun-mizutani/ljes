-- ---------------------------------------------
-- util.lua        2013/04/10
--   Copyright (c) 2013 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

local ffi = require "ffi"

ffi.cdef[[
  typedef struct timeval {
    long tv_sec;
    long tv_usec;
  } timeval;

  int gettimeofday(struct timeval *tv, void *tz);
  int poll(struct pollfd *fds, unsigned long nfds, int timeout);
]]


local util = {}

function util.sleep(sec)
  ffi.C.poll(nil, 0, sec*1000)
end

function util.gettimeofday()
  local t = ffi.new("timeval")
  ffi.C.gettimeofday(t, nil)
  return t.tv_sec, t.tv_usec
end

function util.packagePath()
  for s in string.gmatch(package.path, ".-;") do
    local path = string.match(s, ".+LjES/")
    if path ~= nil then return path end
  end
  return nil
end

function util.isFileExist(file)
  local fh, errormsg = io.open(file)
  if fh then
    fh:close()
    return true
  else
    return fase
  end
end

return util
