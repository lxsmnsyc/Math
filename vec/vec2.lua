local ffi = require "ffi";

local sqrt, min, max, ceil, floor, abs, exp, log = math.sqrt, math.min, math.max, math.ceil, math.floor, math.abs, math.exp, math.log

ffi.cdef[[
    typedef struct{
        float x, y;
    } vec2;
]]

local function assertParams(act, method, param, msg)
    assert(act, "vec2."..method..": parameter \""..param.."\" "..msg)
end

local vec2 = {}
setmetatable(vec2, vec2)

ffi.metatype("vec2", vec2)

local function isnum(v)
    return type(v) == "number"
end

local function isvec(v)
    return ffi.istype("vec2", v)
end

function vec2.isZero(v) 
    assertParams(isvec(v), "isZero", "v", "is not a vec2")
    return v.x == 0 and v.y == 0
end

function vec2.clone(v)
    assertParams(isvec(v), "clone", "v", "is not a vec2")
    return vec2(v.x, v.y)
end

function vec2.assign(a, b)
    assertParams(isvec(a), "assign", "a", "is not a vec2")
    if(isvec(b)) then
        a.x = b.x
        a.y = b.y
    elseif(isnum(b)) then
        a.x = b
        a.y = b
    else 
        assertParams(false, "assign", "b", "is neither a number nor a vec2")
    end
end 

function vec2.compare(a, b, comp)
    local v = vec2()
    local ia = isvec(a)
    local ib = isvec(b)
    local in1 = isnum(a)
    local in2 = isnum(b)
    assertParams(ia or in1, "compare", "a", "is neither a number nor a vec2")
    assertParams(ib or in2, "compare", "b", "is neither a number nor a vec2")
    assertParams(type(comp) == "function", "compare", "comp", "is not a function")
    assertParams(isnum(comp(0, 0)), "compare", "comp", "must return a number")
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

function vec2.__add(a, b) 
    assertParams(isvec(a) or isnum(a), "__add", "a", "is neither a number nor a vec2")
    assertParams(isvec(b) or isnum(b), "__add", "b", "is neither a number nor a vec2")
    return vec2.compare(a, b, add) 
end

function vec2.__sub(a, b) 
    assertParams(isvec(a) or isnum(a), "__sub", "a", "is neither a number nor a vec2")
    assertParams(isvec(b) or isnum(b), "__sub", "b", "is neither a number nor a vec2")
    return vec2.compare(a, b, sub) 
end

function vec2.__mul(a, b)
    assertParams(isvec(a) or isnum(a), "__mul", "a", "is neither a number nor a vec2")
    assertParams(isvec(b) or isnum(b), "__mul", "b", "is neither a number nor a vec2")
    return vec2.compare(a, b, mul) 
end

function vec2.__div(a, b) 
    assertParams(isvec(a) or isnum(a), "__div", "a", "is neither a number nor a vec2")
    assertParams(isvec(b) or isnum(b), "__div", "b", "is neither a number nor a vec2")
    assertParams(not(isvec(b) and vec2.isZero(b)), "__div", "b", "is a zero vector")
    assertParams(not(isnum(b) and b == 0), "__div", "b", "is a zero")
    return vec2.compare(a, b, div) 
end

function vec2.__pow(a, b)
    assertParams(isvec(a), "__pow", "a", "is not a vec2")
    assertParams(isvec(b), "__pow", "b", "is not a vec2")
    return vec2.compare(a, b, mul) 
end 

function vec2.__unm(v)
    assertParams(isvec(v), "__unm", "v", "is not a vec2") 
    return vec2(-v.x, -v.y) 
end

function vec2.__eq(a, b)
    assertParams(isvec(a), "__eq", "a", "is not a vec2")
    assertParams(isvec(b), "__eq", "b", "is not a vec2")
    
    return a.x == b.x and a.y == b.y
end

function vec2.__tostring(v)
    assertParams(isvec(v), "__tostring", "v", "is not a vec2")
    return "vec2("..v.x..", "..v.y..")"
end

function vec2.dot(a, b)
    assertParams(isvec(a), "dot", "a", "is not a vec2")
    assertParams(isvec(b), "dot", "b", "is not a vec2")
    if(vec2.isZero(a) or vec2.isZero(b)) then return 0 end
    return a.x * b.x + a.y * b.y
end  

function vec2.length2(v)
    assertParams(isvec(v), "length2", "v", "is not a vec2")
    if(vec2.isZero(v)) then return 0 end
    return v.x*v.x + v.y*v.y
