local ffi = require "ffi"

local C, istype, new = ffi.C, ffi.istype, ffi.new 

ffi.cdef[[
    float cabsf(float complex z);
    float cargf(float complex z);
    float cimagf(float complex z);
    float crealf(float complex z);

    float complex csinf(float complex z);
    float complex ccosf(float complex z);
    float complex ctanf(float complex z);

    float complex cacosf(float complex z);
    float complex casinf(float complex z);
    float complex catanf(float complex z);

    float complex csinhf(float complex z);
    float complex ccoshf(float complex z);
    float complex ctanhf(float complex z);

    float complex casinhf(float complex z);
    float complex cacoshf(float complex z);
    float complex catanhf(float complex z);

    float complex cexpf(float complex z);
    float complex clogf(float complex z);
    float complex csqrtf(float complex z);
    
    float complex cprojf(float complex z);

    float complex conjf(float complex z);

    float complex caddf(float complex x, float complex z);
    float complex csubf(float complex x, float complex z);
]]


local function assertParams(act, method, param, msg)
    assert(act, "cmplx."..method..": parameter \""..param.."\" "..msg)
end

local cmplx = {}
setmetatable(cmplx, cmplx)

ffi.metatype("cmplx", cmplx)

local EPSILON = 0.000001;

local function exactEqual(a, b)
    return abs(a - b) <= EPSILON*max(1.0, max(abs(a), abs(b)))
end

local function isnum(a)
    return type(a) == "number"
end

local function c____call(re, im)
    assertParams(isnum(re), "__call", "re", "is not a number")
    assertParams(isnum(im), "__call", "im", "is not a number")
    return new("cmplx", re or 0, im or 0)
end

local function iscmplx(a)
    return istype("cmplx", a)
end

local function c__conjugate(a)
    assertParams(iscmplx(a), "conjugate", "a", "is not a cmplx")
    return cmplx(a.re, -a.im)
end

local function c____unm(a)
    assertParams(iscmplx(a), "__unm", "a", "is not a cmplx")
    return cmplx(-a.re, -a.im)
end

local function c____add(a, b)
    assertParams(isnum(a) or iscmplx(a), "__add", "a", "is not a number or a cmplx")
    assertParams(isnum(b) or iscmplx(b), "__add", "b", "is not a number or a cmplx")
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
    assertParams(isnum(a) or iscmplx(a), "__sub", "a", "is not a number or a cmplx")
    assertParams(isnum(b) or iscmplx(b), "__sub", "b", "is not a number or a cmplx")
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
    assertParams(isnum(a) or iscmplx(a), "__mul", "a", "is not a number or a cmplx")
    assertParams(isnum(b) or iscmplx(b), "__mul", "b", "is not a number or a cmplx")
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
    assertParams(isnum(a) or iscmplx(a), "__div", "a", "is not a number or a cmplx")
    assertParams(isnum(b) or iscmplx(b), "__div", "b", "is not a number or a cmplx")
    if(iscmplx(a)) then
        if(iscmplx(b)) then
            local A, B = a.re, a.im
            local C, D = b.re, b.im
            assertParams(not(exactEqual(C, 0) and exactEqual(D, 0)), "__div", "b", "is a zero cmplx")
            local sqr = C*C + D*D
            return cmplx((A*C + B*D)/sqr, (B*C - A*D)/sqr)
        elseif(isnum(b)) then
            assertParams(not(exactEqual(b, 0)), "__div", "b", "is a zero number")
            return cmplx(a.re/b, a.im/b)
        end
    elseif(iscmplx(b) and isnum(a)) then
        local C, D = b.re, b.im
        assertParams(not(exactEqual(C, 0) and exactEqual(D, 0)), "__div", "b", "is a zero cmplx")
        return cmplx(a/C, a/D)
    end
    return cmplx()
end

