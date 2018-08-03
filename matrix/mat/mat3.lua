
local ffi = require "ffi"

local cos, sin, max, abs = math.cos, math.sin, math.max, math.abs

ffi.cdef[[
    typedef struct{
        float set[3][3];
    } mat3;
]]

local EPSILON = 0.000001;

local function exactEqual(a, b)
    return abs(a - b) <= EPSILON*max(1.0, max(abs(a), abs(b)))
end



local function assertParams(act, method, param, msg)
    assert(act, "mat3."..method..": parameter \""..param.."\" "..msg)
end

local mat3 = {}
setmetatable(mat3, mat3)

ffi.metatype("mat3", mat3)

local function isnum(v)
    return type(v) == "number"
end

local function ismat3(v)
    return ffi.istype("mat3", v)
end

function mat3.compare(a, b, comp)
    local ima, imb, ina, inb = ismat3(a), ismat3(b), isnum(a), isnum(b)
    assertParams(ima or ina, "compare", "a", "is not a number nor a mat3")
    assertParams(imb or inb, "compare", "b", "is not a number nor a mat3")
    
    if(ima) then
        if(imb) then
            local as, bs = a.set, b.set
            local a0, a1, a2, b0, b1, b2 = as[0], as[1], as[2], bs[0], bs[1], bs[2]
            return mat3(
                comp(a0[0], b0[0]), comp(a0[1], b0[1]), comp(a0[2], b0[2]),
                comp(a1[0], b1[0]), comp(a1[1], b1[1]), comp(a1[2], b1[2]),
                comp(a2[0], b2[0]), comp(a2[1], b2[1]), comp(a2[2], b2[2])
            )
        elseif(inb) then
            local as = a.set
            local a0, a1, a2= as[0], as[1], as[2]
            return mat3(
                comp(a0[0], b), comp(a0[1], b), comp(a0[2], b),
                comp(a1[0], b), comp(a1[1], b), comp(a1[2], b),
                comp(a2[0], b), comp(a2[1], b), comp(a2[2], b)
            )
        end
    elseif(imb and ina) then
        local bs = b.set
        local b0, b1,b2 = bs[0], bs[1], bs[2]
        return mat3(
            comp(a, b0[0]), comp(a, b0[1]), comp(a, b0[2]),
            comp(a, b1[0]), comp(a, b1[1]), comp(a, b1[2]),
            comp(a, b2[0]), comp(a, b2[1]), comp(a, b2[2])
        )
    end

    return mat3()
end

local function add(a, b) return a + b end
local function sub(a, b) return a - b end 
local function mul(a, b) return a * b end
local function div(a, b) return a / b end
local function pow(a, b) return a ^ b end

function mat3.__add(a, b)
    assertParams(ismat3(a) or isnum(a), "__add", "a", "is not a number nor a mat3")
    assertParams(ismat3(b) or isnum(b), "__add", "b", "is not a number nor a mat3")
    return mat3.compare(a, b, add)
end 

function mat3.__sub(a, b)
    assertParams(ismat3(a) or isnum(a), "__sub", "a", "is not a number nor a mat3")
    assertParams(ismat3(b) or isnum(b), "__sub", "b", "is not a number nor a mat3")
    return mat3.compare(a, b, sub)
end 

function mat3.__eq(a, b)
    assertParams(ismat3(a) or isnum(a), "__eq", "a", "is not a number nor a mat3")
    assertParams(ismat3(b) or isnum(b), "__eq", "b", "is not a number nor a mat3")
    if(ismat3(a)) then
        local as = a.set
        if(isnum(b)) then
            for c = 0, 2 do 
                local col = as[c]
                for r = 0, 2 do 
                    if(not exactEqual(col[r], b)) then return false end
                end
            end
            return true
        elseif(ismat3(b)) then
            local bs = b.set
            for c = 0, 2 do 
                local col1 = as[c]
                local col2 = bs[c]
                for r = 0, 2 do 
                    if(not exactEqual(col1[r], col2[r])) then return false end
                end
            end
            return true
        end
    elseif(ismat3(b) and isnum(a)) then
        local bs = b.set
        for c = 0, 2 do 
            local col = bs[c]
            for r = 0, 2 do 
                if(not exactEqual(a, col[r])) then return false end
            end
        end
        return true
    end
    return false
