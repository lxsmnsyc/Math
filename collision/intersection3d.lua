local ffi = require "ffi"

local vec3 = require "math.vector.vec3"
local ray3 = require "math.ray.ray3"

local shape = require "math.shape3d.shape"

local new, istype = ffi.new, ffi.istype


ffi.cdef[[
    typedef struct {
        ray3 ray;
        float t;
        vec3 color;
    }
]]


