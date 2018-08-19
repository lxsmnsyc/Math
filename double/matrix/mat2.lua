
local ffi = require "ffi"

local new, istype = ffi.new, ffi.istype

local cos, sin, max, abs = math.cos, math.sin, math.max, math.abs

ffi.cdef[[
    typedef struct{
        double set[4];
    } mat2;
]]

local EPSILON = 0.000001;

local function exactEqual(a, b)
    return abs(a - b) <= EPSILON*max(1.0, max(abs(a), abs(b)))
end


local mat2


local function isnum(v)
    return type(v) == "number"
end

local function ismat(v)
    return istype("mat2", v)
end

local function m__compare(a, b, comp)
    local ima, imb, ina, inb = ismat(a), ismat(b), isnum(a), isnum(b)
    
    if(ima) then
        if(imb) then
            local as, bs = a.set, b.set
            return mat2({{
                comp(as[0], bs[0]), comp(as[1], bs[1]),
                comp(as[2], bs[2]), comp(as[3], bs[3])
            }})
        elseif(inb) then
            local as = a.set
            return mat2({{
                comp(as[0], b), comp(as[1], b),
                comp(as[2], b), comp(as[3], b)
            }})
        end
    elseif(imb and ina) then
        local bs = b.set
        return mat2({{
            comp(a, bs[0]), comp(a, bs[1]),
            comp(a, bs[2]), comp(a, bs[3])
        }})
    end

    return mat2()
end

local function add(a, b) return a + b end
local function sub(a, b) return a - b end 
local function mul(a, b) return a * b end
local function div(a, b) return a / b end
local function pow(a, b) return a ^ b end

local function m____add(a, b)
    return m__compare(a, b, add)
end 

local function m____sub(a, b)
    return m__compare(a, b, sub)
end 

local function m____eq(a, b)
    local bs = b.set
    return  exactEqual(as[0], bs[0]) and exactEqual(as[1], bs[1]) and 
            exactEqual(as[2], bs[2]) and exactEqual(as[3], bs[3])
end 

local function m____unm(a)
    local as = a.set
    return mat2({{
        -as[0], -as[1],
        -as[2], -as[3]
    }})
end

local function m__dot(a, b, r, c)
    local as, bs = a.set, b.set
    return as[r*2 + 0]*bs[c] + as[r*2 + 1]*bs[2 + c]
end

local function m____mul(a, b)
    local ima, imb, ina, inb = ismat(a), ismat(b), isnum(a), isnum(b)

    if(ima) then
        if(imb) then
            local as, bs = a.set, b.set
            local a00, a01, a10, a11 = as[0], as[1], as[2], as[3]
            local b00, b01, b10, b11 = bs[0], bs[1], bs[2], bs[3]
            return mat2({{
                a00*b00 + a01*b10, a00*b01 + a01*b11,
                a10*b00 + a11*b10, a10*b01 + a11*b11
            }})
        elseif(inb) then
            local as = a.set
            return mat2({{
                as[0]*b, as[1]*b,
                as[2]*b, as[3]*b
            }})
        end 
    elseif(imb and ina) then
        local bs = b.set
        return mat2({{
            a*bs[0], a*bs[1],
            a*bs[2], a*bs[3]
        }})
    end
    return mat2()
end

local function m__mulComp(a, b)
    return m__compare(a, b, mul)
end


local function m____tostring(m)
    return "mat2("..m.set[0]..", "..m.set[1]..", "..m.set[2]..", "..m.set[3]..")"
end

local function m__transpose(m)
    
    local ms = m.set
    return mat2({{
        ms[0], ms[2],
        ms[1], ms[3]
    }})
end 

local function m__determinant(m)
    local ms = m.set
    return ms[0]*ms[3] - ms[1]*ms[2]
end 

local function m__adjugate(m)
    local ms = m.set
    return mat2({{
        ms[3], -ms[1], 
        -ms[2], ms[0]
    }})
end

local function m__inverse(m)
    local ms = m.set
    local deter = m__determinant(m)
    return (1/deter) * m__adjugate(m)
end

local function m____div(a, b)
    if(isnum(b)) then return m__compare(a, b, div) end
    return m__inverse(b) * a
end

local function m____pow(a, b)
    return m__compare(a, b, pow)
end 

local function m__divComp(a, b)
    return m__compare(a, b, div)
end 

local function m__fromRotation(rad)
    local c, s = cos(rad), sin(rad)
    return mat2({{
        c, -s,
        s, c
    }})
end

local function m__row(m, r)
    local ms = m.set
    return ms[r*2], ms[r*2 + 1]
end

local function m__col(m, c)
    local ms = m.set
    return ms[c], ms[2 + c]
end

local function m__get(m, r, c)
    return m.set[r*2 + c]
end 

local mt = {}
local mti = {}

mti.compare = m__compare
mt.__add = m____add
mt.__sub = m____sub
mt.__mul = m____mul
mt.__div = m____div
mt.__eq = m____eq
mt.__tostring = m____tostring
mt.__unm = m____unm
mt.__call = m____call
mti.adjugate = m__adjugate
mti.adjoint = m__adjugate
mti.col = m__col
mti.det = m__determinant
mti.determinant = m__determinant
mti.divComp = m__divComp
mti.dot = m__dot
mti.inverse = m__inverse
mti.inv = m__inverse
mti.mulComp = m__mulComp
mti.row = m__row
mti.transpose = m__transpose
mti.get = m__get

mt.fromRotation = m__fromRotation

mt.__index = mti

mat2 = ffi.metatype("mat2", mt)

return mat2