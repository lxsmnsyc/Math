
local ffi = require "ffi"

local cos, sin, max, abs = math.cos, math.sin, math.max, math.abs

ffi.cdef[[
    typedef struct{
        float set[4][4];
    } mat4;
]]

local EPSILON = 0.000001;

local function exactEqual(a, b)
    return abs(a - b) <= EPSILON*max(1.0, max(abs(a), abs(b)))
end



local function assertParams(act, method, param, msg)
    assert(act, "mat4."..method..": parameter \""..param.."\" "..msg)
end

local mat4 = {}
setmetatable(mat4, mat4)

ffi.metatype("mat4", mat4)

local function isnum(v)
    return type(v) == "number"
end

local function ismat4(v)
    return ffi.istype("mat4", v)
end

function mat4.compare(a, b, comp)
    local ima, imb, ina, inb = ismat4(a), ismat4(b), isnum(a), isnum(b)
    assertParams(ima or ina, "compare", "a", "is not a number nor a mat4")
    assertParams(imb or inb, "compare", "b", "is not a number nor a mat4")
    
    if(ima) then
        if(imb) then
            local as, bs = a.set, b.set
            local a0, a1, a2, a3 = as[0], as[1], as[2], as[3]
            local b0, b1, b2, b3 = bs[0], bs[1], bs[2], bs[3]
            return mat4(
                comp(a0[0], b0[0]), comp(a0[1], b0[1]), comp(a0[2], b0[2]), comp(a0[3], b0[3]),
                comp(a1[0], b1[0]), comp(a1[1], b1[1]), comp(a1[2], b1[2]), comp(a1[3], b1[3]),
                comp(a2[0], b2[0]), comp(a2[1], b2[1]), comp(a2[2], b2[2]), comp(a2[3], b2[3]),
                comp(a3[0], b3[0]), comp(a3[1], b3[1]), comp(a3[2], b3[2]), comp(a3[3], b3[3])
            )
        elseif(inb) then
            local as = a.set
            local a0, a1, a2, a3 = as[0], as[1], as[2], as[3]
            return mat4(
                comp(a0[0], b), comp(a0[1], b), comp(a0[2], b), comp(a0[3], b),
                comp(a1[0], b), comp(a1[1], b), comp(a1[2], b), comp(a1[3], b),
                comp(a2[0], b), comp(a2[1], b), comp(a2[2], b), comp(a2[3], b),
                comp(a3[0], b), comp(a3[1], b), comp(a3[2], b), comp(a3[3], b)
            )
        end
    elseif(imb and ina) then
        local bs = b.set
        local b0, b1, b2, b3 = bs[0], bs[1], bs[2], bs[3]
        return mat4(
            comp(a, b0[0]), comp(a, b0[1]), comp(a, b0[2]), comp(a, b0[3]),
            comp(a, b1[0]), comp(a, b1[1]), comp(a, b1[2]), comp(a, b1[3]),
            comp(a, b2[0]), comp(a, b2[1]), comp(a, b2[2]), comp(a, b2[3]),
            comp(a, b3[0]), comp(a, b3[1]), comp(a, b3[2]), comp(a, b3[3])
        )
    end

    return mat4()
end

local function add(a, b) return a + b end
local function sub(a, b) return a - b end 
local function mul(a, b) return a * b end
local function div(a, b) return a / b end
local function pow(a, b) return a ^ b end

function mat4.__add(a, b)
    assertParams(ismat4(a) or isnum(a), "__add", "a", "is not a number nor a mat4")
    assertParams(ismat4(b) or isnum(b), "__add", "b", "is not a number nor a mat4")
    return mat4.compare(a, b, add)
end 

function mat4.__sub(a, b)
    assertParams(ismat4(a) or isnum(a), "__sub", "a", "is not a number nor a mat4")
    assertParams(ismat4(b) or isnum(b), "__sub", "b", "is not a number nor a mat4")
    return mat4.compare(a, b, sub)
end 

function mat4.__eq(a, b)
    assertParams(ismat4(a) or isnum(a), "__eq", "a", "is not a number nor a mat4")
    assertParams(ismat4(b) or isnum(b), "__eq", "b", "is not a number nor a mat4")
    if(ismat4(a)) then
        local as = a.set
        if(isnum(b)) then
            for c = 0, 3 do 
                local col = as[c]
                for r = 0, 3 do 
                    if(not exactEqual(col[r], b)) then return false end
                end
            end
            return true
        elseif(ismat4(b)) then
            local bs = b.set
            for c = 0, 3 do 
                local col1 = as[c]
                local col2 = bs[c]
                for r = 0, 3 do 
                    if(not exactEqual(col1[r], col2[r])) then return false end
                end
            end
            return true
        end
    elseif(ismat4(b) and isnum(a)) then
        local bs = b.set
        for c = 0, 3 do 
            local col = bs[c]
            for r = 0, 3 do 
                if(not exactEqual(a, col[r])) then return false end
            end
        end
        return true
    end
    return false
