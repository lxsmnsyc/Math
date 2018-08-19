local vec3 = require "math.double.vector.vec3"

local ffi = require "ffi"

local istype, new = ffi.istype, ffi.new


ffi.cdef[[
    typedef struct{
        vec3 origin, direction;
        double tMax;
    } ray3;
]]

local ray3

local function isnum(v)
    return type(v) == "number"
end

local function isray(r)
    return istype("ray3", r)
end

local mt = {}
local mti = {
    get = function(r, t)
        return r.origin + r.direction * t * r.tMax
    end,

}

mt.__index = mti

ray3 = ffi.metatype("ray3", mt)

return ray2