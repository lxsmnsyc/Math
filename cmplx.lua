local ffi = require "ffi"

local C, istype, new = ffi.C, ffi.istype, ffi.new 

local sqrt, min, max, ceil, floor, abs, exp, log  = math.sqrt, math.min, math.max, math.ceil, math.floor, math.abs, math.exp, math.log
local cos, sin, tan = math.cos, math.sin, math.tan
local asin, acos, atan, atan2 = math.asin, math.acos,math.atan, math.atan2
local cosh, sinh, tanh = math.cosh, math.sinh, math.tanh

ffi.cdef[[
    typedef struct{
        float re, im;
    } cmplx;
]]

local cmplx


local EPSILON = 0.000001;

local function exactEqual(a, b)
    return abs(a - b) <= EPSILON*max(1.0, max(abs(a), abs(b)))
end

local function isnum(a)
    return type(a) == "number"
end

local function iscmplx(a)
    return istype("cmplx", a)
end

local function c__conjugate(a)
    return cmplx(a.re, -a.im)
end

local function c____unm(a)
    return cmplx(-a.re, -a.im)
end

local function c____add(a, b)
    if(iscmplx(a)) then
        if(iscmplx(b)) then
            return cmplx(a.re + b.re, a.im + b.im)
        elseif(isnum(b)) then
            return cmplx(a.re + b, a.im)
        end
    elseif(iscmplx(b) and isnum(a)) then
        return cmplx(a + b.re, b.im)
    end
    return cmplx()
end

local function c____sub(a, b)
    if(iscmplx(a)) then
        if(iscmplx(b)) then
            return cmplx(a.re - b.re, a.im - b.im)
        elseif(isnum(b)) then
            return cmplx(a.re - b, a.im)
        end
    elseif(iscmplx(b) and isnum(a)) then
        return cmplx(a - b.re, b.im)
    end
    return cmplx()
end

local function c____mul(a, b)
    if(iscmplx(a)) then
        if(iscmplx(b)) then
            return cmplx(a.re*b.re - a.im*b.im, a.re*b.im + a.im*b.re)
        elseif(isnum(b)) then
            return cmplx(a.re*b, a.im*b)
        end
    
    elseif(iscmplx(b) and isnum(a)) then
        return cmplx(a*b.re, a*b.im)
    end
    return cmplx()
end

local function c____div(a, b)
    if(iscmplx(a)) then
        if(iscmplx(b)) then
            local A, B = a.re, a.im
            local C, D = b.re, b.im
            local sqr = C*C + D*D
            return cmplx((A*C + B*D)/sqr, (B*C - A*D)/sqr)
        elseif(isnum(b)) then
            return cmplx(a.re/b, a.im/b)
        end
    elseif(iscmplx(b) and isnum(a)) then
        local C, D = b.re, b.im
        return cmplx(a/C, a/D)
    end
    return cmplx()
end

local function c__reciprocal(a)
    local re, im = a.re, a.im 
    local sqr = re*re + im*im
    return cmplx(re/sqr, -im/sqr)
end

local function c__abs(a)
    local re, im = a.re, a.im
    return sqrt(re*re + im*im)
end

local function c__arg(a)
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

local function c__sgn(a)
    if(isnum(a)) then return cmplx(sgn(a), 0) end
    return c__euler(c__arg(a))
end

local function c__sqrt(a)
    if(isnum(a)) then return cmplx(sqrt(a), 0) end
    local re, im = a.re, a.im 
    if(exactEqual(im, 0)) then return cmplx(sqrt(re), 0) end
    local modulus = sqrt(re*re + im*im)
    return cmplx(sqrt((re + modulus)/2), sqrt((-re + modulus)/2)*sgn(im))
end

local function c__euler(x)
    return cmplx(cos(x), sin(x))
end

local function c__exp(a)
    local re, im = a.re, a.im 
    local e = exp(re)
    if(im == 0) then return cmplx(e, 0) end
    return cmplx(e * cos(im), e * sin(im))
end

local function c__ln(a)
    local re, im = a.re, a.im
    return cmplx(log(sqrt(re*re + im*im)), atan2(im, re))
end