end 

function mat4.__unm(a)
    assertParams(ismat4(a), "__unm", "a", "is not a a mat4")
    local as = a.set
    local a0, a1, a2, a3 = as[0], as[1], as[2], as[3]
    return mat4(
        -a0[0], -a0[1], -a0[2], -a3[0],
        -a1[0], -a1[1], -a1[2], -a3[1],
        -a2[0], -a2[1], -a2[2], -a3[2],
        -a3[0], -a3[1], -a3[2], -a3[2]
    )
end

local function dot(a, b, c, e, f, g, h, i)
    return a*f + b*g + c*h + e*i
end

function mat4.dot(a, b, r, c)
    assertParams(ismat4(a), "dot", "a", "is not a mat4")
    assertParams(ismat4(b), "dot", "b", "is not a mat4")
    assertParams(isnum(r), "dot", "r", "is not a number")
    assertParams(isnum(c), "dot", "c", "is not a number")

    local as, bs = a.set, b.set
    local ar = as[r]
    return ar[0]*b[0][c] + ar[1]*b[1][c] + ar[2]*b[2][c] + ar[3]*b[3][c]
end

function mat4.__mul(a, b)
    local ima, imb, ina, inb = ismat4(a), ismat4(b), isnum(a), isnum(b)
    assertParams(ima or ina, "__mul", "a", "is not a number, a vec2 nor a mat4")
    assertParams(imb or inb, "__mul", "b", "is not a number, a vec2 nor a mat4")

    if(ima) then
        if(imb) then
            local as, bs = a.set, b.set
            local a0, a1, a2, a3 = as[0], as[1], as[2], as[3]
            local b0, b1, b2, b3 = bs[0], bs[1], bs[2], bs[3]

            local a00, a01, a02, a03 = a0[0], a0[1], a0[2], a0[3]
            local a10, a11, a12, a13 = a1[0], a1[1], a1[2], a1[3]
            local a20, a21, a22, a23 = a2[0], a2[1], a2[2], a2[3]
            local a30, a31, a32, a33 = a3[0], a3[1], a3[2], a3[3]

            local a00, b01, b02, b03 = b0[0], b0[1], b0[2], b0[3]
            local b10, b11, b12, b13 = b1[0], b1[1], b1[2], b1[3]
            local b20, b21, b22, b23 = b2[0], b2[1], b2[2], b2[3]
            local b30, b31, b32, b33 = b3[0], b3[1], b3[2], b3[3]

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
            local a0, a1, a2, a3 = as[0], as[1], as[2], as[3]
            return mat4(
                a0[0]*b, a0[1]*b, a0[2]*b, a0[3]*b,
                a1[0]*b, a1[1]*b, a1[2]*b, a1[3]*b,
                a2[0]*b, a2[1]*b, a2[2]*b, a2[3]*b,
                a3[0]*b, a3[1]*b, a3[2]*b, a3[3]*b
            )
        end 
    elseif(imb and ina) then
        local bs = b.set
        local b0, b1, b2, b3 = bs[0], bs[1], bs[2], bs[3]
        return mat4(
            a*b0[0], a*b0[1], a*b0[2], a*b0[3],
            a*b1[0], a*b1[1], a*b1[2], a*b1[3],
            a*b2[0], a*b2[1], a*b2[2], a*b2[3],
            a*b3[0], a*b3[1], a*b3[2], a*b3[3]
        )
    end
    return mat4()
end

function mat4.mulComp(a, b)
    assertParams(ismat4(a) or isnum(a), "mulComp", "a", "is not a number nor a mat4")
    assertParams(ismat4(b) or isnum(b), "mulComp", "b", "is not a number nor a mat4")
    return mat4.compare(a, b, mul)
end


