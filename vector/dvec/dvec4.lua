local ffi = require "ffi";

local sqrt, min, max, ceil, floor, abs, exp, log = math.sqrt, math.min, math.max, math.ceil, math.floor, math.abs, math.exp, math.log

ffi.cdef[[
    typedef struct{
        double x, y, z, w;
    } dvec4;
]]

local EPSILON = 0.000001;

local function exactEqual(a, b)
    return abs(a - b) <= EPSILON*max(1.0, max(abs(a), abs(b)))
end

local function assertParams(act, method, param, msg)
    assert(act, "dvec4."..method..": parameter \""..param.."\" "..msg)
end

local dvec4 = {}
setmetatable(dvec4, dvec4)

ffi.metatype("dvec4", dvec4)

local function isnum(v)
    return type(v) == "number"
end

local function isvec(v)
    return ffi.istype("dvec4", v)
end

function dvec4.isZero(v) 
    assertParams(isvec(v), "isZero", "v", "is not a dvec4")
    return v.x == 0 and v.y == 0 and v.z == 0 and v.w == 0
end

function dvec4.clone(v)
    assertParams(isvec(v), "clone", "v", "is not a dvec4")
    return dvec4(v.x, v.y, v.z)
end

function dvec4.assign(a, b)
    assertParams(isvec(a), "assign", "a", "is not a dvec4")
    if(isvec(b)) then
        a.x = b.x
        a.y = b.y
        a.z = b.z
        a.w = b.w
    elseif(isnum(b)) then
        a.x = b
        a.y = b
        a.z = b
        a.w = b
    else 
        assertParams(false, "assign", "b", "is neither a number nor a dvec4")
    end
end 

function dvec4.compare(a, b, comp)
    local v = dvec4()
    local ia = isvec(a)
    local ib = isvec(b)
    local in1 = isnum(a)
    local in2 = isnum(b)
    assertParams(ia or in1, "compare", "a", "is neither a number nor a dvec4")
    assertParams(ib or in2, "compare", "b", "is neither a number nor a dvec4")
    assertParams(type(comp) == "function", "compare", "comp", "is not a function")
    assertParams(isnum(comp(0, 0)), "compare", "comp", "must return a number")
    if(in1 and in2) then return comp(a, b) end
    if ia then
        if in2 then
            v.x = comp(a.x, b)
            v.y = comp(a.y, b)
            v.z = comp(a.z, b)
            v.w = comp(a.w, b)
        elseif ib then
            v.x = comp(a.x, b.x)
            v.y = comp(a.y, b.y)
            v.z = comp(a.z, b.z)
            v.w = comp(a.w, b.w)
        end
    elseif ib and in1 then
        v.x = comp(a, b.x)
        v.y = comp(a, b.y)
        v.z = comp(a, b.z)
        v.w = comp(a, b.w)
    end 
    return v
end

local function add(a, b) return a + b end
local function sub(a, b) return a - b end 
local function mul(a, b) return a * b end
local function div(a, b) return a / b end
local function pow(a, b) return a ^ b end

function dvec4.__add(a, b) 
    assertParams(isvec(a) or isnum(a), "__add", "a", "is neither a number nor a dvec4")
    assertParams(isvec(b) or isnum(b), "__add", "b", "is neither a number nor a dvec4")
    return dvec4.compare(a, b, add) 
end

function dvec4.__sub(a, b) 
    assertParams(isvec(a) or isnum(a), "__sub", "a", "is neither a number nor a dvec4")
    assertParams(isvec(b) or isnum(b), "__sub", "b", "is neither a number nor a dvec4")
    return dvec4.compare(a, b, sub) 
end

function dvec4.__mul(a, b)
    assertParams(isvec(a) or isnum(a), "__mul", "a", "is neither a number nor a dvec4")
    assertParams(isvec(b) or isnum(b), "__mul", "b", "is neither a number nor a dvec4")
    return dvec4.compare(a, b, mul) 
end

function dvec4.__div(a, b) 
    assertParams(isvec(a) or isnum(a), "__div", "a", "is neither a number nor a dvec4")
    assertParams(isvec(b) or isnum(b), "__div", "b", "is neither a number nor a dvec4")
    assertParams(not(isvec(b) and dvec4.isZero(b)), "__div", "b", "is a zero vector")
    assertParams(not(isnum(b) and exactEqual(b, 0)), "__div", "b", "is a zero")
    return dvec4.compare(a, b, div) 
end

function dvec4.__pow(a, b)
    assertParams(isvec(a), "__pow", "a", "is not a dvec4")
    assertParams(isvec(b), "__pow", "b", "is not a dvec4")
    return dvec4.compare(a, b, mul) 
end 

function dvec4.__unm(v)
    assertParams(isvec(v), "__unm", "v", "is not a dvec4") 
    return dvec4(-v.x, -v.y, -v.z, -v.w) 
end

