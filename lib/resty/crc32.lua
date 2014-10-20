-- Copyright (C) by Shafreeck Sea (shafreeck)


local ffi = require "ffi"
local C = ffi.C
local setmetatable = setmetatable
local tonumber = tonumber


local _M = { _VERSION = '0.09' }

local mt = { __index = _M }


ffi.cdef[[
unsigned long  crc32 (unsigned long crc, const char *buf, unsigned int len);
]]

function _M.new(self)
    local ctx = 0
    return setmetatable({ _ctx = ctx }, mt)
end


function _M.update(self, s)
    self._ctx = C.crc32(self._ctx, s, #s) 
    return tonumber(self._ctx)
end


function _M.final(self)
    return tonumber(self._ctx)
end

return _M

