-- Copyright (C) 2012 by Yichun Zhang (agentzh)


local ffi = require "ffi"
local ffi_new = ffi.new
local ffi_str = ffi.string
local C = ffi.C
local setmetatable = setmetatable
local error = error


module(...)

_VERSION = '0.08'


ffi.cdef[[
int RAND_bytes(unsigned char *buf, int num);
int RAND_pseudo_bytes(unsigned char *buf, int num);
]]


function bytes(len, strong)
    local buf = ffi_new("char[?]", len)
    if strong then
        if C.RAND_bytes(buf, len) == 0 then
            return nil
        end
    else
        C.RAND_pseudo_bytes(buf,len)
    end

    return ffi_str(buf, len)
end


local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)

