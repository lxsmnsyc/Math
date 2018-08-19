
local ffi = require "ffi"

local new, istype = ffi.new, ffi.istype

local cos, sin, max, abs = math.cos, math.sin, math.max, math.abs

ffi.cdef[[
    typedef struct{
        double set[16];
    } mat4;
]]

local EPSILON = 0.000001;

local function exactEqual(a, b)
    return abs(a - b) <= EPSILON*max(1.0, max(abs(a), abs(b)))
end


local mat4


local function isnum(v)
    return type(v) == "number"
end

local function ismat(v)
    return istype("mat4", v)
end

local function m__compare(a, b, comp)
    local ima, imb, ina, inb = ismat(a), ismat(b), isnum(a), isnum(b)
    
    if(ima) then
        if(imb) then
            local as, bs = a.set, b.set
            local r = {}
            for i = 0, 15 do 
                r[i] = comp(as[i], bs[i])
            end 
            return mat4({r})
        elseif(inb) then
            local as = a.set
            local r = {}
            for i = 0, 15 do 
                r[i] = comp(as[i], b)
            end 
            return mat4({r})
        end
    elseif(imb and ina) then
        local bs = b.set
        local r = {}
        for i = 0, 15 do 
            r[i] = comp(a, bs[i])
        end 
        return mat4({r})
    end

    return mat4()
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
            for c = 0, 15 do 
                if(not exactEqual(as[c], b)) then return false end
            end
            return true
        elseif(ismat(b)) then
            local bs = b.set
            for c = 0, 15 do 
                if(not exactEqual(as[c], bs[c])) then return false end
            end
            return true
        end
    elseif(ismat(b) and isnum(a)) then
        local bs = b.set
        for c = 0, 15 do 
            if(not exactEqual(a, bs[c])) then return false end
        end
        return true
    end
    return false
end 

local function m____unm(a)
    local as = a.set
    return mat4({{
        -as[0], -as[1], -as[2], -as[3],
        -as[4], -as[5], -as[6], -as[7],
        -as[8], -as[9], -as[10], -as[11],
        -as[12], -as[13], -as[14], -as[15],
    }})
end

local function dot(a, b, c, e, f, g, h, i)
    return a*f + b*g + c*h + e*i
end

local function m__dot(a, b, r, c)
    local as, bs = a.set, b.set
    local off = r*4
    return as[off + 0]*bs[c] + as[off + 1]*bs[4 + c] + as[off + 2]*bs[8 + c] + as[off + 3]*bs[12 + c]
end

local function m____mul(a, b)
    local ima, imb, ina, inb = ismat(a), ismat(b), isnum(a), isnum(b)

    if(ima) then
        if(imb) then
            local as, bs = a.set, b.set

            local a00, a01, a02, a03 = as[0], as[1], as[2], as[3]
            local a10, a11, a12, a13 = as[4], as[5], as[6], as[7]
            local a20, a21, a22, a23 = as[8], as[9], as[10], as[11]
            local a30, a31, a32, a33 = as[12], as[13], as[14], as[15]

            local a00, b01, b02, b03 = bs[0], bs[1], bs[2], bs[3]
            local b10, b11, b12, b13 = bs[4], bs[5], bs[6], bs[7]
            local b20, b21, b22, b23 = bs[8], bs[9], bs[10], bs[11]
            local b30, b31, b32, b33 = bs[12], bs[13], bs[14], bs[15]

            local A = dot(a00, a01, a02, a03, b00, b10, b20, b30)
            local B = dot(a00, a01, a02, a03, b01, b11, b21, b31)
            local C = dot(a00, a01, a02, a03, b02, b12, b22, b32)
            local D = dot(a00, a01, a02, a03, b03, b13, b23, b33)

            local E = dot(a10, a11, a12, a13, b00, b10, b20, b30)
            local F = dot(a10, a11, a12, a13, b01, b11, b21, b31)
            local G = dot(a10, a11, a12, a13, b02, b12, b22, b32)
            local H = dot(a10, a11, a12, a13, b03, b13, b23, b33)

            local I = dot(a20, a21, a22, a23, b00, b10, b20, b30)
            local J = dot(a20, a21, a22, a23, b01, b11, b21, b31)
            local K = dot(a20, a21, a22, a23, b02, b12, b22, b32)
            local L = dot(a20, a21, a22, a23, b03, b13, b23, b33)

            local M = dot(a30, a31, a32, a33, b00, b10, b20, b30)
            local N = dot(a30, a31, a32, a33, b01, b11, b21, b31)
            local O = dot(a30, a31, a32, a33, b02, b12, b22, b32)
            local P = dot(a30, a31, a32, a33, b03, b13, b23, b33)
            return mat4(
                A, B, C, D,
                E, F, G, H,
                I, J, K, L,
                M, N, O, P
            )
        elseif(inb) then
            local as = a.set
            local r = {}
            for i = 0, 8 do 
                r[i] =as[i]*b
            end 
            return mat4({r})
        end 
    elseif(imb and ina) then
        local bs = b.set
        local r = {}
        for i = 0, 8 do 
            r[i] = a*bs[i]
        end 
        return mat4({r})
    end
    return mat4()
