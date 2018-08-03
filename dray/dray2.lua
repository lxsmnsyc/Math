local dvec2 = require "math.vector.vec.dvec2"

local ffi = require "ffi"

local RAY_T_MAX = 0.000001
local RAY_T_MIN = 1.0e30

ffi.cdef[[
    typdef struct{
        dvec2 origin, direction;
        float tMax;
    } dray2;
]]

local dray2 = {}
setmetatable(dray2, dray2)

ffi.metatype("dray2", dray2)

local isvec = dvec2.is

local function isnum(v)
    return type(v) == "number"
end

local function isray(r)
    return ffi.type("dray2", r)
end

local function assertParams(act, method, param, msg)
    assert(act, "dray2."..method..": parameter \""..param.."\" "..msg)
end

function dray2.__call(t, origin, direction, tmax)
    assertParams(isvec(origin) or origin == nil, "__call", "origin", "is not a dvec2")
    assertParams(isvec(direction) or direction == nil, "__call", "direction", "is not a dvec2")
    assertParams(isnum(tmax) or tmax == nil, "__call", "tmax", "is not a dvec2")
    return ffi.new("dray2", origin or dvec2(), direction or dvec2(), tmax or RAY_T_MAX)
end

function dray2.get(r, t)
    assertParams(isray(r), "get", "r", "is not a dray2")
    assertParams(isnum(t), "get", "t", "is not a number")
    return r.origin + r.direction * t
end

return dray2