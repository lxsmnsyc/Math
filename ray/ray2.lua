local vec2 = require "math.vector.vec2"

local ffi = require "ffi"

local istype, new = ffi.istype, ffi.new

ffi.cdef[[
    typedef struct{
        vec2 origin, direction;
        float tMax;
    } ray2;
]]  

local ray2


local function isnum(v)
    return type(v) == "number"
end

local function isray(r)
    return istype("ray2", r)
end

local mt = {}
local mti = {
    get = function(r, t)
        return r.origin + r.direction * t * r.tMax
    end,

}

mt.__index = mti

ray2 = ffi.metatype("ray2", mt)

return ray2