local function c__reciprocal(a)
    assertParams(iscmplx(a), "reciprocal", "a", "is not a cmplx")
    assertParams(not(exactEqual(a.re, 0) and exactEqual(a.im, 0)), "reciprocal", "a", "is a zero cmplx")
    local re, im = a.re, a.im 
    local sqr = re*re + im*im
    return cmplx(re/sqr, -im/sqr)
end

local function c__abs(a)
    assertParams(iscmplx(a), "abs", "a", "is not a cmplx")
    local re, im = a.re, a.im
    return sqrt(re*re + im*im)
end

local function c__arg(a)
    assertParams(iscmplx(a), "arg", "a", "is not a cmplx")
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
    assertParams(isnum(a) or iscmplx(a), "sgn", "a", "is not a number nor a cmplx")
    if(isnum(a)) then return cmplx(sgn(a), 0) end
    return c__euler(c__arg(a))
end

local function c__sqrt(a)
    assertParams(isnum(a) or iscmplx(a), "sqrt", "a", "is not a number nor a cmplx")
    if(isnum(a)) then return cmplx(sqrt(a), 0) end
    local re, im = a.re, a.im 
    if(exactEqual(im, 0)) then return cmplx(sqrt(re), 0) end
    local modulus = sqrt(re*re + im)
    return cmplx(sqrt((a + modulus)/2), sqrt((-a + modulus)/2)*sgn(im))
end

local function c__euler(x)
    assertParams(isnum(x), "euler", "x", "is not a number")
    return cmplx(cos(x), sin(x))
end

local function c__exp(a)
    assertParams(iscmplx(a), "exp", "a", "is not a cmplx")
    local re, im = a.re, a.im 
    local e = exp(re)
    if(im == 0) then return cmplx(e, 0) end
    return cmplx(e * cos(im), e * sin(im))
end

local function c__ln(a)
    assertParams(iscmplx(a), "ln", "a", "is not a cmplx")
    local re, im = a.re, a.im
    return cmplx(log(sqrt(re*re + im*im)), atan2(im, re))
end

local function c__log10(a)
    assertParams(iscmplx(a), "log10", "a", "is not a cmplx")
    return c__ln(a) / c__ln(cmplx(10, 0))
end

local function c____pow(a, b)
    assertParams(isnum(a) or iscmplx(a), "__pow", "a", "is not a number nor a cmplx")
    assertParams(isnum(b) or iscmplx(b), "__pow", "b", "is not a number nor a cmplx")
    if(isnum(a)) then
        a = cmplx(a, 0)
    end
    if(isnum(b)) then
        b = cmplx(b, 0)
    end
    return c__exp(ln(a) * b)
end

local function c__floor(a)
    assertParams(isnum(a) or iscmplx(a), "floor", "a", "is not a number nor a cmplx")
    if(isnum(a)) then return cmplx(floor(a), 0) end
    return cmplx(floor(a.re), floor(a.im))
end

local function c__ceil(a)
    assertParams(isnum(a) or iscmplx(a), "ceil", "a", "is not a number nor a cmplx")
    if(isnum(a)) then return cmplx(ceil(a), 0) end
    return cmplx(ceil(a.re), ceil(a.im))
end

local function c__polar(radius, phi)
    return cmplx(radius*cos(phi), radius*sin(phi))
end

local function c__sin(a)
    assertParams(isnum(a) or iscmplx(a), "sin", "a", "is not a number nor a cmplx")
    if(isnum(a)) then return cmplx(sin(a), 0) end

    local re, im = a.re, a.im
    return cmplx(sin(re)*cosh(im), cos(re)*sinh(im))
end

local function c__cos(a)
    assertParams(isnum(a) or iscmplx(a), "cos", "a", "is not a number nor a cmplx")
    if(isnum(a)) then return cmplx(cos(a), 0) end

    local re, im = a.re, a.im
    local exp1 = c__exp()
    return cmplx(cos(re)*cosh(im), -sin(re)*sinh(im))
end

local function c__tan(a)
    assertParams(isnum(a) or iscmplx(a), "tan", "a", "is not a number nor a cmplx")
    if(isnum(a)) then return cmplx(tan(a), 0) end
    return c__sin(a) / c__cos(a)