local function c__log10(a)
    return c__ln(a) / c__ln(cmplx(10, 0))
end

local function c____pow(a, b)
    if(isnum(a)) then
        a = cmplx(a, 0)
    end
    if(isnum(b)) then
        b = cmplx(b, 0)
    end
    return c__exp(c__ln(a) * b)
end

local function c__floor(a)
    if(isnum(a)) then return cmplx(floor(a), 0) end
    return cmplx(floor(a.re), floor(a.im))
end

local function c__ceil(a)
    if(isnum(a)) then return cmplx(ceil(a), 0) end
    return cmplx(ceil(a.re), ceil(a.im))
end

local function c__polar(radius, phi)
    return cmplx(radius*cos(phi), radius*sin(phi))
end

local function c__sin(a)
    if(isnum(a)) then return cmplx(sin(a), 0) end

    local re, im = a.re, a.im
    return cmplx(sin(re)*cosh(im), cos(re)*sinh(im))
end

local function c__cos(a)
    if(isnum(a)) then return cmplx(cos(a), 0) end

    local re, im = a.re, a.im
    return cmplx(cos(re)*cosh(im), -sin(re)*sinh(im))
end

local function c__tan(a)
    if(isnum(a)) then return cmplx(tan(a), 0) end
    return c__sin(a) / c__cos(a)
end

local function c__asin(a)
    if(isnum(a)) then return cmplx(asin(a), 0) end
    return -a.im * c__ln(a.im * a + c__sqrt(1 - a ^ 2))
end

local function c__acos(a)
    if(isnum(a)) then return cmplx(acos(a), 0) end
    return math.pi / 2 - c__asin(a)
end

local function c__atan(a)
    if(isnum(a)) then return cmplx(atan(a), 0) end
    return 0.5 * a.im * c__ln((1 - a.im * a) / (1 + a.im * a))
end

local function c__sinh(a)
    if(isnum(a)) then return cmplx(sinh(a), 0) end
    return (c__exp(a) - c__exp(-a)) / 2
end

local function c__cosh(a)
    if(isnum(a)) then return cmplx(cosh(a), 0) end
    return (c__exp(a) + c__exp(-a)) / 2
end


local function c__tanh (a)
    if(isnum(a)) then return cmplx(tanh(a), 0) end
	return (c__sinh(a) / c__cosh(a))
end

local function c__asinh (a)
    if(isnum(a)) then a = cmplx(a, 0) end
	return c__ln(a + c__sqrt(a ^ 2 + 1))
end

local function c__acosh (a)
    if(isnum(a)) then a = cmplx(a, 0) end
	return c__ln(a + c__sqrt(a + 1) * c__sqrt(a - 1))
end

local function c__atanh (a)
    if(isnum(a)) then a = cmplx(a, 0) end
	return (0.5 * c__ln((1 + a) / (1 - a)))
end

local function c___tostring(a)
    local s = sgn(a.im)
    return a.re.." "..((s > 0) and "+" or ((s < 0) and "-" or "+")).." "..abs(a.im).."i"
end

local mt = {}
local mti = {}

mt.__add = c____add
mt.__sub = c____sub
mt.__mul = c____mul
mt.__div = c____div
mt.__unm = c____unm
mt.__pow = c____pow
mt.__tostring = c___tostring

mti.sqrt = c__sqrt
mti.exp = c__exp
mti.log = c__ln
mti.log10 = c__log10
mti.abs = c__arg
mti.arg = c__arg
mti.polar = c__polar
mti.reciprocal = c__reciprocal
mti.euler = c__euler
mti.conjugate = c__conjugate
mti.floor = c__floor
mti.ceil = c__ceil
mti.sgn = c__sgn
mti.sin = c__sin
mti.cos = c__cos
mti.tan = c__tan
mti.asin = c__asin
mti.acos = c__acos
mti.atan = c__atan
mti.sinh = c__sinh
mti.cosh = c__cosh
mti.tanh = c__tanh
mti.acosh = c__acosh
mti.asinh = c__asinh
mti.atanh = c__atanh 

mt.__index = mti
cmplx = ffi.metatype("cmplx", mt)

return cmplx 