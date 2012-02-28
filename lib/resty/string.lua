module("resty.string", package.seeall)


local ffi = require "ffi"
local ffi_new = ffi.new
local ffi_str = ffi.string
local C = ffi.C

local mt = { __index = resty.sha1 }

ffi.cdef[[
typedef unsigned char u_char;

u_char * ngx_hex_dump(u_char *dst, const u_char *src, size_t len);
]]


function to_hex(s)
    local len = #s * 2
    local buf = ffi_new("uint8_t[?]", len)
    C.ngx_hex_dump(buf, s, #s)
    return ffi_str(buf, len)
end


-- to prevent use of casual module global variables
getmetatable(resty.string).__newindex = function (table, key, val)
    error('attempt to write to undeclared variable "' .. key .. '": '
            .. debug.traceback())
end