end 

function mat3.__unm(a)
    assertParams(ismat3(a), "__unm", "a", "is not a a mat3")
    local as = a.set
    local a0, a1, a2 = as[0], as[1], as[2]
    return mat3(
        -a0[0], -a0[1], -a0[2],
        -a1[0], -a1[1], -a1[2],
        -a2[0], -a2[1], -a2[2]
    )
end

function mat3.dot(a, b, r, c)
    assertParams(ismat3(a), "dot", "a", "is not a mat3")
    assertParams(ismat3(b), "dot", "b", "is not a mat3")
    assertParams(isnum(r), "dot", "r", "is not a number")
    assertParams(isnum(c), "dot", "c", "is not a number")

    local as, bs = a.set, b.set
    local ar = as[r]
    return ar[0]*b[0][c] + ar[1]*b[1][c] + ar[2]*b[2][c]
end

function mat3.__mul(a, b)
    local ima, imb, ina, inb = ismat3(a), ismat3(b), isnum(a), isnum(b)
    assertParams(ima or ina, "__mul", "a", "is not a number, a vec2 nor a mat3")
    assertParams(imb or inb, "__mul", "b", "is not a number, a vec2 nor a mat3")

    if(ima) then
        if(imb) then
            local as, bs = a.set, b.set
            local a0, a1, a2, b0, b1, b2 = as[0], as[1], as[2], bs[0], bs[1], bs[2]
            local a00, a01, a02 = a0[0], a0[1], a0[2]
            local a10, a11, a12 = a1[0], a1[1], a1[2]
            local a20, a21, a22 = a2[0], a2[1], a2[2]
            local b00, b01, b02 = b0[0], b0[1], b0[2]
            local b10, b11, b12 = b1[0], b1[1], b1[2]
            local b20, b21, b22 = b2[0], b2[1], b2[2]
            return mat3(
                a00*b00 + a01*b10 + a02*b20, a00*b01 + a01*b11 + a02*b21, a00*b02 + a01*b12 + a02*b22, 
                a10*b00 + a11*b10 + a12*b20, a10*b01 + a11*b11 + a12*b21, a10*b02 + a11*b12 + a12*b22, 
                a20*b00 + a21*b10 + a22*b20, a20*b01 + a21*b11 + a22*b21, a20*b02 + a21*b12 + a22*b22
            )
        elseif(inb) then
            local as = a.set
            local a0, a1, a2 = as[0], as[1], as[2]
            return mat3(
                a0[0]*b, a0[1]*b, a0[2]*b,
                a1[0]*b, a1[1]*b, a1[2]*b,
                a2[0]*b, a2[1]*b, a2[2]*b
            )
        end 
    elseif(imb and ina) then
        local bs = b.set
        local b0, b1, b2 = bs[0], bs[1], bs[2]
        return mat3(
            a*b0[0], a*b0[1], a*b0[2],
            a*b1[0], a*b1[1], a*b1[2],
            a*b2[0], a*b2[1], a*b2[2]
        )
    end
    return mat3()
end

function mat3.mulComp(a, b)
    assertParams(ismat3(a) or isnum(a), "mulComp", "a", "is not a number nor a mat3")
    assertParams(ismat3(b) or isnum(b), "mulComp", "b", "is not a number nor a mat3")
    return mat3.compare(a, b, mul)
end


function mat3.__tostring(m)
    assertParams(ismat3(m), "__tostring", "m", "is not a mat3")
    return "mat3("..
        m.set[0][0]..", "..m.set[0][1]..", "..m.set[0][2]..", "..
        m.set[1][0]..", "..m.set[1][1]..", "..m.set[1][2]..", "..
        m.set[2][0]..", "..m.set[2][1]..", "..m.set[2][2]..
    ")"