function mat4.__tostring(m)
    assertParams(ismat4(m), "__tostring", "m", "is not a mat4")
    return "mat4("..
        m.set[0][0]..", "..m.set[0][1]..", "..m.set[0][2]..", "..m.set[0][3]..", "..
        m.set[1][0]..", "..m.set[1][1]..", "..m.set[1][2]..", "..m.set[1][3]..", "..
        m.set[2][0]..", "..m.set[2][1]..", "..m.set[2][2]..", "..m.set[2][3]..", "..
        m.set[3][0]..", "..m.set[3][1]..", "..m.set[3][2]..", "..m.set[3][3]
    ")"
end

function mat4.transpose(m)
    assertParams(ismat4(m), "transpose", "m", "is not a mat4")
    
    local ms = m.set
    local m0, m1, m2, m3 = ms[0], ms[1], ms[2], ms[3]
    return mat4(
        m0[0], m1[0], m2[0], m3[0],
        m0[1], m1[1], m2[1], m3[1],
        m0[2], m1[2], m2[2], m3[2],
        m0[3], m1[3], m2[3], m3[3]
    )
end 

local function det3(a, b, c, d, e, f, g, h, i)
    return a*e*i + b*f*g + c*d*h - c*e*g - b*d*i - a*f*h 
end

function mat4.determinant(x)
    assertParams(ismat4(x), "determinant", "x", "is not a mat4")
    local ms = x.set
    local m0, m1, m2, m3 = ms[0], ms[1], ms[2], ms[3]
    local a, b, c, d = m0[0], m0[1], m0[2], m0[3]
    local e, f, g, h = m1[0], m1[1], m1[2], m1[3]
    local i, j, k, l = m2[0], m2[1], m2[2], m2[3]
    local m, n, o, p = m3[0], m3[1], m3[2], m3[3]
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


function mat4.adjugate(x)
    assertParams(ismat4(x), "adjugate", "x", "is not a mat4")
    local ms = x.set
    local m0, m1, m2, m3 = ms[0], ms[1], ms[2], ms[3]
    local a, b, c, d = m0[0], m0[1], m0[2], m0[3]
    local e, f, g, h = m1[0], m1[1], m1[2], m1[3]
    local i, j, k, l = m2[0], m2[1], m2[2], m2[3]
    local m, n, o, p = m3[0], m3[1], m3[2], m3[3]
    local A, E, I, M = det3(f, g, h, j, k, l, n, o, p), -det3(b, c, d, j, k, l, n, o, p), det3(b, c, d, f, g, h, n, o, p), -det3(b, c, d, f, g, h, j, k, l)
    local B, F, J, N = -det3(e, g, h, i, k, l, m, o, p), det3(a, c, d, i, k, l, m, o, p), -det3(a, c, d, e, g, h, i, k, l), det3(a, c, d, e, g, h, i, k, l)
    local C, G, K, O = det3(e, f, h, i, j, l, m, n, p), -det3(a, b, d, i, j, l, m, n, p), det3(a, b, d, e, f, h, m, n, p), -det3(a, b, d, e, f, h, i, j, l)
    local D, H, L, P = -det3(e, f, g, i, j, k, m, n, o), det3(a, b, c, i, j, k, m, n, o), -det3(a, b, c, e, f, g, m, n, o), det3(a, b, d, e, f, g, i, j, k)
    return mat4(
        A, E, I, M,
        B, F, J, N,
        C, G, K, O,
        D, H, L, P
    )
end

function mat4.inverse(m)
    assertParams(ismat4(m), "inverse", "m", "is not a mat4")
    return (1/mat4.determinant(m)) * mat4.adjugate(m)
end

function mat4.__div(a, b)
    assertParams(ismat4(a) or isnum(a), "__div", "a", "is not a number nor a mat4")
    assertParams(ismat4(b) or isnum(b), "__div", "b", "is not a number nor a mat4")
    return mat4.inverse(b) * a
end

function mat4.__pow(a, b)
    assertParams(ismat4(a) or isnum(a), "__sub", "a", "is not a number nor a mat4")
    assertParams(ismat4(b) or isnum(b), "__sub", "b", "is not a number nor a mat4")
    return mat4.compare(a, b, pow)
end 

function mat4.divComp(a, b)
    assertParams(ismat4(a) or isnum(a), "divComp", "a", "is not a number nor a mat4")
    assertParams(ismat4(b) or isnum(b), "divComp", "b", "is not a number nor a mat4")
    assertParams(ismat4(b) or isnum(b) and b ~= 0, "divComp", "b", "cannot be used to divide \"a\"")
    return mat4.compare(a, b, div)
end 

function mat4.identity()
    return mat4(
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    )
end

function mat4.exchange()
    return mat4(
        0, 0, 0, 1,
        0, 0, 1, 0,
        0, 1, 0, 0,
        1, 0, 0, 0
    )
