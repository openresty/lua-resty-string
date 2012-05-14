module("resty.sha512", package.seeall)

_VERSION = '0.06'

local sha = require "resty.sha"
local ffi = require "ffi"
local ffi_new = ffi.new
local ffi_str = ffi.string
local C = ffi.C

local mt = { __index = resty.sha512 }


ffi.cdef[[
enum {
    SHA512_CBLOCK = SHA_LBLOCK*8
};

typedef struct SHA512state_st
        {
        SHA_LONG64 h[8];
        SHA_LONG64 Nl,Nh;
        union {
                SHA_LONG64      d[SHA_LBLOCK];
                unsigned char   p[SHA512_CBLOCK];
        } u;
        unsigned int num,md_len;
        } SHA512_CTX;

int SHA512_Init(SHA512_CTX *c);
int SHA512_Update(SHA512_CTX *c, const void *data, size_t len);
int SHA512_Final(unsigned char *md, SHA512_CTX *c);
]]

local digest_len = 64

local buf = ffi_new("char[?]", digest_len)
local ctx_ptr_type = ffi.typeof("SHA512_CTX[1]")


function new(self)
    local ctx = ffi_new(ctx_ptr_type)
    if C.SHA512_Init(ctx) == 0 then
        return nil
    end

    return setmetatable({ _ctx = ctx }, mt)
end


function update(self, s)
    return C.SHA512_Update(self._ctx, s, #s) == 1
end


function final(self)
    if C.SHA512_Final(buf, self._ctx) == 1 then
        return ffi_str(buf, digest_len)
    end

    return nil
end


function reset(self)
    return C.SHA512_Init(self._ctx) == 1
end


-- to prevent use of casual module global variables
getmetatable(resty.sha512).__newindex = function (table, key, val)
    error('attempt to write to undeclared variable "' .. key .. '": '
            .. debug.traceback())
end