function dvec4.__eq(a, b)
    assertParams(isvec(a), "__eq", "a", "is not a dvec4")
    assertParams(isvec(b), "__eq", "b", "is not a dvec4")
    
    return exactEqual(a.x, b.x) and exactEqual(a.y, b.y) and exactEqual(a.w, b.w)
end

function dvec4.__tostring(v)
    assertParams(isvec(v), "__tostring", "v", "is not a dvec4")
    return "dvec4("..v.x..", "..v.y..", "..v.z..", "..v.w..")"
end

function dvec4.dot(a, b)
    assertParams(isvec(a), "dot", "a", "is not a dvec4")
    assertParams(isvec(b), "dot", "b", "is not a dvec4")
    if(dvec4.isZero(a) or dvec4.isZero(b)) then return 0 end
    return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
end 

function dvec4.length2(v)
    assertParams(isvec(v), "length2", "v", "is not a dvec4")
    if(dvec4.isZero(v)) then return 0 end
    return v.x*v.x + v.y*v.y + v.z*v.z + v.w*v.w
end

function dvec4.length(v)
    assertParams(isvec(v), "length", "v", "is not a dvec4")
    if(dvec4.isZero(v)) then return 0 end
    return sqrt(dvec4.length2(v))
end

function dvec4.distance2(a, b)
    assertParams(isvec(a), "distance2", "a", "is not a dvec4")
    assertParams(isvec(b), "distance2", "b", "is not a dvec4")
    return dvec4.length2(a - b)
end

function dvec4.distance(a, b)
    assertParams(isvec(a), "distance", "a", "is not a dvec4")
    assertParams(isvec(b), "distance", "b", "is not a dvec4")
    return dvec4.length(a - b)
end

function dvec4.normalize(v)
    assertParams(isvec(v), "normalize", "v", "is not a dvec4")
    local nv = dvec4.clone(v)
    if(not dvec4.isZero(v)) then
        nv = v/dvec4.length(v)
    end
    return nv
end 

function dvec4.floor(v)
    assertParams(isvec(v), "floor", "v", "is not a dvec4")
    return dvec4(floor(v.x), floor(v.y), floor(v.z), floor(v.w))
end

function dvec4.ceil(v)
    assertParams(isvec(v), "ceil", "v", "is not a dvec4")
    return dvec4(ceil(v.x), ceil(v.y), ceil(v.z), ceil(v.w))
end

function dvec4.round(v)
    assertParams(isvec(v), "round", "v", "is not a dvec4")
    return dvec4.floor(v + 0.5)
end

function dvec4.fract(v)
    assertParams(isvec(v), "fract", "v", "is not a dvec4")
    return v - dvec4.floor(v)
end

function dvec4.abs(v)
    assertParams(isvec(v), "abs", "v", "is not a dvec4")
    return dvec4(abs(v.x), abs(v.y), abs(v.z), abs(v.w))
end

local function eq(a, b) return exactEqual(a, b) and 1 or 0 end
local function ne(a, b) return exactEqual(a, b) and 0 or 1 end
local function lt(a, b) return a < b and 1 or 0 end
local function gt(a, b) return a > b and 1 or 0 end
local function le(a, b) return lt(a, b) or eq(a, b) end
local function ge(a, b) return gt(a, b) or eq(a, b) end

function dvec4.eq(a, b)
    assertParams(isvec(a), "eq", "a", "is not a dvec4")
    assertParams(isvec(b) or isnum(b), "eq", "b", "is neither a number nor a dvec4")
    return dvec4.compare(a, b, eq)
end

function dvec4.ne(a, b)
    assertParams(isvec(a), "ne", "a", "is not a dvec4")
    assertParams(isvec(b) or isnum(b), "ne", "b", "is neither a number nor a dvec4")
    return dvec4.compare(a, b, ne)
end

function dvec4.lt(a, b)
    assertParams(isvec(a), "lt", "a", "is not a dvec4")
    assertParams(isvec(b) or isnum(b), "lt", "b", "is neither a number nor a dvec4")
    return dvec4.compare(a, b, lt)
end

function dvec4.gt(a, b)
    assertParams(isvec(a), "gt", "a", "is not a dvec4")
    assertParams(isvec(b) or isnum(b), "gt", "b", "is neither a number nor a dvec4")
    return dvec4.compare(a, b, gt)
end

function dvec4.le(a, b)
    assertParams(isvec(a), "le", "a", "is not a dvec4")
    assertParams(isvec(b) or isnum(b), "le", "b", "is neither a number nor a dvec4")
    return dvec4.compare(a, b, le)
end

function dvec4.ge(a, b)
    assertParams(isvec(a), "ge", "a", "is not a dvec4")
    assertParams(isvec(b) or isnum(b), "ge", "b", "is neither a number nor a dvec4")
    return dvec4.compare(a, b, ge)
end


