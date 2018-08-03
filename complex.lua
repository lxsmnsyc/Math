local ffi = require "ffi"

local sqrt, min, max, ceil, floor, abs, exp, log, cos, sin, atan2 = math.sqrt, math.min, math.max, math.ceil, math.floor, math.abs, math.exp, math.log, math.cos, math.sin, math.atan2

ffi.cdef[[
    typedef struct{
        float re, im;
    } complex;
]]


local function assertParams(act, method, param, msg)
    assert(act, "complex."..method..": parameter \""..param.."\" "..msg)
end

local complex = {}
setmetatable(complex, complex)

ffi.metatype("complex", complex)

local EPSILON = 0.000001;

local function exactEqual(a, b)
    return abs(a - b) <= EPSILON*max(1.0, max(abs(a), abs(b)))
end

local function isnum(a)
    return type(a) == "number"
end

function complex.__call(re, im)
    assertParams(isnum(re), "__call", "re", "is not a number")
    assertParams(isnum(im), "__call", "im", "is not a number")
    return ffi.new("complex", re or 0, im or 0)
end

local function iscomplex(a)
    return ffi.istype("complex", a)
end

function complex.conjugate(a)
    assertParams(iscomplex(a), "__add", "a", "is not a complex")
    return complex(a.re, -a.im)
end

function complex.__unm(a)
    assertParams(iscomplex(a), "__add", "a", "is not a complex")
    return complex(-a.re, -a.im)
end

function complex.__add(a, b)
    assertParams(isnum(a) or iscomplex(a), "__add", "a", "is not a number or a complex")
    assertParams(isnum(b) or iscomplex(b), "__add", "b", "is not a number or a complex")
    if(iscomplex(a)) then
        if(iscomplex(b)) then
            return complex(a.re + b.re, a.im + b.im)
        elseif(isnum(b)) then
            return complex(a.re + b, a.im)
        end
    elseif(iscomplex(b) and isnum(a)) then
        return complex(a + b.re, b.im)
    end
    return complex()
end

function complex.__sub(a, b)
    assertParams(isnum(a) or iscomplex(a), "__sub", "a", "is not a number or a complex")
    assertParams(isnum(b) or iscomplex(b), "__sub", "b", "is not a number or a complex")
    if(iscomplex(a)) then
        if(iscomplex(b)) then
            return complex(a.re - b.re, a.im - b.im)
        elseif(isnum(b)) then
            return complex(a.re - b, a.im)
        end
    elseif(iscomplex(b) and isnum(a)) then
        return complex(a - b.re, b.im)
    end
    return complex()
end

function complex.__mul(a, b)
    assertParams(isnum(a) or iscomplex(a), "__mul", "a", "is not a number or a complex")
    assertParams(isnum(b) or iscomplex(b), "__mul", "b", "is not a number or a complex")
    if(iscomplex(a)) then
        if(iscomplex(b)) then
            return complex(a.re*b.re - a.im*b.im, a.re*b.im + a.im*b.re)
        elseif(isnum(b)) then
            return complex(a.re*b, a.im*b)
        end
    
    elseif(iscomplex(b) and isnum(a)) then
        return complex(a*b.re, a*b.im)
    end
    return complex()
end

function complex.__div(a, b)
    assertParams(isnum(a) or iscomplex(a), "__div", "a", "is not a number or a complex")
    assertParams(isnum(b) or iscomplex(b), "__div", "b", "is not a number or a complex")
    if(iscomplex(a)) then
        if(iscomplex(b)) then
            local A, B = a.re, a.im
            local C, D = b.re, b.im
            assertParams(not(exactEqual(C, 0) and exactEqual(D, 0)), "__div", "b", "is a zero complex")
            local sqr = C*C + D*D
            return complex((A*C + B*D)/sqr, (B*C - A*D)/sqr)
        elseif(isnum(b)) then
            assertParams(not(exactEqual(b, 0)), "__div", "b", "is a zero number")
            return complex(a.re/b, a.im/b)
        end
    elseif(iscomplex(b) and isnum(a)) then
        local C, D = b.re, b.im
        assertParams(not(exactEqual(C, 0) and exactEqual(D, 0)), "__div", "b", "is a zero complex")
        return complex(a/C, a/D)
    end
    return complex()
end

function complex.reciprocal(a)
    assertParams(iscomplex(a), "reciprocal", "a", "is not a complex")
    assertParams(not(exactEqual(a.re, 0) and exactEqual(a.im, 0)), "reciprocal", "a", "is a zero complex")
    local re, im = a.re, a.im 
    local sqr = re*re + im*im
    return complex(re/sqr, -im/sqr)
end

function complex.abs(a)
    assertParams(iscomplex(a), "abs", "a", "is not a complex")
    local re, im = a.re, a.im
    return sqrt(re*re + im*im)
end

complex.modulus = complex.abs

function complex.arg(a)
    assertParams(iscomplex(a), "arg", "a", "is not a complex")
    return atan2(a.im, a.re)
end


local function sgn(v)
    if(v < 0) then 
        return -1
    elseif(v > 0) then 
        return 1 
    end
    return 0
end 

function complex.sqrt(a)
    assertParams(iscomplex(a), "sqrt", "a", "is not a complex")
    local re, im = a.re, a.im 
    if(exactEqual(im, 0)) then return sqrt(re) end
    local modulus = sqrt(re*re + im)
    return sqrt((a + modulus)/2), sqrt((-a + modulus)/2)*sgn(im)
end

function complex.euler(x)
    assertParams(isnum(x), "euler", "x", "is not a number")
    return complex(cos(x), sin(x))
end

function complex.exp(a)
    assertParams(iscomplex(a), "exp", "a", "is not a complex")
    local re, im = a.re, a.im 
    local e = exp(re)
    if(im == 0) then return complex(e, 0) end
    return complex(e * cos(im), e * sin(im))
end

function complex.ln(a)
    assertParams(iscomplex(a), "ln", "a", "is not a complex")
    local re, im = a.re, a.im
    return complex(log(sqrt(re*re + im*im)), atan2(im, re))
end

function complex.floor(a)
    assertParams(isnum(a) or iscomplex(a), "floor", "a", "is not a number nor a complex")
    if(isnum(a)) then return complex(floor(a), 0) end
    return complex(floor(a.re), floor(a.im))
end

function complex.ceil(a)
    assertParams(isnum(a) or iscomplex(a), "ceil", "a", "is not a number nor a complex")
    if(isnum(a)) then return complex(ceil(a), 0) end
    return complex(ceil(a.re), ceil(a.im))
end

function complex.polar(radius, phi)
    return complex(radius*cos(phi), radius*sin(phi))
end

return complex 