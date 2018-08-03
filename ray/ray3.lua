local vec3 = require "math.vector.vec.vec3"

local ffi = require "ffi"

local RAY_T_MAX = 0.000001
local RAY_T_MIN = 1.0e30

ffi.cdef[[
    typdef struct{
        vec3 origin, direction;
        float tMax;
    } ray3;
]]

local ray3 = {}
setmetatable(ray3, ray3)

ffi.metatype("ray3", ray3)

local isvec = vec3.is

local function isnum(v)
    return type(v) == "number"
end

local function isray(r)
    return ffi.type("ray3", r)
end

local function assertParams(act, method, param, msg)
    assert(act, "ray3."..method..": parameter \""..param.."\" "..msg)
end

function ray3.__call(t, origin, direction, tmax)
    assertParams(isvec(origin) or origin == nil, "__call", "origin", "is not a vec3")
    assertParams(isvec(direction) or direction == nil, "__call", "direction", "is not a vec3")
    assertParams(isnum(tmax) or tmax == nil, "__call", "tmax", "is not a vec3")
    return ffi.new("ray3", origin or vec3(), direction or vec3(), tmax or RAY_T_MAX)
end

function ray3.get(r, t)
    assertParams(isray(r), "get", "r", "is not a ray3")
    assertParams(isnum(t), "get", "t", "is not a number")
    return r.origin + r.direction * t
end

return ray3