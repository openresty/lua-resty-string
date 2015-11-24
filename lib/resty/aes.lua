-- Copyright (C) by Yichun Zhang (agentzh)


local crypto = require "resty.crypto"
local crypto_new = crypto.new
local ffi = require "ffi"
local C = ffi.C
local setmetatable = setmetatable


local _M = { _VERSION = '0.09' }

_M = setmetatable(_M, { __index = crypto })


ffi.cdef[[
const EVP_CIPHER *EVP_aes_128_ecb(void);
const EVP_CIPHER *EVP_aes_128_cbc(void);
const EVP_CIPHER *EVP_aes_128_cfb1(void);
const EVP_CIPHER *EVP_aes_128_cfb8(void);
const EVP_CIPHER *EVP_aes_128_cfb128(void);
const EVP_CIPHER *EVP_aes_128_ofb(void);
const EVP_CIPHER *EVP_aes_128_ctr(void);
const EVP_CIPHER *EVP_aes_192_ecb(void);
const EVP_CIPHER *EVP_aes_192_cbc(void);
const EVP_CIPHER *EVP_aes_192_cfb1(void);
const EVP_CIPHER *EVP_aes_192_cfb8(void);
const EVP_CIPHER *EVP_aes_192_cfb128(void);
const EVP_CIPHER *EVP_aes_192_ofb(void);
const EVP_CIPHER *EVP_aes_192_ctr(void);
const EVP_CIPHER *EVP_aes_256_ecb(void);
const EVP_CIPHER *EVP_aes_256_cbc(void);
const EVP_CIPHER *EVP_aes_256_cfb1(void);
const EVP_CIPHER *EVP_aes_256_cfb8(void);
const EVP_CIPHER *EVP_aes_256_cfb128(void);
const EVP_CIPHER *EVP_aes_256_ofb(void);
]]


local cipher
cipher = function (size, _cipher)
    local _size = size or 128
    local _cipher = _cipher or "cbc"
    local func = "EVP_aes_" .. _size .. "_" .. _cipher
    if C[func] then
        return { size=_size, ivl=16, cipher=_cipher, method=C[func]()}
    else
        return nil
    end
end
_M.cipher = cipher


return _M