end

function mat4.hilbert()
    return mat4(
        1, 1/2, 1/3, 1/4,
        1/2, 1/3, 1/4, 1/5,
        1/3, 1/4, 1/5, 1/6,
        1/4, 1/5, 1/6, 1/7
    )
end

function mat4.lehmer()
    return mat4(
        1, 1/2, 1/3, 1/4,
        1/2, 1, 2/3, 1/2, 
        1/3, 2/3, 1, 3/4,
        1/4, 1/2, 3/4, 1
    )
end

function mat4.ilehmer()
    return mat4(
        4/3,    -2/3,   0,      0,
        -2/3,   32/15,  -6/5,   0,
        0,      -6/3,   9/5,    -12/7,
        0,      0,      -12/7,  16/7
    )
end

function mat4.upascal()
    return mat4(
        1, 1, 1, 1,
        0, 1, 2, 3,
        0, 0, 1, 3,
        0, 0, 0, 1
    )
end

function mat4.lpascal()
    return mat4(
        1, 0, 0, 0,
        1, 1, 0, 0,
        1, 2, 1, 0,
        1, 3, 3, 1
    )
end

function mat4.spascal()
    return mat4(
        1, 1, 1, 1,
        1, 2, 3, 4,
        1, 3, 6, 10,
        1, 4, 10, 20
    )
end

function mat4.shiftup()
    return mat4(
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
        0, 0, 0, 0
    )
end

function mat4.shiftdown()
    return mat4(
        0, 0, 0, 0,
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0
    )
end

function mat4.__call(t, aa, ab, ac, ad, ba, bb, bc, bd, ca, cb, cc, cd, da, db, dc, dd)
    assertParams(isnum(aa) or aa == nil or ismat4(v), "__call", "aa", "is not a number")
    assertParams(isnum(ab) or ab == nil, "__call", "ab", "is not a number")
    assertParams(isnum(ac) or ac == nil, "__call", "ac", "is not a number")
    assertParams(isnum(ad) or ad == nil, "__call", "ad", "is not a number")
    assertParams(isnum(ba) or ba == nil, "__call", "ba", "is not a number")
    assertParams(isnum(bb) or bb == nil, "__call", "bb", "is not a number")
    assertParams(isnum(bc) or bc == nil, "__call", "bc", "is not a number")
    assertParams(isnum(bd) or bd == nil, "__call", "bd", "is not a number")
    assertParams(isnum(ca) or ca == nil, "__call", "ca", "is not a number")
    assertParams(isnum(cb) or cb == nil, "__call", "cb", "is not a number")
    assertParams(isnum(cc) or cc == nil, "__call", "cc", "is not a number")
    assertParams(isnum(cd) or cd == nil, "__call", "cd", "is not a number")
    assertParams(isnum(da) or da == nil, "__call", "da", "is not a number")
    assertParams(isnum(db) or db == nil, "__call", "db", "is not a number")
    assertParams(isnum(dc) or dc == nil, "__call", "dc", "is not a number")
    assertParams(isnum(dd) or dd == nil, "__call", "dd", "is not a number")
    local m = ffi.new("mat4")
    local ms = m.set
    local m0, m1, m2, m3 = ms[0], ms[1], ms[2], ms[3]
    if(ismat4(v)) then
        local as = aa.set
        local a0, a1, a2, a3 = as[0], as[1], as[2], as[3]
        m0[0] = a0[0]
        m0[1] = a0[1]
        m0[2] = a0[2]
        m0[3] = a0[3]

        m1[0] = a1[0]
        m1[1] = a1[1]
        m1[2] = a1[2]
        m1[3] = a1[3]

        m2[0] = a2[0]
        m2[1] = a2[1]
        m2[2] = a2[2]
        m2[3] = a2[3]

        m3[0] = a3[0]
        m3[1] = a3[1]
        m3[2] = a3[2]
        m3[3] = a3[3]
    else 
        m0[0] = aa or 0
        m0[1] = ab or 0
        m0[2] = ac or 0
        m0[3] = ad or 0

        m1[0] = ba or 0
        m1[1] = bb or 0
        m1[2] = bc or 0
        m1[3] = bd or 0

        m2[0] = ca or 0
        m2[1] = cb or 0
        m2[2] = cc or 0
        m2[3] = cd or 0

        m3[0] = da or 0
        m3[1] = db or 0
        m3[2] = dc or 0
        m3[3] = dd or 0
    end 
    return m
end

return mat4