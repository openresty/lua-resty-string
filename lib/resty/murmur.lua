-- Copyright (C) by Yichun Zhang (agentzh)


local ffi = require "ffi"
local ffi_new = ffi.new
local ffi_copy = ffi.copy
local ffi_str = ffi.string
local C = ffi.C
local setmetatable = setmetatable


local _M = { _VERSION = "0.01" }

local mt = { __index = _M }


ffi.cdef[[
typedef unsigned char u_char;

uint32_t ngx_murmur_hash2(u_char *data, size_t len);
]]

local str_type = ffi.typeof("uint8_t[?]")


function _M.murmur_hash2(s)
    local len = #s
    local buf = ffi_new(str_type, len)
    ffi_copy(buf, s, len)

    return C.ngx_murmur_hash2(buf, len)
end


return _M
