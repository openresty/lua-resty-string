-- Copyright (C) by Yichun Zhang (agentzh)


local ffi = require "ffi"
local ffi_new = ffi.new
local ffi_str = ffi.string
local C = ffi.C
local setmetatable = setmetatable
local error = error
local type = type
local random = math.random
local randomseed = math.randomseed
local time = os.time

local t_concat = table.concat
local ok, t_new = pcall(require, "table.new")
if not ok then
    t_new = function(narr, nrec) return {} end
end

local _M = { _VERSION = '0.09' }


ffi.cdef[[
int RAND_bytes(unsigned char *buf, int num);
int RAND_pseudo_bytes(unsigned char *buf, int num);
]]


function _M.bytes(len, strong)
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

function _M.seed()
    local seed = t_new(8,0);
    local bytes = _M.bytes(8);
    for i=1,8 do
        seed[i]=bytes:byte(i);
    end

    return randomseed(seed[2] * 0xfeed + seed[7] * 0x175 + seed[4] * 0xb001 + seed[1] * 0x5eed + seed[6] * 0xb1 + seed[8] * 0xd34d + seed[3] * 0xf00d + seed[5] * 0xcafe + 0x47 * time());
end

function _M.number(min, max, strong)
    if strong then
        _M.seed()
    end

    if min then
        if max then
            return random(min,max)
        else
            return random(min)
        end
    else
        return random()
    end
end

function _M.token(len, dict)
    local an = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    local dict = dict or an;
    local token = t_new(len, 0);
    if type(dict) == "table" then
        dict = t_concat(dict);
    end;
    dict = tostring(dict);
    for i=1,len do
        local n = _M.number(1, #dict);
        token[i] = dict:sub(n, n);
    end

    return t_concat(token)
end

_M.seed()

return _M