end

function mat3.transpose(m)
    assertParams(ismat3(m), "transpose", "m", "is not a mat3")
    
    local ms = m.set
    local m0, m1, m2 = ms[0], ms[1], ms[2]
    return mat3(
        m0[0], m1[0], m2[0],
        m0[1], m1[1], m2[1],
        m0[2], m1[2], m2[2]
    )
end 

function mat3.determinant(m)
    assertParams(ismat3(m), "determinant", "m", "is not a mat3")
    local ms = m.set
    local m0, m1, m2 = ms[0], ms[1], ms[2]
    local a, b, c = m0[0], m0[1], m0[2]
    local d, e, f = m1[0], m1[1], m1[2]
    local g, h, i = m2[0], m2[1], m2[2]
    return a*e*i + b*f*g + c*d*h - c*e*g - b*d*i - a*f*h 
end 

local function det(a0, a1, b0, b1)
    return a0*b1 - a1*b0
end

function mat3.adjugate(m)
    assertParams(ismat3(m), "adjugate", "m", "is not a mat3")
    local ms = m.set
    local m0, m1, m2 = ms[0], ms[1], ms[2]
    local a, b, c = m0[0], m0[1], m0[2]
    local d, e, f = m1[0], m1[1], m1[2]
    local g, h, i = m2[0], m2[1], m2[2]
    local A, D, G = det(e, f, h, i), -det(b, c, h, i), det(b, c, e, f)
    local B, E, H = -det(d, f, g, i), det(a, c, g, i), -det(a, c, d, f)
    local C, F, I = det(d, e, g, h), -det(a, b, g, h), det(a, b, d, e)
    return mat3(
        A, D, G,
        B, E, H,
        C, F, I
    )
end

function mat3.inverse(m)
    assertParams(ismat3(m), "inverse", "m", "is not a mat3")
    local dete = mat3.determinant(m)
    assert(not exactEqual(dete), "inverse", "m", "has a zero determinant")
    return (1/dete) * mat3.adjugate(m)
end

function mat3.__div(a, b)
    assertParams(ismat3(a) or isnum(a), "__div", "a", "is not a number nor a mat3")
    assertParams(ismat3(b) or isnum(b), "__div", "b", "is not a number nor a mat3")
    return mat3.inverse(b) * a
end

function mat3.__pow(a, b)
    assertParams(ismat3(a) or isnum(a), "__sub", "a", "is not a number nor a mat3")
    assertParams(ismat3(b) or isnum(b), "__sub", "b", "is not a number nor a mat3")
    return mat3.compare(a, b, pow)
end 

function mat3.divComp(a, b)
    assertParams(ismat3(a) or isnum(a), "divComp", "a", "is not a number nor a mat3")
    assertParams(ismat3(b) or isnum(b), "divComp", "b", "is not a number nor a mat3")
    assertParams(ismat3(b) or isnum(b) and not exactEqual(b, 0), "divComp", "b", "cannot be used to divide \"a\"")
    return mat3.compare(a, b, div)
end 

function mat3.identity()
    return mat3(
        1, 0, 0,
        0, 1, 0,
        0, 0, 1
    )
end

function mat3.exchange()
    return mat3(
        0, 0, 1,
        0, 1, 0,
        1, 0, 0
    )
end

function mat3.hilbert()
    return mat3(
        1, 1/2, 1/3,
        1/2, 1/3, 1/4,
        1/3, 1/4, 1/5
    )
end

function mat3.lehmer()
    return mat3(
        1, 1/2, 1/3,
        1/2, 1, 2/3,
        1/3, 2/3, 1
    )
end

function mat3.ilehmer()
    return mat3(
        4/3, -2/3, 0,
        -2/3, 32/15, -6/5,
        0, -6/3, 9/5
    )
end

function mat3.upascal()
    return mat3(
        1, 1, 1,
        0, 1, 2,
        0, 0, 1
    )
end

function mat3.lpascal()
    return mat3(
        1, 0, 0,
        1, 1, 0,
        1, 2, 1
    )
