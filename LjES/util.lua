-- ---------------------------------------------
-- util.lua        2014/06/05
--   Copyright (c) 2013-2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------

local ffi = require("ffi")

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
  ffi.C.poll(nil, 0, sec * 1000)
end

function util.gettimeofday()
  local t = ffi.new("timeval")
  ffi.C.gettimeofday(t, nil)
  return t.tv_sec, t.tv_usec
end

function util.now()
  local sec, usec = util.gettimeofday()
  return tonumber(sec) + tonumber(usec) / 1000000
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
    return false
  end
end

function util.readFile(filename)
  local f = assert(io.open(filename, "rb"))
  local text = f:read("*all")
  f:close()
  return text
end

function util.printf(fmt, ...)
  io.write(string.format(fmt, ...))
end

function util.print()
  io.write("\n")
end

function util.countTableElements(tbl)
  local count = 0
  for _ in pairs(tbl) do
    count = count + 1
  end
  return count
end

-- simple table copy
-- No:circular reference, keys which are tables, metatable
function util.copyTable(dest, source)
  for key, value in pairs(source) do
    if type(value) == 'table' then
      local t ={}
      util.copyTable(t, value)
      dest[key] = t
    else
      dest[key] = value
    end
  end
end

function util.checkTable(Table)
  util.printf("------ %15s ---(meta)---> %s\n", Table, getmetatable(Table))
  local nameList = {}
  for name, value in pairs(Table) do
    nameList[#nameList + 1] = name
  end
  table.sort(nameList)
  for i = 1, #nameList do
    util.printf("%24s  -- %s\n", nameList[i], Table[nameList[i]])
  end
  util.printf("\n")

  local mt = getmetatable(Table)
  if mt ~= nil then
    local next = mt.__index
    if next ~= nil then util.checkTable(next) end
  end
end

return util
