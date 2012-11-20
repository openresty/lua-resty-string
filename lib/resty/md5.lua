-- Copyright (C) 2012 by Yichun Zhang (agentzh)


local ffi = require "ffi"
local ffi_new = ffi.new
local ffi_str = ffi.string
local C = ffi.C
local setmetatable = setmetatable
local error = error


module(...)

_VERSION = '0.08'

local mt = { __index = _M }


ffi.cdef[[
typedef unsigned long MD5_LONG ;

enum {
    MD5_CBLOCK = 64,
    MD5_LBLOCK = MD5_CBLOCK/4
};

typedef struct MD5state_st
        {
        MD5_LONG A,B,C,D;
        MD5_LONG Nl,Nh;
        MD5_LONG data[MD5_LBLOCK];
        unsigned int num;
        } MD5_CTX;

int MD5_Init(MD5_CTX *c);
int MD5_Update(MD5_CTX *c, const void *data, size_t len);
int MD5_Final(unsigned char *md, MD5_CTX *c);
]]

local buf = ffi_new("char[16]")
local ctx_ptr_type = ffi.typeof("MD5_CTX[1]")


function new(self)
    local ctx = ffi_new(ctx_ptr_type)
    if C.MD5_Init(ctx) == 0 then
        return nil
    end

    return setmetatable({ _ctx = ctx }, mt)
end


function update(self, s)
    return C.MD5_Update(self._ctx, s, #s) == 1
end


function final(self)
    if C.MD5_Final(buf, self._ctx) == 1 then
        return ffi_str(buf, 16)
    end

    return nil
end


function reset(self)
    return C.MD5_Init(self._ctx) == 1
end


local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)