local function sgn(v)
    if(v < 0) then 
        return -1
    elseif(v > 0) then 
        return 1 
    end
    return 0
end 

function dvec4.sgn(v)
    assertParams(isvec(v), "sgn", "v", "is not a dvec4")
    return dvec4(sgn(v.x), sgn(v.y), sgn(v.z), sgn(v.w))
end

function dvec4.exp(v)
    assertParams(isvec(v), "exp", "v", "is not a dvec4")
    return dvec4(exp(v.x), exp(v.y), exp(v.z), exp(v.w))
end

function dvec4.log(v)
    assertParams(isvec(v), "log", "v", "is not a dvec4")
    return dvec4(log(v.x), log(v.y), log(v.z), log(v.w))
end

function dvec4.sqrt(v)
    assertParams(isvec(v), "sqrt", "v", "is not a dvec4")
    return dvec4(sqrt(v.x), sqrt(v.y), sqrt(v.z), sqrt(v.w))
end

function dvec4.min(a, b)
    assertParams(isvec(a) or isnum(a), "min", "a", "is neither a number nor a dvec4")
    assertParams(isvec(b) or isnum(b), "min", "b", "is neither a number nor a dvec4")
    return dvec4.compare(a, b, min) 
end

function dvec4.max(a, b) 
    assertParams(isvec(a) or isnum(a), "max", "a", "is neither a number nor a dvec4")
    assertParams(isvec(b) or isnum(b), "max", "b", "is neither a number nor a dvec4")
    return dvec4.compare(a, b, max) 
end 

function dvec4.clamp(a, b, c)
    assertParams(isvec(a) or isnum(a), "clamp", "a", "is neither a number nor a dvec4")
    assertParams(isvec(b) or isnum(b), "clamp", "b", "is neither a number nor a dvec4")
    assertParams(isvec(c) or isnum(c), "clamp", "c", "is neither a number nor a dvec4")
    return dvec4.max(a, dvec4.min(b, c)) 
end

function dvec4.mix(a, b, t) 
    assertParams(isvec(a) or isnum(a), "mix", "a", "is neither a number nor a dvec4")
    assertParams(isvec(b) or isnum(b), "mix", "b", "is neither a number nor a dvec4")
    assertParams(isvec(t) or isnum(t), "mix", "t", "is neither a number nor a dvec4")

    return a + (b - a) * t 
end

function dvec4.smoothstep(edge0, edge1, x)
    assertParams(isvec(edge0) or isnum(edge0), "smoothstep", "edge0", "is neither a number nor a dvec4")
    assertParams(isvec(edge1) or isnum(edge1), "smoothstep", "edge1", "is neither a number nor a dvec4")
    assertParams(isvec(x) or isnum(x), "smoothstep", "x", "is neither a number nor a dvec4")

    local t = dvec4.clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)
end

local function stepcomp(a, b)
    if(a < b) then
        return 0
    end
    return 1
end 

function dvec4.step(edge, x)
    assertParams(isvec(edge) or isnum(edge), "step", "edge", "is neither a number nor a dvec4")
    assertParams(isvec(x) or isnum(x), "step", "x", "is neither a number nor a dvec4")
    return dvec4.compare(edge, x, stepcomp)
end

function dvec4.reflect(i, n)
    assertParams(isvec(i), "reflect", "i", "is not a dvec4")
    assertParams(isvec(n), "reflect", "n", "is not a dvec4")
    n = dvec4.normalize(n)
    return i - 2.0*dvec4.dot(n, i)*n;
end

function dvec4.refract(i, n, eta)
    assertParams(isvec(i), "reflect", "i", "is not a dvec4")
    assertParams(isvec(n), "reflect", "n", "is not a dvec4")
    assertParams(isnum(eta), "refract", "eta", "is not a number")
    i = dvec4.normalize(i)
    n = dvec4.normalize(n)
    local d = dvec4.dot(n, i)
    local k = 1.0 - eta*eta*(1.0 - d*d)
    if(k < 0) then
        return dvec4()
    end
    return eta * i - (eta * d + sqrt(k)) * n
end

function dvec4.__call(t, x, y, z, w)
    local iv = isvec(x)
    assertParams(isnum(x) or iv or x == nil, "__call", "x", " is neither a number, nor a dvec4.")
    assertParams(isnum(y) or y == nil, "__call", "y", "is not a number.")
    assertParams(isnum(z) or z == nil, "__call", "z", "is not a number.")
    assertParams(isnum(w) or w == nil, "__call", "w", "is not a number.")
    if(iv) then return ffi.new("dvec4", x.x, x.y, x.z, x.w) end
    return ffi.new("dvec4", x or 0, y or 0, z or 0, w or 0)
end

function dvec4.is(v)
    return isvec(v)
end

function dvec4.split(v)
    assertParams(isvec(v), "split", "v", "is not a dvec4")
    return v.x, v.y, v.z, v.w
end

return dvec4
