module("resty.md5", package.seeall)

_VERSION = '0.06'

local ffi = require "ffi"
local ffi_new = ffi.new
local ffi_str = ffi.string
local C = ffi.C

local mt = { __index = resty.md5 }


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

function save_ctx(self, fn)
    local f,err = io.open(fn, "w")
    if not f then 
        return nil, err
    end
    
    local ctx = {}
    ctx.A   = self._ctx[0].A   
    ctx.B   = self._ctx[0].B   
    ctx.C   = self._ctx[0].C   
    ctx.D   = self._ctx[0].D   
    ctx.Nl  = self._ctx[0].Nl  
    ctx.Nh  = self._ctx[0].Nh  
    ctx.num = self._ctx[0].num 
    ctx.data = {}
    for i = 0,15 do
        ctx.data[i+1] = self._ctx[0].data[i]
    end

    local cjson = require("cjson")
    f:write(cjson.encode(ctx))
    f:close()
    return true
end

function load_ctx(self, fn)
    local f,err = io.open(fn, "r")
    if not f then 
        return nil, err
    end
    local jstr = f:read()
    f:close()

    local cjson = require("cjson")
    local ctx = cjson.decode(jstr)
    self._ctx[0].A = ctx.A
    self._ctx[0].B = ctx.B
    self._ctx[0].C = ctx.C
    self._ctx[0].D = ctx.D
    self._ctx[0].Nl = ctx.Nl
    self._ctx[0].Nh = ctx.Nh
    self._ctx[0].num = ctx.num

    for i = 0,15 do
        self._ctx[0].data[i] = ctx.data[i+1]
    end
    return true
end

-- to prevent use of casual module global variables
getmetatable(resty.md5).__newindex = function (table, key, val)
    error('attempt to write to undeclared variable "' .. key .. '": '
            .. debug.traceback())
end

