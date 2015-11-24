-- Copyright (C) by Yichun Zhang (agentzh)


local crypto = require "resty.crypto"
local crypto_new = crypto.new
local ffi = require "ffi"
local C = ffi.C
local setmetatable = setmetatable


local _M = { _VERSION = '0.09' }

_M = setmetatable(_M, { __index = crypto })


ffi.cdef[[
const EVP_CIPHER *EVP_des_ecb(void);
const EVP_CIPHER *EVP_des_cfb1(void);
const EVP_CIPHER *EVP_des_cfb8(void);
const EVP_CIPHER *EVP_des_cfb64(void);
const EVP_CIPHER *EVP_des_ofb(void);
const EVP_CIPHER *EVP_des_cbc(void);
]]


local cipher
cipher = function (_cipher)
    local _cipher = _cipher or "cbc"
    local func = "EVP_des_" .. _cipher
    if C[func] then
        return { size=64, ivl=8, cipher=_cipher, method=C[func]() }
    else
        return nil
    end
end
_M.cipher = cipher


return _M

