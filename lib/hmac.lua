-- Adds HMAC support to Lua with multiple algorithms, via OpenSSL and FFI
--
-- Author: ddragosd@gmail.com
-- Date: 16/05/14
--


local ffi = require "ffi"
local ffi_new = ffi.new
local ffi_str = ffi.string
local C = ffi.C
local resty_string = require "resty.string"
local setmetatable = setmetatable
local error = error


module(...)

_VERSION = '0.08'


local mt = { __index = _M }

--
-- EVP_MD is defined in openssl/evp.h
-- HMAC is defined in openssl/hmac.h
--
ffi.cdef[[
typedef struct env_md_st EVP_MD;
typedef struct env_md_ctx_st EVP_MD_CTX;
unsigned char *HMAC(const EVP_MD *evp_md, const void *key, int key_len,
		    const unsigned char *d, size_t n, unsigned char *md,
		    unsigned int *md_len);
const EVP_MD *EVP_sha1(void);
const EVP_MD *EVP_sha224(void);
const EVP_MD *EVP_sha256(void);
const EVP_MD *EVP_sha384(void);
const EVP_MD *EVP_sha512(void);
]]

-- table definind the available algorithms and the length of each digest
-- for more information @see: http://csrc.nist.gov/publications/fips/fips180-4/fips-180-4.pdf
local available_algorithms = {
    sha1   = { method = "EVP_sha1",   length = 160/8   },
    sha224 = { method = "EVP_sha224", length = 224/8   },
    sha256 = { method = "EVP_sha256", length = 256/8   },
    sha384 = { method = "EVP_sha384", length = 384/8   },
    sha512 = { method = "EVP_sha512", length = 512/8   }
}


function new(self)
    return setmetatable({}, mt)
end

local function getDigestAlgorithm(dtype)
    local md_name = available_algorithms[dtype]
    if ( md_name == nil ) then
        error("attempt to use unkown algorithm: '" .. dtype ..
                "'.\n Available algorithms are: sha1,sha224,sha256,sha384,sha512")
    end
    return C[md_name.method](), md_name.length
end

---
-- Returns the HMAC-SHA256 digest.
-- The optional raw flag, defaulted to false, is a boolean indicating whether the output should be a direct binary
-- equivalent of the HMAC or formatted as a hexadecimal string (the default)
--
-- TBD: should this method be more generic and support multiple hashing algorithms ( I.e. SHA1,SHA224,SHA256,SHA384,SHA512 ) ?
--
-- @param self
-- @param dtype The hashing algorithm to use is specified by dtype
-- @param key The secret
-- @param msg The message to be signed
-- @param raw When true, it returns the binary format, else, the hex format is returned
--
function digest(self, dtype, key, msg, raw)
    local binary_format = raw or false
    --local evp_md = C.EVP_sha256()
    local evp_md, digest_length_int = getDigestAlgorithm(dtype)

    local digest_len = ffi_new("int[?]", digest_length_int)
    local buf = ffi_new("char[?]", digest_length_int)

    C.HMAC(evp_md, key, #key, msg, #msg, buf, digest_len)

    if binary_format == true then
        return ffi_str(buf,digest_length_int)
    end
    return resty_string.to_hex(ffi_str(buf,digest_length_int))
end


local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)



