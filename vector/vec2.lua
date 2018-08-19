local ffi = require "ffi";

local C, istype, new = ffi.C, ffi.istype, ffi.new 

local sqrt, min, max, ceil, floor, abs, exp, log = math.sqrt, math.min, math.max, math.ceil, math.floor, math.abs, math.exp, math.log

ffi.cdef[[
    typedef struct{
        float x, y;
    } vec2;
]]

local vec2

local EPSILON = 0.000001;

local function exactEqual(a, b)
    return abs(a - b) <= EPSILON*max(1.0, max(abs(a), abs(b)))
end

local function isnum(v)
    return type(v) == "number"
end

local function isvec(v)
    return istype("vec2", v)
end

local function v__isZero(v) 
    return exactEqual(v.x, 0) and exactEqual(v.y, 0)
end

local function v__clone(v)
    return vec2(v.x, v.y)
end

local function v__assign(a, b)
    if(isvec(b)) then
        a.x = b.x
        a.y = b.y
    elseif(isnum(b)) then
        a.x = b
        a.y = b
    end
end 

local function v__compare(a, b, comp)
    local v = vec2()
    local ia = isvec(a)
    local ib = isvec(b)
    local in1 = isnum(a)
    local in2 = isnum(b)
    if(in1 and in2) then return comp(a, b) end
    if ia then
        if in2 then
            v.x = comp(a.x, b)
            v.y = comp(a.y, b)
        elseif ib then
            v.x = comp(a.x, b.x)
            v.y = comp(a.y, b.y)
        end
    elseif ib and in1 then
        v.x = comp(a, b.x)
        v.y = comp(a, b.y)
    end 
    return v
end

local function add(a, b) return a + b end
local function sub(a, b) return a - b end 
local function mul(a, b) return a * b end
local function div(a, b) return a / b end
local function pow(a, b) return a ^ b end

local function v__add(a, b) 
    return v__compare(a, b, add) 
end

local function v__sub(a, b) 
    return v__compare(a, b, sub) 
end

local function v__mul(a, b)
    return v__compare(a, b, mul) 
end

local function v__div(a, b) 
    return v__compare(a, b, div) 
end

local function v__pow(a, b)
    return v__compare(a, b, pow) 
end 

local function v__unm(v)
    return vec2(-v.x, -v.y) 
end

local function v____eq(a, b)
    return exactEqual(a.x, b.x) and exactEqual(a.y, b.y)
end

local function v____lt(a, b)
    return a.x < b.x and a.y < b.y
end

local function v____le(a, b)
    return a.x <= b.x and a.y <= b.y
end

local function v__tostring(v)
    return "vec2("..v.x..", "..v.y..")"
end

local function v__dot(a, b)
    if(v__isZero(a) or v__isZero(b)) then return 0 end
    return a.x * b.x + a.y * b.y
end  

local function v__length2(v)
    if(v__isZero(v)) then return 0 end
    return v.x*v.x + v.y*v.y
end

local function v__length(v)
    if(v__isZero(v)) then return 0 end
    return sqrt(v__length2(v))
end

local function v__distance2(a, b)
    return v__length2(a - b)
end

local function v__distance(a, b)
    return v__length(a - b)
end

local function v__normalize(v)
    local nv = vec2(v.x, v.y)
    if(not v__isZero(v)) then
        nv = v / v__length(v);
    end
    return nv
end 

local function v__floor(v)
    return vec2(floor(v.x), floor(v.y))
end

local function v__ceil(v)
    return vec2(ceil(v.x), ceil(v.y))
end

local function v__round(v)
    return v__floor(v + 0.5)
end

local function v__fract(v)
    return v - v__floor(v)
end

local function v__abs(v)
    return vec2(abs(v.x), abs(v.y))
end

local function eq(a, b) return exactEqual(a, b) and 1 or 0 end
local function ne(a, b) return exactEqual(a, b) and 0 or 1 end
local function lt(a, b) return a < b and 1 or 0 end
local function gt(a, b) return a > b and 1 or 0 end
local function le(a, b) return lt(a, b) or eq(a, b) end
local function ge(a, b) return gt(a, b) or eq(a, b) end

