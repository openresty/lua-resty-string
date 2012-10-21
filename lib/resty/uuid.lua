module("resty.uuid", package.seeall)

_VERSION = '0.01'

local ffi = require "ffi"
local ffi_new = ffi.new
local ffi_str = ffi.string

ffi.cdef[[
    typedef unsigned char uuid_t[16];
    void uuid_generate(uuid_t out);
    void uuid_unparse(const uuid_t uu, char *out);
]]

local libuuid = ffi.load("libuuid")

function generate()
    if libuuid then
        local uuid   = ffi_new("uuid_t")
        local result = ffi_new("char[36]")
        libuuid.uuid_generate(uuid)
        libuuid.uuid_unparse(uuid, result)
        return ffi_str(result)
    end
end

-- to prevent use of casual module global variables
getmetatable(resty.uuid).__newindex = function (table, key, val)
    error('attempt to write to undeclared variable "' .. key .. '": '
            .. debug.traceback())
end
