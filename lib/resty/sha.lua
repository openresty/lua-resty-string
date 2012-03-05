module("resty.sha", package.seeall)

_VERSION = '0.04'

local ffi = require "ffi"

ffi.cdef[[
typedef unsigned long SHA_LONG;

enum {
    SHA_LBLOCK = 16
};
]];