local function v__eq(a, b)
    return v__compare(a, b, eq)
end

local function v__ne(a, b)
    return v__compare(a, b, ne)
end

local function v__lt(a, b)
    return v__compare(a, b, lt)
end

local function v__gt(a, b)
    return v__compare(a, b, gt)
end

local function v__le(a, b)
    return v__compare(a, b, le)
end

local function v__ge(a, b)
    return v__compare(a, b, ge)
end


local function sgn(v)
    if(v < 0) then 
        return -1
    elseif(v > 0) then 
        return 1 
    end
    return 0
end 

local function v__sgn(v)
    return vec2(sgn(v.x), sgn(v.y))
end

local function v__exp(v)
    return vec2(exp(v.x), exp(v.y))
end

local function v__log(v)
    return vec2(log(v.x), log(v.y))
end

local function v__sqrt(v)
    return vec2(sqrt(v.x), sqrt(v.y))
end

local function v__min(a, b)
    return v__compare(a, b, min) 
end

local function v__max(a, b) 
    return v__compare(a, b, max) 
end 

local function v__clamp(a, b, c)
    return v__max(a, v__min(b, c)) 
end

local function v__mix(a, b, t) 
    return a + (b - a) * t 
end

local function v__smoothstep(edge0, edge1, x)
    local t = v__clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)
end

local function stepcomp(a, b)
    if(a < b) then
        return 0
    end
    return 1
end 

local function v__step(edge, x)
    return v__compare(edge, x, stepcomp)
end

local function v__reflect(i, n)
    n = v__normalize(n)
    return i - 2.0*v__dot(n, i)*n;
end

local function v__refract(I, N, eta)
    I = v__normalize(I)
    N = v__normalize(N)
    local cosi = clamp(-1., 1., dot(I, N))
    local etai, etat = 1., ior
    local n = N
    if (cosi < 0.) then
        cosi = -cosi
    else
        etai, etat = etat, etai
        n= -N
    end
    local eta = etai / etat
    local k = 1. - eta * eta * (1. - cosi * cosi)
    if(k < 0.) then 
        return vec2()
    end
    
    return eta * I + (eta * cosi - sqrt(k)) * n
end

local function v__split(v)
    return v.x, v.y
end

local function v__fromPolar(radius, theta)
    return vec2(cos(theta)*radius, sin(theta)*radius)
end

local mt = {}
local mti = {}

mti.isZero = v__isZero
mti.clone = v__clone
mti.assign = v__assign
mti.compare = v__compare

-- Meta methods
mt.__add = v__add
mt.__sub = v__sub
mt.__mul = v__mul
mt.__div = v__div
mt.__pow = v__pow
mt.__unm = v__unm
mt.__eq = v____eq
mt.__lt = v____lt
mt.__le = v____le
mt.__tostring = v__tostring

-- single params
mti.floor = v__floor
mti.ceil = v__ceil
mti.round = v__round
mti.fract = v__fract
mti.abs = v__abs
mti.sgn = v__sgn
mti.length2 = v__length2
mti.length = v__length
mti.normalize = v__normalize
mti.exp = v__exp
mti.log = v__log
mti.sqrt = v__sqrt


-- double params
mti.dot = v__dot
mti.distance2 = v__distance2
mti.distance = v__distance
mti.min = v__min
mti.max = v__max

-- triple params
mti.clamp = v__clamp 
mti.mix = v__mix
mti.smoothstep = v__smoothstep
mti.step = v__step

-- light
mti.reflect = v__reflect
mti.refract = v__refract

-- component-based boolean comparison
mti.eq = v__eq
mti.lt = v__lt
mti.le = v__le
mti.gt = v__gt
mti.ge = v__ge
mti.ne = v__ne

-- other
mti.fromPolar = v__fromPolar
mti.split = v__split


mt.__index = mti
vec2 = ffi.metatype("vec2", mt)
return vec2
