local ffi = require "ffi";

local sqrt, min, max, ceil, floor, abs, exp, log = math.sqrt, math.min, math.max, math.ceil, math.floor, math.abs, math.exp, math.log

ffi.cdef[[
    typedef struct{
        double x, y, z;
    } dvec3;
]]

local function assertParams(act, method, param, msg)
    assert(act, "dvec3."..method..": parameter \""..param.."\" "..msg)
end

local dvec3 = {}
setmetatable(dvec3, dvec3)

ffi.metatype("dvec3", dvec3)

local EPSILON = 0.000001;

local function exactEqual(a, b)
    return abs(a - b) <= EPSILON*max(1.0, max(abs(a), abs(b)))
end

local function isnum(v)
    return type(v) == "number"
end

local function isvec(v)
    return ffi.istype("dvec3", v)
end

function dvec3.isZero(v) 
    assertParams(isvec(v), "isZero", "v", "is not a dvec3")
    return v.x == 0 and v.y == 0 and v.z == 0
end

function dvec3.clone(v)
    assertParams(isvec(v), "clone", "v", "is not a dvec3")
    return dvec3(v.x, v.y, v.z)
end

function dvec3.assign(a, b)
    assertParams(isvec(a), "assign", "a", "is not a dvec3")
    if(isvec(b)) then
        a.x = b.x
        a.y = b.y
        a.z = b.z
    elseif(isnum(b)) then
        a.x = b
        a.y = b
        a.z = b
    else 
        assertParams(false, "assign", "b", "is neither a number nor a dvec3")
    end
end 

function dvec3.compare(a, b, comp)
    local v = dvec3()
    local ia = isvec(a)
    local ib = isvec(b)
    local in1 = isnum(a)
    local in2 = isnum(b)
    assertParams(ia or in1, "compare", "a", "is neither a number nor a dvec3")
    assertParams(ib or in2, "compare", "b", "is neither a number nor a dvec3")
    assertParams(type(comp) == "function", "compare", "comp", "is not a function")
    assertParams(isnum(comp(0, 0)), "compare", "comp", "must return a number")
    if(in1 and in2) then return comp(a, b) end
    if ia then
        if in2 then
            v.x = comp(a.x, b)
            v.y = comp(a.y, b)
            v.z = comp(a.z, b)
        elseif ib then
            v.x = comp(a.x, b.x)
            v.y = comp(a.y, b.y)
            v.z = comp(a.z, b.z)
        end
    elseif ib and in1 then
        v.x = comp(a, b.x)
        v.y = comp(a, b.y)
        v.z = comp(a, b.z)
    end 
    return v
end

local function add(a, b) return a + b end
local function sub(a, b) return a - b end 
local function mul(a, b) return a * b end
local function div(a, b) return a / b end
local function pow(a, b) return a ^ b end

function dvec3.__add(a, b) 
    assertParams(isvec(a) or isnum(a), "__add", "a", "is neither a number nor a dvec3")
    assertParams(isvec(b) or isnum(b), "__add", "b", "is neither a number nor a dvec3")
    return dvec3.compare(a, b, add) 
end

function dvec3.__sub(a, b) 
    assertParams(isvec(a) or isnum(a), "__sub", "a", "is neither a number nor a dvec3")
    assertParams(isvec(b) or isnum(b), "__sub", "b", "is neither a number nor a dvec3")
    return dvec3.compare(a, b, sub) 
end

function dvec3.__mul(a, b)
    assertParams(isvec(a) or isnum(a), "__mul", "a", "is neither a number nor a dvec3")
    assertParams(isvec(b) or isnum(b), "__mul", "b", "is neither a number nor a dvec3")
    return dvec3.compare(a, b, mul) 
end

function dvec3.__div(a, b) 
    assertParams(isvec(a) or isnum(a), "__div", "a", "is neither a number nor a dvec3")
    assertParams(isvec(b) or isnum(b), "__div", "b", "is neither a number nor a dvec3")
    assertParams(not(isvec(b) and dvec3.isZero(b)), "__div", "b", "is a zero vector")
    assertParams(not(isnum(b) and exactEqual(b, 0)), "__div", "b", "is a zero")
    return dvec3.compare(a, b, div) 
end

function dvec3.__pow(a, b)
    assertParams(isvec(a), "__pow", "a", "is not a dvec3")
    assertParams(isvec(b), "__pow", "b", "is not a dvec3")
    return dvec3.compare(a, b, pow) 
end 

function dvec3.__unm(v)
    assertParams(isvec(v), "__unm", "v", "is not a dvec3") 
    return dvec3(-v.x, -v.y, -v.z) 
end

function dvec3.__eq(a, b)
    assertParams(isvec(a), "__eq", "a", "is not a dvec3")
    assertParams(isvec(b), "__eq", "b", "is not a dvec3")
    
    return exactEqual(a.x, b.x) and exactEqual(a.y, b.y) and exactEqual(a.z, b.z)
end

