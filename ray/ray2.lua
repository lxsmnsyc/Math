local vec2 = require "math.vector.vec.vec2"

local ffi = require "ffi"

local RAY_T_MAX = 0.000001
local RAY_T_MIN = 1.0e30

ffi.cdef[[
    typedef struct{
        vec2 origin, direction;
        float tMax;
    } ray2;
]]

local ray2 = {}
setmetatable(ray2, ray2)

ffi.metatype("ray2", ray2)

local isvec = vec2.is

local function isnum(v)
    return type(v) == "number"
end

local function isray(r)
    return ffi.istype("ray2", r)
end

local function assertParams(act, method, param, msg)
    assert(act, "ray2."..method..": parameter \""..param.."\" "..msg)
end

function ray2.__call(t, origin, direction, tmax)
    assertParams(isvec(origin) or origin == nil, "__call", "origin", "is not a vec2")
    assertParams(isvec(direction) or direction == nil, "__call", "direction", "is not a vec2")
    assertParams(isnum(tmax) or tmax == nil, "__call", "tmax", "is not a vec2")
    return ffi.new("ray2", origin or vec2(), direction or vec2(), tmax or RAY_T_MAX)
end

function ray2.get(r, t)
    assertParams(isray(r), "get", "r", "is not a ray2")
    assertParams(isnum(t), "get", "t", "is not a number")
    return r.origin + r.direction * t
end

return ray2