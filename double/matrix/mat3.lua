
local ffi = require "ffi"

local new, istype = ffi.new, ffi.istype

local cos, sin, max, abs = math.cos, math.sin, math.max, math.abs

ffi.cdef[[
    typedef struct{
        double set[9];
    } mat3;
]]

local EPSILON = 0.000001;

local function exactEqual(a, b)
    return abs(a - b) <= EPSILON*max(1.0, max(abs(a), abs(b)))
end

local mat3

local function isnum(v)
    return type(v) == "number"
end

local function ismat(v)
    return istype("mat3", v)
end

local function m__compare(a, b, comp)
    local ima, imb, ina, inb = ismat(a), ismat(b), isnum(a), isnum(b)
    
    if(ima) then
        if(imb) then
            local as, bs = a.set, b.set
            local r = {}
            for i = 0, 8 do 
                r[i] = comp(as[i], bs[i])
            end 
            return mat3({r})
        elseif(inb) then
            local as = a.set
            local r = {}
            for i = 0, 8 do 
                r[i] = comp(as[i], b)
            end 
            return mat3({r})
        end
    elseif(imb and ina) then
        local bs = b.set
        local r = {}
        for i = 0, 8 do 
            r[i] = comp(a, bs[i])
        end 
        return mat3({r})
    end

    return mat3()
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
    if(ismat(a)) then
        local as = a.set
        if(isnum(b)) then
            for c = 0, 8 do 
                if(not exactEqual(as[c], b)) then return false end
            end
            return true
        elseif(ismat(b)) then
            local bs = b.set
            for c = 0, 8 do 
                if(not exactEqual(as[c], bs[c])) then return false end
            end
            return true
        end
    elseif(ismat(b) and isnum(a)) then
        local bs = b.set
        for c = 0, 8 do 
            if(not exactEqual(a, bs[c])) then return false end
        end
        return true
    end
    return false
end 

local function m____unm(a)
    local as = a.set
    return mat3({{
        -as[0], -as[1], -as[2],
        -as[3], -as[4], -as[5],
        -as[6], -as[7], -as[8]
    }})
end

local function m__dot(a, b, r, c)

    local as, bs = a.set, b.set
    local off = r*3
    return as[off + 0]*bs[c] + as[off + 1]*bs[3 + c] + as[off + 2]*bs[6 + c]
end

local function m____mul(a, b)
    local ima, imb, ina, inb = ismat(a), ismat(b), isnum(a), isnum(b)

    if(ima) then
        if(imb) then
            local as, bs = a.set, b.set
            local a00, a01, a02 = as[0], as[1], as[2]
            local a10, a11, a12 = as[3], as[4], as[5]
            local a20, a21, a22 = as[6], as[7], as[8]
            local b00, b01, b02 = bs[0], bs[1], bs[2]
            local b10, b11, b12 = bs[3], bs[4], bs[5]
            local b20, b21, b22 = bs[6], bs[7], bs[8]
            return mat3({{
                a00*b00 + a01*b10 + a02*b20, a00*b01 + a01*b11 + a02*b21, a00*b02 + a01*b12 + a02*b22, 
                a10*b00 + a11*b10 + a12*b20, a10*b01 + a11*b11 + a12*b21, a10*b02 + a11*b12 + a12*b22, 
                a20*b00 + a21*b10 + a22*b20, a20*b01 + a21*b11 + a22*b21, a20*b02 + a21*b12 + a22*b22
            }})
        elseif(inb) then
            local as = a.set
            local r = {}
            for i = 0, 8 do 
                r[i] =as[i]*b
            end 
            return mat3({r})
        end 
    elseif(imb and ina) then
        local bs = b.set
        local r = {}
        for i = 0, 8 do 
            r[i] = a*bs[i]
        end 
        return mat3({r})
    end
    return mat3()
end

local function m__mulComp(a, b)
    return m__compare(a, b, mul)
end


local function m____tostring(m)
    local s = "mat3("

    for i = 0, 8 do
        s = s..m.set[i]
        if(i < 8) then
            s = s..", "
        end
    end 
    s = s..")"
    return s
end

local function m__transpose(m)
    local ms = m.set
    return mat3({{
        ms[0], ms[3], ms[6],
        ms[1], ms[4], ms[7],
        ms[2], ms[5], ms[8]
    }})
end 

local function m__determinant(m)
    local ms = m.set
    local a, b, c = ms[0], ms[1], ms[2]
    local d, e, f = ms[3], ms[4], ms[5]
    local g, h, i = ms[6], ms[7], ms[8]
    return a*e*i + b*f*g + c*d*h - c*e*g - b*d*i - a*f*h 
end 

local function det(x, y, z, w)
    return x*w - y*z
end

local function m__adjugate(m)
    local ms = m.set
    local a, b, c = ms[0], ms[1], ms[2]
    local d, e, f = ms[3], ms[4], ms[5]
    local g, h, i = ms[6], ms[7], ms[8]
    local A, D, G = det(e, f, h, i), -det(b, c, h, i), det(b, c, e, f)
    local B, E, H = -det(d, f, g, i), det(a, c, g, i), -det(a, c, d, f)
    local C, F, I = det(d, e, g, h), -det(a, b, g, h), det(a, b, d, e)
    return mat3({{
        A, D, G,
        B, E, H,
        C, F, I
    }})
end

local function m__inverse(m)
    local dete = m__determinant(m)
    return (1/dete) * m__adjugate(m)
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


local function m__fromYaw(theta)
    local c, s = cos(theta), sin(theta)
    return mat3({{
        c, 0, s,
        0, 1, 0,
        -s, 0, c
    }})
end

local function m__fromRoll(theta)
    local c, s = cos(theta), sin(theta)
    return mat3({{
        c, -s, 0,
        s, c, 0,
        0, 0, 1
    }})
end


local function m__fromPitch(theta)
    local c, s = cos(theta), sin(theta)
    return mat3({{
        1, 0, 0,
        0, c, -s,
        0, s, c
    }})
end

local function m__fromSpherical(radius, theta, phi)

    local ct, st = cos(theta), sin(theta)
    local cp, sp = cos(phi), sin(phi)
    return mat3({{
        st*cp, radius*ct*cp, -radius*st*sp,
        st*sp, radius*ct*sp, radius*st*cp,
        ct, -radius*st, 0
    }})
end

local function m__row(m, r)
    local ms = m.set
    local off = r*3
    return ms[off], ms[off + 1], ms[off + 2]
end

local function m__col(m, c)
    local ms = m.set
    return ms[c], ms[3 + c], ms[6 + c]
end

local function m__get(m, r, c)
    return m.set[r*3 + c]
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

mti.fromSpherical = m__fromSpherical
mti.fromPitch = m__fromPitch
mti.fromYaw = m__fromYaw
mti.fromRoll = m__fromRoll

mti.get = m__get

mt.__index = mti

mat3 = ffi.metatype("mat3", mt)

return mat3