function dvec3.__tostring(v)
    assertParams(isvec(v), "__tostring", "v", "is not a dvec3")
    return "dvec3("..v.x..", "..v.y..", "..v.z..")"
end

function dvec3.dot(a, b)
    assertParams(isvec(a), "dot", "a", "is not a dvec3")
    assertParams(isvec(b), "dot", "b", "is not a dvec3")
    if(dvec3.isZero(a) or dvec3.isZero(b)) then return 0 end
    return a.x * b.x + a.y * b.y + a.z * b.z
end 

function dvec3.cross(a, b)
    assertParams(isvec(a), "cross", "a", "is not a dvec3")
    assertParams(isvec(b), "cross", "b", "is not a dvec3")
    if(dvec3.isZero(a) or dvec3.isZero(b)) then return dvec3() end
    return dvec3(
        a.y*b.z - a.z*b.y,
        a.z*b.x - a.x*b.z,
        a.x*b.y - a.y*b.x
    )
end 

function dvec3.length2(v)
    assertParams(isvec(v), "length2", "v", "is not a dvec3")
    if(dvec3.isZero(v)) then return 0 end
    return v.x*v.x + v.y*v.y + v.z*v.z
end

function dvec3.length(v)
    assertParams(isvec(v), "length", "v", "is not a dvec3")
    if(dvec3.isZero(v)) then return 0 end
    return sqrt(dvec3.length2(v))
end

function dvec3.distance2(a, b)
    assertParams(isvec(a), "distance2", "a", "is not a dvec3")
    assertParams(isvec(b), "distance2", "b", "is not a dvec3")
    return dvec3.length2(a - b)
end

function dvec3.distance(a, b)
    assertParams(isvec(a), "distance", "a", "is not a dvec3")
    assertParams(isvec(b), "distance", "b", "is not a dvec3")
    return dvec3.length(a - b)
end

function dvec3.normalize(v)
    assertParams(isvec(v), "normalize", "v", "is not a dvec3")
    local nv = dvec3.clone(v)
    if(not dvec3.isZero(v)) then
        nv = v/dvec3.length(v)
    end
    return nv
end 

function dvec3.floor(v)
    assertParams(isvec(v), "floor", "v", "is not a dvec3")
    return dvec3(floor(v.x), floor(v.y), floor(v.z))
end

function dvec3.ceil(v)
    assertParams(isvec(v), "ceil", "v", "is not a dvec3")
    return dvec3(ceil(v.x), ceil(v.y), ceil(v.z))
end

function dvec3.round(v)
    assertParams(isvec(v), "round", "v", "is not a dvec3")
    return dvec3.floor(v + 0.5)
end

function dvec3.fract(v)
    assertParams(isvec(v), "fract", "v", "is not a dvec3")
    return v - dvec3.floor(v)
end

function dvec3.abs(v)
    assertParams(isvec(v), "abs", "v", "is not a dvec3")
    return dvec3(abs(v.x), abs(v.y), abs(v.z))
end

local function eq(a, b) return exactEqual(a, b) and 1 or 0 end
local function ne(a, b) return exactEqual(a, b) and 0 or 1 end
local function lt(a, b) return a < b and 1 or 0 end
local function gt(a, b) return a > b and 1 or 0 end
local function le(a, b) return lt(a, b) or eq(a, b) end
local function ge(a, b) return gt(a, b) or eq(a, b) end

function dvec3.eq(a, b)
    assertParams(isvec(a), "eq", "a", "is not a dvec3")
    assertParams(isvec(b) or isnum(b), "eq", "b", "is neither a number nor a dvec3")
    return dvec3.compare(a, b, eq)
end

function dvec3.ne(a, b)
    assertParams(isvec(a), "ne", "a", "is not a dvec3")
    assertParams(isvec(b) or isnum(b), "ne", "b", "is neither a number nor a dvec3")
    return dvec3.compare(a, b, ne)
end

function dvec3.lt(a, b)
    assertParams(isvec(a), "lt", "a", "is not a dvec3")
    assertParams(isvec(b) or isnum(b), "lt", "b", "is neither a number nor a dvec3")
    return dvec3.compare(a, b, lt)
end

function dvec3.gt(a, b)
    assertParams(isvec(a), "gt", "a", "is not a dvec3")
    assertParams(isvec(b) or isnum(b), "gt", "b", "is neither a number nor a dvec3")
    return dvec3.compare(a, b, gt)
end

function dvec3.le(a, b)
    assertParams(isvec(a), "le", "a", "is not a dvec3")
    assertParams(isvec(b) or isnum(b), "le", "b", "is neither a number nor a dvec3")
    return dvec3.compare(a, b, le)
end

function dvec3.ge(a, b)
    assertParams(isvec(a), "ge", "a", "is not a dvec3")
    assertParams(isvec(b) or isnum(b), "ge", "b", "is neither a number nor a dvec3")
    return dvec3.compare(a, b, ge)
end


local function sgn(v)
    if(v < 0) then 
        return -1
    elseif(v > 0) then 
        return 1 
    end
    return 0
end 

