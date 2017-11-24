-- Copyright (C) by Yichun Zhang (agentzh)
-- Copyright (C) by OpenResty Inc.


local ffi = require("ffi")
local get_string_buf = require("resty.core.base").get_string_buf
local ffi_str = ffi.string
local C = ffi.C
local NGX_ERROR = ngx.ERROR

local _M = { _VERSION = '0.10' }


ffi.cdef[[
typedef intptr_t        ngx_int_t;

void ngx_encode_base64(ngx_str_t *dst, ngx_str_t *src);
void ngx_encode_base64url(ngx_str_t *dst, ngx_str_t *src);
ngx_int_t ngx_decode_base64(ngx_str_t *dst, ngx_str_t *src);
ngx_int_t ngx_decode_base64url(ngx_str_t *dst, ngx_str_t *src);
]]

local dst = ffi.new("ngx_str_t[1]")
local src = ffi.new("ngx_str_t[1]")


local function base64_encoded_length(len)
    return ((len + 2) / 3) * 4
end


local function base64_decoded_length(len)
    return ((len + 3) / 4) * 3
end


local function transform_helper(s, trans_func, len_func)
    local len = #s
    local trans_len = len_func(len)

    src[0].data = s
    src[0].len = len

    dst[0].data = get_string_buf(trans_len)
    dst[0].len = trans_len

    local ret = trans_func(dst, src);
    if ret == NGX_ERROR then
        return false, "invalid input"
    end

    return ffi_str(dst[0].data, dst[0].len)
end


function _M.encode_base64(s)
    return transform_helper(s, C.ngx_encode_base64, base64_encoded_length)
end


function _M.encode_base64url(s)
    return transform_helper(s, C.ngx_encode_base64url, base64_encoded_length)
end


function _M.decode_base64(s)
    return transform_helper(s, C.ngx_decode_base64, base64_decoded_length)
end


function _M.decode_base64url(s)
    return transform_helper(s, C.ngx_decode_base64url, base64_decoded_length)
end


return _M
