module("resty.sha384", package.seeall)

_VERSION = '0.06'

local sha512 = require "resty.sha512"
local ffi = require "ffi"
local ffi_new = ffi.new
local ffi_str = ffi.string
local C = ffi.C

local mt = { __index = resty.sha384 }


ffi.cdef[[
int SHA384_Init(SHA512_CTX *c);
int SHA384_Update(SHA512_CTX *c, const void *data, size_t len);
int SHA384_Final(unsigned char *md, SHA512_CTX *c);
]]

local digest_len = 48

local buf = ffi_new("char[?]", digest_len)
local ctx_ptr_type = ffi.typeof("SHA512_CTX[1]")


function new(self)
    local ctx = ffi_new(ctx_ptr_type)
    if C.SHA384_Init(ctx) == 0 then
        return nil
    end

    return setmetatable({ _ctx = ctx }, mt)
end


function update(self, s)
    return C.SHA384_Update(self._ctx, s, #s) == 1
end


function final(self)
    if C.SHA384_Final(buf, self._ctx) == 1 then
        return ffi_str(buf, digest_len)
    end

    return nil
end


function reset(self)
    return C.SHA384_Init(self._ctx) == 1
end


-- to prevent use of casual module global variables
getmetatable(resty.sha384).__newindex = function (table, key, val)
    error('attempt to write to undeclared variable "' .. key .. '": '
            .. debug.traceback())
end

