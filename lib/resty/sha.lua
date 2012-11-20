-- Copyright (C) 2012 by Yichun Zhang (agentzh)


local ffi = require "ffi"


module(...)

_VERSION = '0.08'


ffi.cdef[[
typedef unsigned long SHA_LONG;
typedef unsigned long long SHA_LONG64;

enum {
    SHA_LBLOCK = 16
};
]];