end

local function c__asin(a)
    assertParams(isnum(a) or iscmplx(a), "asin", "a", "is not a number nor a cmplx")
    if(isnum(a)) then return cmplx(asin(a), 0) end
    return -a.im * c__ln(a.im * a + c__sqrt(1 - a ^ 2))
end

local function c__acos(a)
    assertParams(isnum(a) or iscmplx(a), "acos", "a", "is not a number nor a cmplx")
    if(isnum(a)) then return cmplx(acos(a), 0) end
    return math.pi / 2 - c__asin(a)
end

local function c__atan(a)
    assertParams(isnum(a) or iscmplx(a), "atan", "a", "is not a number nor a cmplx")
    if(isnum(a)) then return cmplx(atan(a), 0) end
    return 0.5 * a.im * c__ln((1 - a.im * a) / (1 + a.im * a))
end

local function c__sinh(a)
    assertParams(isnum(a) or iscmplx(a), "sinh", "a", "is not a number nor a cmplx")
    if(isnum(a)) then return cmplx(sinh(a), 0) end
    return (c__exp(a) - c__exp(-a)) / 2
end

local function c__cosh(a)
    assertParams(isnum(a) or iscmplx(a), "cosh", "a", "is not a number nor a cmplx")
    if(isnum(a)) then return cmplx(cosh(a), 0) end
    return (c__exp(a) + c__exp(-a)) / 2
end


local function c__tanh (a)
    assertParams(isnum(a) or iscmplx(a), "tanh", "a", "is not a number nor a cmplx")
    if(isnum(a)) then return cmplx(tanh(a), 0) end
	return (c__sinh(a) / c__cosh(a))
end

local function c__asinh (a)
    assertParams(isnum(a) or iscmplx(a), "asinh", "a", "is not a number nor a cmplx")
    if(isnum(a)) then a = cmplx(a, 0) end
	return c__ln(a + c__sqrt(a ^ 2 + 1))
end

local function c__acosh (a)
    assertParams(isnum(a) or iscmplx(a), "acosh", "a", "is not a number nor a cmplx")
    if(isnum(a)) then a = cmplx(a, 0) end
	return c__ln(a + c__sqrt(a + 1) * c__sqrt(a - 1))
end

local function c__atanh (a)
    assertParams(isnum(a) or iscmplx(a), "atanh", "a", "is not a number nor a cmplx")
    if(isnum(a)) then a = cmplx(a, 0) end
	return (0.5 * c__ln((1 + a) / (1 - a)))
end

local function c___tostring(a)
    assertParams(iscmplx(a), "__tostring", "a", "is not a cmplx")
    local s = sgn(a.im)
    return a.re.." "..((s > 0) and "+" or ((s < 0) and "-" or 0)).." "..abs(a.im).."i"
end

cmplx.__call = c____call
cmplx.__add = c____add
cmplx.__sub = c____sub
cmplx.__mul = c____mul
cmplx.__div = c____div
cmplx.__unm = c____unm
cmplx.__tostring = c___tostring

cmplx.sqrt = c__sqrt
cmplx.exp = c__exp
cmplx.log = c__ln
cmplx.log10 = c__log10
cmplx.abs = c__arg
cmplx.arg = c__arg
cmplx.polar = c__polar
cmplx.reciprocal = c__reciprocal
cmplx.euler = c__euler
cmplx.conjugate = c__conjugate
cmplx.floor = c__floor
cmplx.ceil = c__ceil
cmplx.sgn = c__sgn
cmplx.sin = c__sin
cmplx.cos = c__cos
cmplx.tan = c__tan
cmplx.asin = c__asin
cmplx.acos = c__acos
cmplx.atan = c__atan
cmplx.sinh = c__sinh
cmplx.cosh = c__cosh
cmplx.tanh = c__tanh
cmplx.acosh = c__acosh
cmplx.asinh = c__asinh
cmplx.atanh = c__atanh 

return cmplx 