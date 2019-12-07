-- Copyright (C) by Yichun Zhang (agentzh)


local ffi = require "ffi"
local ffi_new = ffi.new
local ffi_str = ffi.string
local C = ffi.C
--local setmetatable = setmetatable
--local error = error
local tonumber = tonumber


local _M = { _VERSION = '0.12' }


ffi.cdef[[
typedef unsigned char u_char;

u_char * ngx_hex_dump(u_char *dst, const u_char *src, size_t len);

intptr_t ngx_atoi(const unsigned char *line, size_t n);
]]

local str_type = ffi.typeof("uint8_t[?]")


function _M.to_hex(s)
    local len = #s
    local buf_len = len * 2
    local buf = ffi_new(str_type, buf_len)
    C.ngx_hex_dump(buf, s, len)
    return ffi_str(buf, buf_len)
end


function _M.from_hex(s)
    local hex_to_char = {}
    for idx = 0, 255 do
    hex_to_char[("%02X"):format(idx)] = string.char(idx)
    hex_to_char[("%02x"):format(idx)] = string.char(idx)
    end

    return s:gsub("(..)", hex_to_char)
end

function _M.atoi(s)
    return tonumber(C.ngx_atoi(s, #s))
end


return _M