end

function vec2.length(v)
    assertParams(isvec(v), "length", "v", "is not a vec2")
    if(vec2.isZero(v)) then return 0 end
    return sqrt(vec2.length2(v))
end

function vec2.distance2(a, b)
    assertParams(isvec(a), "distance2", "a", "is not a vec2")
    assertParams(isvec(b), "distance2", "b", "is not a vec2")
    return vec2.length2(a - b)
end

function vec2.distance(a, b)
    assertParams(isvec(a), "distance", "a", "is not a vec2")
    assertParams(isvec(b), "distance", "b", "is not a vec2")
    return vec2.length(a - b)
end

function vec2.normalize(v)
    assertParams(isvec(v), "normalize", "v", "is not a vec2")
    local nv = vec2.clone(v)
    if(not vec2.isZero(v)) then
        nv = v / vec2.length(v);
    end
    return nv
end 

function vec2.floor(v)
    assertParams(isvec(v), "floor", "v", "is not a vec2")
    return vec2(floor(v.x), floor(v.y))
end

function vec2.ceil(v)
    assertParams(isvec(v), "ceil", "v", "is not a vec2")
    return vec2(ceil(v.x), ceil(v.y))
end

function vec2.round(v)
    assertParams(isvec(v), "round", "v", "is not a vec2")
    return vec2.floor(v + 0.5)
end

function vec2.fract(v)
    assertParams(isvec(v), "fract", "v", "is not a vec2")
    return v - vec2.floor(v)
end

function vec2.abs(v)
    assertParams(isvec(v), "abs", "v", "is not a vec2")
    return vec2(abs(v.x), abs(v.y))
end

function vec2.eq(a, b)
    assertParams(isvec(a), "eq", "a", "is not a vec2")
    assertParams(isvec(b) or isnum(b), "eq", "b", "is neither a number nor a vec2")
    if(isnum(b)) then
        return vec2(a.x == b and 1 or 0, a.y == b and 1 or 0)
    end
    return vec2(a.x == b.x and 1 or 0, a.y == b.y and 1 or 0)
end

function vec2.ne(a, b)
    assertParams(isvec(a), "ne", "a", "is not a vec2")
    assertParams(isvec(b) or isnum(b), "ne", "b", "is neither a number nor a vec2")
    if(isnum(b)) then
        return vec2(a.x ~= b and 1 or 0, a.y ~= b and 1 or 0)
    end
    return vec2(a.x ~= b.x and 1 or 0, a.y ~= b.y and 1 or 0)
end

function vec2.lt(a, b)
    assertParams(isvec(a), "lt", "a", "is not a vec2")
    assertParams(isvec(b) or isnum(b), "lt", "b", "is neither a number nor a vec2")
    if(isnum(b)) then
        return vec2(a.x < b and 1 or 0, a.y < b and 1 or 0)
    end
    return vec2(a.x < b.x and 1 or 0, a.y < b.y and 1 or 0)
end

function vec2.gt(a, b)
    assertParams(isvec(a), "gt", "a", "is not a vec2")
    assertParams(isvec(b) or isnum(b), "gt", "b", "is neither a number nor a vec2")
    if(isnum(b)) then
        return vec2(a.x > b and 1 or 0, a.y > b and 1 or 0)
    end
    return vec2(a.x > b.x and 1 or 0, a.y > b.y and 1 or 0)
end

function vec2.le(a, b)
    assertParams(isvec(a), "le", "a", "is not a vec2")
    assertParams(isvec(b) or isnum(b), "le", "b", "is neither a number nor a vec2")
    if(isnum(b)) then
        return vec2(a.x <= b and 1 or 0, a.y <= b and 1 or 0)
    end
    return vec2(a.x <= b.x and 1 or 0, a.y <= b.y and 1 or 0)
end

function vec2.ge(a, b)
    assertParams(isvec(a), "ge", "a", "is not a vec2")
    assertParams(isvec(b) or isnum(b), "ge", "b", "is neither a number nor a vec2")
    if(isnum(b)) then
        return vec2(a.x >= b and 1 or 0, a.y >= b and 1 or 0)
    end
    return vec2(a.x >= b.x and 1 or 0, a.y >= b.y and 1 or 0)
end


local function sgn(v)
    if(v < 0) then 
        return -1
    elseif(v > 0) then 
        return 1 
    end
    return 0
end 

function vec2.sgn(v)
    assertParams(isvec(v), "sgn", "v", "is not a vec2")
    return vec2(sgn(v.x), sgn(v.y))
