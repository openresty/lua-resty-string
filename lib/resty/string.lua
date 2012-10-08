module("resty.string", package.seeall)

_VERSION = '0.06'

local ffi = require "ffi"
local ffi_new = ffi.new
local ffi_str = ffi.string
local C = ffi.C

ffi.cdef[[
typedef unsigned char u_char;

u_char * ngx_hex_dump(u_char *dst, const u_char *src, size_t len);

intptr_t ngx_atoi(const unsigned char *line, size_t n);
]]

local str_type = ffi.typeof("uint8_t[?]")


function to_hex(s)
    local len = #s * 2
    local buf = ffi_new(str_type, len)
    C.ngx_hex_dump(buf, s, #s)
    return ffi_str(buf, len)
end


function atoi(s)
    return tonumber(C.ngx_atoi(s, #s))
end


local strfind = string.find
local strsub = string.sub
local strlen = string.len
function explode(sep, str, limit)
    if not sep or sep == "" then return false end
    if not str then return false end
    limit = limit or 0
    if limit == 0 or limit == 1 then return {str},1 end

    local r = {}
    local n, init = 0, 1

    while true do
        local s,e = strfind(str, sep, init, true)
        if not s then break end
        r[#r+1] = strsub(str, init, s - 1)
        init = e + 1
        n = n + 1
        if n == limit - 1 then break end
    end

    if init <= strlen(str) then 
        r[#r+1] = strsub(str, init) 
    else 
        r[#r+1] = "" 
    end
    n = n + 1

    if limit < 0 then
        for i=n, n + limit + 1, -1 do r[i] = nil end
        n = n + limit
    end

    return r, n
end


-- to prevent use of casual module global variables
getmetatable(resty.string).__newindex = function (table, key, val)
    error('attempt to write to undeclared variable "' .. key .. '": '
            .. debug.traceback())
end