function dvec3.sgn(v)
    assertParams(isvec(v), "sgn", "v", "is not a dvec3")
    return dvec3(sgn(v.x), sgn(v.y), sgn(v.z))
end

function dvec3.exp(v)
    assertParams(isvec(v), "exp", "v", "is not a dvec3")
    return dvec3(exp(v.x), exp(v.y), exp(v.z))
end

function dvec3.log(v)
    assertParams(isvec(v), "log", "v", "is not a dvec3")
    return dvec3(log(v.x), log(v.y), log(v.z))
end

function dvec3.sqrt(v)
    assertParams(isvec(v), "sqrt", "v", "is not a dvec3")
    return dvec3(sqrt(v.x), sqrt(v.y), sqrt(v.z))
end

function dvec3.min(a, b)
    assertParams(isvec(a) or isnum(a), "min", "a", "is neither a number nor a dvec3")
    assertParams(isvec(b) or isnum(b), "min", "b", "is neither a number nor a dvec3")
    return dvec3.compare(a, b, min) 
end

function dvec3.max(a, b) 
    assertParams(isvec(a) or isnum(a), "max", "a", "is neither a number nor a dvec3")
    assertParams(isvec(b) or isnum(b), "max", "b", "is neither a number nor a dvec3")
    return dvec3.compare(a, b, max) 
end 

function dvec3.clamp(a, b, c)
    assertParams(isvec(a) or isnum(a), "clamp", "a", "is neither a number nor a dvec3")
    assertParams(isvec(b) or isnum(b), "clamp", "b", "is neither a number nor a dvec3")
    assertParams(isvec(c) or isnum(c), "clamp", "c", "is neither a number nor a dvec3")
    return dvec3.max(a, dvec3.min(b, c)) 
end

function dvec3.mix(a, b, t) 
    assertParams(isvec(a) or isnum(a), "mix", "a", "is neither a number nor a dvec3")
    assertParams(isvec(b) or isnum(b), "mix", "b", "is neither a number nor a dvec3")
    assertParams(isvec(t) or isnum(t), "mix", "t", "is neither a number nor a dvec3")

    return a + (b - a) * t 
end

function dvec3.smoothstep(edge0, edge1, x)
    assertParams(isvec(edge0) or isnum(edge0), "smoothstep", "edge0", "is neither a number nor a dvec3")
    assertParams(isvec(edge1) or isnum(edge1), "smoothstep", "edge1", "is neither a number nor a dvec3")
    assertParams(isvec(x) or isnum(x), "smoothstep", "x", "is neither a number nor a dvec3")

    local t = dvec3.clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)
end

local function stepcomp(a, b)
    if(a < b) then
        return 0
    end
    return 1
end 

function dvec3.step(edge, x)
    assertParams(isvec(edge) or isnum(edge), "step", "edge", "is neither a number nor a dvec3")
    assertParams(isvec(x) or isnum(x), "step", "x", "is neither a number nor a dvec3")
    return dvec3.compare(edge, x, stepcomp)
end

function dvec3.reflect(i, n)
    assertParams(isvec(i), "reflect", "i", "is not a dvec3")
    assertParams(isvec(n), "reflect", "n", "is not a dvec3")
    n = dvec3.normalize(n)
    return i - 2.0*dvec3.dot(n, i)*n;
end

function dvec3.refract(i, n, eta)
    assertParams(isvec(i), "reflect", "i", "is not a dvec3")
    assertParams(isvec(n), "reflect", "n", "is not a dvec3")
    assertParams(isnum(eta), "refract", "eta", "is not a number")
    i = dvec3.normalize(i)
    n = dvec3.normalize(n)
    local d = dvec3.dot(n, i)
    local k = 1.0 - eta*eta*(1.0 - d*d)
    if(k < 0) then
        return dvec3()
    end
    return eta * i - (eta * d + sqrt(k)) * n
end

function dvec3.__call(t, x, y, z)
    local iv = isvec(x)
    assertParams(isnum(x) or iv or x == nil, "__call", "x", " is neither a number nor a dvec3.")
    assertParams(isnum(y) or y == nil, "__call", "y", "is not a number.")
    assertParams(isnum(z) or z == nil, "__call", "z", "is not a number.")
    if(iv) then return ffi.new("dvec3", x.x, x.y, x.z) end
    return ffi.new("vec4", x or 0, y or 0, z or 0)
end

function dvec3.is(v)
    return isvec(v)
end

function dvec3.split(v)
    assertParams(isvec(v), "split", "v", "is not a dvec3")
    return v.x, v.y, v.z
end

function dvec3.fromSpherical(radius, theta, phi)
    assertParams(isnum(radius), "fromSpherical", "radius", "is not a number")
    assertParams(isnum(theta), "fromSpherical", "theta", "is not a number")
    assertParams(isnum(phi), "fromSpherical", "phi", "is not a number")
    return dvec3(sin(phi)*cos(theta)*radius, sin(phi)*sin(theta)*radius, cos(phi)*radius)
end

return dvec3