end

local function m__mulComp(a, b)
    return m__compare(a, b, mul)
end


local function m____tostring(m)
    local s = "mat4("

    for i = 0, 15 do
        s = s..m.set[i]
        if(i < 15) then
            s = s..", "
        end
    end 
    s = s..")"
    return s
end

local function m__transpose(m)
    
    local ms = m.set
    return mat4({{
        ms[0], ms[1], ms[2], ms[3],
        ms[4], ms[5], ms[6], ms[7],
        ms[8], ms[9], ms[10], ms[11],
        ms[12], ms[13], ms[14], ms[15]
    }})
end 

local function det3(a, b, c, d, e, f, g, h, i)
    return a*e*i + b*f*g + c*d*h - c*e*g - b*d*i - a*f*h 
end

local function m__determinant(x)
    local ms = x.set
    local a, b, c, d = ms[0], ms[1], ms[2], ms[3]
    local e, f, g, h = ms[4], ms[5], ms[6], ms[7]
    local i, j, k, l = ms[8], ms[9], ms[10], ms[11]
    local m, n, o, p = ms[12], ms[13], ms[14], ms[15]
    return a*det3(
        f, g, h,
        j, k, l,
        n, o, p
    ) - b*det3(
        e, g, h,
        i, k, l,
        m, o, p
    ) + c*det3(
        e, f, h,
        i, j, l,
        m, n, p
    ) - d*det3(
        e, f, g,
        i, j, k,
        m, n, o
    )
end 


local function m__adjugate(x)
    local ms = x.set
    local a, b, c, d = ms[0], ms[1], ms[2], ms[3]
    local e, f, g, h = ms[4], ms[5], ms[6], ms[7]
    local i, j, k, l = ms[8], ms[9], ms[10], ms[11]
    local m, n, o, p = ms[12], ms[13], ms[14], ms[15]
    local A, E, I, M = det3(f, g, h, j, k, l, n, o, p), -det3(b, c, d, j, k, l, n, o, p), det3(b, c, d, f, g, h, n, o, p), -det3(b, c, d, f, g, h, j, k, l)
    local B, F, J, N = -det3(e, g, h, i, k, l, m, o, p), det3(a, c, d, i, k, l, m, o, p), -det3(a, c, d, e, g, h, i, k, l), det3(a, c, d, e, g, h, i, k, l)
    local C, G, K, O = det3(e, f, h, i, j, l, m, n, p), -det3(a, b, d, i, j, l, m, n, p), det3(a, b, d, e, f, h, m, n, p), -det3(a, b, d, e, f, h, i, j, l)
    local D, H, L, P = -det3(e, f, g, i, j, k, m, n, o), det3(a, b, c, i, j, k, m, n, o), -det3(a, b, c, e, f, g, m, n, o), det3(a, b, d, e, f, g, i, j, k)
    return mat4({{
        A, E, I, M,
        B, F, J, N,
        C, G, K, O,
        D, H, L, P
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

local function m__divComp(a, b)
    return m__compare(a, b, div)
end 

local function m__row(m, r)
    local ms = m.set
    local off = r*4
    return ms[off], ms[off + 1], ms[off + 2], ms[off + 3]
end

local function m__col(m, c)
    local ms = m.set
    return ms[c], ms[4 + c], ms[8 + c], ms[12 + c]
end

local function m__get(m, r, c)
    return m.set[r*4 + c]
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

mt.__index = mti

mat4 = ffi.metatype("mat4", mt)

return mat4