end

function vec2.exp(v)
    assertParams(isvec(v), "exp", "v", "is not a vec2")
    return vec2(exp(v.x), exp(v.y))
end

function vec2.log(v)
    assertParams(isvec(v), "log", "v", "is not a vec2")
    return vec2(log(v.x), log(v.y))
end

function vec2.sqrt(v)
    assertParams(isvec(v), "sqrt", "v", "is not a vec2")
    return vec2(sqrt(v.x), sqrt(v.y))
end

function vec2.min(a, b)
    assertParams(isvec(a) or isnum(a), "min", "a", "is neither a number nor a vec2")
    assertParams(isvec(b) or isnum(b), "min", "b", "is neither a number nor a vec2")
    return vec2.compare(a, b, min) 
end

function vec2.max(a, b) 
    assertParams(isvec(a) or isnum(a), "max", "a", "is neither a number nor a vec2")
    assertParams(isvec(b) or isnum(b), "max", "b", "is neither a number nor a vec2")
    return vec2.compare(a, b, max) 
end 

function vec2.clamp(a, b, c)
    assertParams(isvec(a) or isnum(a), "clamp", "a", "is neither a number nor a vec2")
    assertParams(isvec(b) or isnum(b), "clamp", "b", "is neither a number nor a vec2")
    assertParams(isvec(c) or isnum(c), "clamp", "c", "is neither a number nor a vec2")
    return vec2.max(a, vec2.min(b, c)) 
end

function vec2.mix(a, b, t) 
    assertParams(isvec(a) or isnum(a), "mix", "a", "is neither a number nor a vec2")
    assertParams(isvec(b) or isnum(b), "mix", "b", "is neither a number nor a vec2")
    assertParams(isvec(t) or isnum(t), "mix", "t", "is neither a number nor a vec2")

    return a + (b - a) * t 
end

function vec2.smoothstep(edge0, edge1, x)
    assertParams(isvec(edge0) or isnum(edge0), "smoothstep", "edge0", "is neither a number nor a vec2")
    assertParams(isvec(edge1) or isnum(edge1), "smoothstep", "edge1", "is neither a number nor a vec2")
    assertParams(isvec(x) or isnum(x), "smoothstep", "x", "is neither a number nor a vec2")

    local t = vec2.clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)
end

local function stepcomp(a, b)
    if(a < b) then
        return 0
    end
    return 1
end 

function vec2.step(edge, x)
    assertParams(isvec(edge) or isnum(edge), "step", "edge", "is neither a number nor a vec2")
    assertParams(isvec(x) or isnum(x), "step", "x", "is neither a number nor a vec2")
    return vec2.compare(edge, x, stepcomp)
end

function vec2.reflect(i, n)
    assertParams(isvec(i), "reflect", "i", "is not a vec2")
    assertParams(isvec(n), "reflect", "n", "is not a vec2")
    n = vec2.normalize(n)
    return i - 2.0*vec2.dot(n, i)*n;
end

function vec2.refract(i, n, eta)
    assertParams(isvec(i), "reflect", "i", "is not a vec2")
    assertParams(isvec(n), "reflect", "n", "is not a vec2")
    assertParams(isnum(eta), "refract", "eta", "is not a number")
    i = vec2.normalize(i)
    n = vec2.normalize(n)
    local d = vec2.dot(n, i)
    local k = 1.0 - eta*eta*(1.0 - d*d)
    if(k < 0) then
        return vec2()
    end
    return eta * i - (eta * d + sqrt(k)) * n
end

function vec2.__call(t, x, y)
    local it = type(x) == "table"
    local iv = isvec(x)
    assertParams(isnum(x) or it or iv or x == nil, "__call", "x", " is neither a number, a table nor a vec4.")
    assertParams(isnum(y) or y == nil, "__call", "y", "is not a number.")
    local k, i = false, false
    if(it) then
        k = (isnum(x.x) and isnum(x.y))
        i = (isnum(x[1]) and isnum(x[2]))
    end
    assertParams(isnum(x) or iv or x == nil or it and (i or k), "new", "x", "is a table but doesn't contain valid values.")
    if(it and i) then return ffi.new("vec4", x[1] or 0, x[2] or 0) end
    if(it or iv) then return ffi.new("vec4", x.x or 0, x.y or 0) end
    return ffi.new("vec4", x or 0, y or 0)
end

function vec2.is(v)
    return isvec(v)
end

return vec2
