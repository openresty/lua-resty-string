-- Copyright (C) by Yichun Zhang (agentzh)


--local asn1 = require "resty.asn1"
local ffi = require "ffi"
local ffi_new = ffi.new
local ffi_gc = ffi.gc
local ffi_str = ffi.string
local ffi_copy = ffi.copy
local C = ffi.C
local setmetatable = setmetatable
--local error = error
local type = type


local _M = { _VERSION = '0.12' }

local mt = { __index = _M }


ffi.cdef[[

typedef struct env_md_st EVP_MD;

const EVP_MD *EVP_md5(void);
const EVP_MD *EVP_sha(void);
const EVP_MD *EVP_sha1(void);
const EVP_MD *EVP_sha224(void);
const EVP_MD *EVP_sha256(void);
const EVP_MD *EVP_sha384(void);
const EVP_MD *EVP_sha512(void);
void EVP_MD_free(EVP_MD *md);

unsigned char *HMAC(const EVP_MD *evp_md, const void *key,
    int key_len, const unsigned char *d, int n,
    unsigned char *md, unsigned int *md_len);
]]

local hash
hash = {
    md5 = C.EVP_md5(),
    sha1 = C.EVP_sha1(),
    sha224 = C.EVP_sha224(),
    sha256 = C.EVP_sha256(),
    sha384 = C.EVP_sha384(),
    sha512 = C.EVP_sha512()
}

_M.hash = hash

function _M.HMAC(key, data, hashfunc)
    if not hashfunc then
        return nil, "bad method"
    end

    -- local md = ffi_new("unsigned char[?]", 64)
    local md_len = ffi_new("int[1]")
    md_len[0] = 64

    local md = C.HMAC(hashfunc, key, #key, data, #data, nil, md_len)

    return ffi_str(md, md_len[0])
end


return _M

