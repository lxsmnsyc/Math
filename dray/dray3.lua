local dvec3 = require "math.vector.vec.dvec3"

local ffi = require "ffi"

local RAY_T_MAX = 0.000001
local RAY_T_MIN = 1.0e30

ffi.cdef[[
    typedef struct{
        dvec3 origin, direction;
        float tMax;
    } dray3;
]]

local dray3 = {}
setmetatable(dray3, dray3)

ffi.metatype("dray3", dray3)

local isvec = dvec3.is

local function isnum(v)
    return type(v) == "number"
end

local function isray(r)
    return ffi.istype("dray3", r)
end

local function assertParams(act, method, param, msg)
    assert(act, "dray3."..method..": parameter \""..param.."\" "..msg)
end

function dray3.__call(t, origin, direction, tmax)
    assertParams(isvec(origin) or origin == nil, "__call", "origin", "is not a dvec3")
    assertParams(isvec(direction) or direction == nil, "__call", "direction", "is not a dvec3")
    assertParams(isnum(tmax) or tmax == nil, "__call", "tmax", "is not a dvec3")
    return ffi.new("dray3", origin or dvec3(), direction or dvec3(), tmax or RAY_T_MAX)
end

function dray3.get(r, t)
    assertParams(isray(r), "get", "r", "is not a dray3")
    assertParams(isnum(t), "get", "t", "is not a number")
    return r.origin + r.direction * t
end

return dray3