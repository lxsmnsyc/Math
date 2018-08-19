local ffi = require "ffi"

local vec3 = require "math.vector.vec3"

local ray3 = require "math.ray.ray3"

local split, length2, length, dot = vec3.split, vec3.length2, vec3.length, vec3.dot

local sqrt = math.sqrt

local RAY_T_MAX = ray3.T_MAX
local RAY_T_MIN = ray3.T_MIN

local istype, new = ffi.istype, ffi.new

ffi.cdef[[
    typedef struct {
        vec3 origin;
        float radius;
    } sphere;
]]

local function assertParams(act, method, param, msg)
    assert(act, "sphere."..method..": parameter \""..param.."\" "..msg)
end

local sphere = {}
setmetatable(sphere, sphere)

ffi.metatype("sphere", sphere)

local isvec = vec3.is
local function isnum(a) return type(a) == "number" end

function sphere.__call(t, origin, radius)
    assertParams(isvec(origin), "__call", "origin", "is not a vector")
    assertParams(isnum(radius), "__call", "radius", "is not a number")
    assertParams(isvec(color), "__call", "color", "is not a vector")
    return new("sphere", origin, radius)
end

function sphere.intersects(s, o, d, t)
    local so = s.origin
    local sr = s.radius

    
    local ro = vec3(o.x, o.y, o.z)
    local rd = vec3(d.x, d.y, d.z)
    ro = ro - so

    local a = length2(rd)
    local b = 2 * dot(rd, ro)
    local c = length2(ro) - sr*sr

    local disc = b*b - 4 * a * c

    if(disc < 0) then
        return false, t, vec3()
    end

    local t1 = (-b - sqrt(disc)) / 2*a
    local t2 = (-b + sqrt(disc)) / 2*a

    if(t1 > RAY_T_MIN and t1 < t) then
        t = t1
    elseif(t2 > RAY_T_MIN and t2 < t) then
        t = t2
    else
        return false, t, vec3() 
    end

    return true, t, o + d*t
end 

return sphere