end

function mat3.spascal()
    return mat3(
        1, 1, 1,
        1, 2, 3,
        1, 3, 6
    )
end

function mat3.shiftup()
    return mat3(
        0, 1, 0,
        0, 0, 1,
        0, 0, 0
    )
end

function mat3.shiftdown()
    return mat3(
        0, 0, 0,
        1, 0, 0,
        0, 1, 0
    )
end

function mat3.fromYaw(theta)
    assertParams(isnum(theta), "fromYaw", "theta", "is not a number nor a mat3")

    local c, s = cos(theta), sin(theta)
    return mat3(
        c, 0, s,
        0, 1, 0,
        -s, 0, c
    )
end

function mat3.fromRoll(theta)
    assertParams(isnum(theta), "fromRoll", "theta", "is not a number nor a mat3")

    local c, s = cos(theta), sin(theta)
    return mat3(
        c, -s, 0,
        s, c, 0,
        0, 0, 1
    )
end

function mat3.fromSpherical(radius, theta, phi)
    assertParams(isnum(radius), "fromSpherical", "radius", "is not a number nor a mat3")
    assertParams(isnum(theta), "fromSpherical", "theta", "is not a number nor a mat3")
    assertParams(isnum(phi), "fromSpherical", "phi", "is not a number nor a mat3")

    local ct, st = cos(theta), sin(theta)
    local cp, sp = cos(phi), sin(phi)
    return mat3(
        st*cp, radius*ct*cp, -radius*st*sp,
        st*sp, radius*ct*sp, radius*st*cp,
        ct, -radius*st, 0
    )
end

function mat3.__call(t, aa, ab, ac, ba, bb, bc, ca, cb, cc)
    assertParams(isnum(aa) or aa == nil or ismat3(v), "__call", "aa", "is not a number")
    assertParams(isnum(ab) or ab == nil, "__call", "ab", "is not a number")
    assertParams(isnum(ac) or ac == nil, "__call", "ac", "is not a number")
    assertParams(isnum(ba) or ba == nil, "__call", "ba", "is not a number")
    assertParams(isnum(bb) or bb == nil, "__call", "bb", "is not a number")
    assertParams(isnum(bc) or bc == nil, "__call", "bc", "is not a number")
    assertParams(isnum(ca) or ca == nil, "__call", "ca", "is not a number")
    assertParams(isnum(cb) or cb == nil, "__call", "cb", "is not a number")
    assertParams(isnum(cc) or cc == nil, "__call", "cc", "is not a number")
    local m = ffi.new("mat3")
    local ms = m.set
    local m0, m1, m2 = ms[0], ms[1], ms[2]
    if(ismat3(v)) then
        local as = aa.set
        local a0, a1, a2 = as[0], as[1], as[2]
        m0[0] = a0[0]
        m0[1] = a0[1]
        m0[2] = a0[2]

        m1[0] = a1[0]
        m1[1] = a1[1]
        m1[2] = a1[2]

        m2[0] = a2[0]
        m2[1] = a2[1]
        m2[2] = a2[2]
    else 
        m0[0] = aa or 0
        m0[1] = ab or 0
        m0[2] = ac or 0

        m1[0] = ba or 0
        m1[1] = bb or 0
        m1[2] = bc or 0

        m2[0] = ca or 0
        m2[1] = cb or 0
        m2[2] = cc or 0
    end 
    return m
end

function mat3.is(m)
    return ismat3(m)
end

function mat3.row(m, r)
    assertParams(ismat3(m), "row", "m", "is not a mat3")
    assertParams(isnum(r), "row", "r", "is not a number")
    local ms = m.set
    return ms[r][0], ms[r][1], ms[r][2]
end

function mat3.col(m, c)
    assertParams(ismat3(m), "col", "m", "is not a mat3")
    assertParams(isnum(c), "col", "c", "is not a number")
    local ms = m.set
    return ms[0][c], ms[1][c], ms[2][c]
end

return mat3