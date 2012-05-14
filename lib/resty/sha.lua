module("resty.sha", package.seeall)

_VERSION = '0.06'

local ffi = require "ffi"

ffi.cdef[[
typedef unsigned long SHA_LONG;
typedef unsigned long long SHA_LONG64;

enum {
    SHA_LBLOCK = 16
};
]];

