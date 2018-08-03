
local ffi = require "ffi"

local cos, sin, max, abs = math.cos, math.sin, math.max, math.abs

ffi.cdef[[
    typedef struct{
        float set[2][2];
    } mat2;
]]

local EPSILON = 0.000001;

local function exactEqual(a, b)
    return abs(a - b) <= EPSILON*max(1.0, max(abs(a), abs(b)))
end

local function assertParams(act, method, param, msg)
    assert(act, "mat2."..method..": parameter \""..param.."\" "..msg)
end

local mat2 = {}
setmetatable(mat2, mat2)

ffi.metatype("mat2", mat2)

local function isnum(v)
    return type(v) == "number"
end

local function ismat2(v)
    return ffi.istype("mat2", v)
end

local function new(aa, ab, ba, bb)
    assertParams(isnum(aa) or aa == nil or ismat2(v), "new", "aa", "is not a number")
    assertParams(isnum(ab) or ab == nil, "new", "ab", "is not a number")
    assertParams(isnum(ba) or ba == nil, "new", "ba", "is not a number")
    assertParams(isnum(bb) or bb == nil, "new", "bb", "is not a number")
    local m = ffi.new("mat2")
    local ms = m.set
    local m0, m1 = ms[0], ms[1]
    if(ismat2(v)) then
        local as = aa.set
        local a0, a1 = as[0], as[1]
        m0[0] = a0[0]
        m0[1] = a0[1]
        m1[0] = a1[0]
        m1[1] = a1[1]
    else 
        m0[0] = aa or 0
        m0[1] = ab or 0
        m1[0] = ba or 0
        m1[1] = bb or 0
    end 
    return m
end

function mat2.compare(a, b, comp)
    local ima, imb, ina, inb = ismat2(a), ismat2(b), isnum(a), isnum(b)
    assertParams(ima or ina, "compare", "a", "is not a number nor a mat2")
    assertParams(imb or inb, "compare", "b", "is not a number nor a mat2")
    
    if(ima) then
        if(imb) then
            local as, bs = a.set, b.set
            local a0, a1, b0, b1 = as[0], as[1], bs[0], bs[1]
            return mat2(
                comp(a0[0], b0[0]), comp(a0[1], b0[1]),
                comp(a1[0], b1[0]), comp(a1[1], b1[1])
            )
        elseif(inb) then
            local as = a.set
            local a0, a1= as[0], as[1]
            return mat2(
                comp(a0[0], b), comp(a0[1], b),
                comp(a1[0], b), comp(a1[1], b)
            )
        end
    elseif(imb and ina) then
        local bs = b.set
        local b0, b1 = bs[0], bs[1]
        return mat2(
            comp(a, b0[0]), comp(a, b0[1]),
            comp(a, b1[0]), comp(a, b1[1])
        )
    end

    return mat2()
end

local function add(a, b) return a + b end
local function sub(a, b) return a - b end 
local function mul(a, b) return a * b end
local function div(a, b) return a / b end
local function pow(a, b) return a ^ b end

function mat2.__add(a, b)
    assertParams(ismat2(a) or isnum(a), "__add", "a", "is not a number nor a mat2")
    assertParams(ismat2(b) or isnum(b), "__add", "b", "is not a number nor a mat2")
    return mat2.compare(a, b, add)
end 

function mat2.__sub(a, b)
    assertParams(ismat2(a) or isnum(a), "__sub", "a", "is not a number nor a mat2")
    assertParams(ismat2(b) or isnum(b), "__sub", "b", "is not a number nor a mat2")
    return mat2.compare(a, b, sub)
end 

function mat2.__eq(a, b)
    assertParams(ismat2(a) or isnum(a), "__eq", "a", "is not a number nor a mat2")
    assertParams(ismat2(b) or isnum(b), "__eq", "b", "is not a number nor a mat2")
    if(ismat2(a)) then
        local as = a.set
        local a0, a1= as[0], as[1]
        if(isnum(b)) then
            return  exactEqual(a0[0], b) and exactEqual(a0[1], b) and 
                    exactEqual(a1[0], b) and exactEqual(a1[1], b)
        elseif(ismat2(b)) then
            local bs = b.set
            local b0, b1 = bs[0], bs[1]
            return  exactEqual(a0[0], b0[0]) and exactEqual(a0[1], b0[1]) and 
                    exactEqual(a1[0], b1[0]) and exactEqual(a1[1], b1[1])
        end
    elseif(ismat2(b) and isnum(a)) then
        local bs = b.set
        local b0, b1 = bs[0], bs[1]
        return  exactEqual(a, b0[0]) and exactEqual(a, b0[1]) and 
                exactEqual(a, b1[0]) and exactEqual(a, b1[1])
    end
    return false
end 

function mat2.__unm(a)
    assertParams(ismat2(a), "__unm", "a", "is not a a mat2")
    local as = a.set
    local a0, a1= as[0], as[1]
    return mat2(
        -a0[0], -a0[1],
        -a1[0], -a1[1]
    )
end

function mat2.dot(a, b, r, c)
    assertParams(ismat2(a), "dot", "a", "is not a mat2")
    assertParams(ismat2(b), "dot", "b", "is not a mat2")
    assertParams(isnum(r), "dot", "r", "is not a number")
    assertParams(isnum(c), "dot", "c", "is not a number")

    local as, bs = a.set, b.set
    local ar = as[r]
    return ar[0]*b[0][c] + ar[1]*b[1][c]
end

function mat2.__mul(a, b)
    local ima, imb, ina, inb = ismat2(a), ismat2(b), isnum(a), isnum(b)
    assertParams(ima or ina, "__mul", "a", "is not a number, a vec2 nor a mat2")
    assertParams(imb or inb, "__mul", "b", "is not a number, a vec2 nor a mat2")

    if(ima) then
        if(imb) then
            local as, bs = a.set, b.set
            local a0, a1, b0, b1 = as[0], as[1], bs[0], bs[1]
            local a00, a01, a10, a11 = a0[0], a0[1], a1[0], a1[1]
            local b00, b01, b10, b11 = b0[0], b0[1], b1[0], b1[1]
            return mat2(
                a00*b00 + a01*b10, a00*b01 + a01*b11,
                a10*b00 + a11*b10, a10*b01 + a11*b11
            )
        elseif(inb) then
            local as = a.set
            local a0, a1= as[0], as[1]
            return mat2(
                a0[0]*b, a0[1]*b,
                a1[0]*b, a1[1]*b
            )
        end 
    elseif(imb and ina) then
        local bs = b.set
        local b0, b1 = bs[0], bs[1]
        return mat2(
            a*b0[0], a*b0[1],
            a*b1[0], a*b1[1]
        )
    end
    return mat2()
end

function mat2.mulComp(a, b)
    assertParams(ismat2(a) or isnum(a), "mulComp", "a", "is not a number nor a mat2")
    assertParams(ismat2(b) or isnum(b), "mulComp", "b", "is not a number nor a mat2")
    return mat2.compare(a, b, mul)
end


function mat2.__tostring(m)
    assertParams(ismat2(m), "__tostring", "m", "is not a mat2")
    return "mat2("..m.set[0][0]..", "..m.set[0][1]..", "..m.set[1][0]..", "..m.set[1][1]..")"
end

function mat2.transpose(m)
    assertParams(ismat2(m), "transpose", "m", "is not a mat2")
    
    local ms = m.set
    local m0, m1= ms[0], ms[1]
    return mat2(
        m0[0], m1[0],
        m0[1], m1[1]
    )
end 

function mat2.determinant(m)
    assertParams(ismat2(m), "determinant", "m", "is not a mat2")
    local ms = m.set
    local m0, m1= ms[0], ms[1]
    return m0[0]*m1[1] - m0[1]*m1[0]
end 

function mat2.adjugate(m)
    assertParams(ismat2(m), "adjugate", "m", "is not a mat2")
    local ms = m.set
    local m0, m1= ms[0], ms[1]
    return mat2(
        m1[1], -m0[1], 
        -m1[0], m0[0]
    )
end

function mat2.inverse(m)
    assertParams(ismat2(m), "inverse", "m", "is not a mat2")
    local ms = m.set
    local m0, m1= ms[0], ms[1]
    return (1/mat2.determinant(m)) * mat2.adjugate(m)
end

function mat2.__div(a, b)
    assertParams(ismat2(a) or isnum(a), "__div", "a", "is not a number nor a mat2")
    assertParams(ismat2(b) or isnum(b), "__div", "b", "is not a number nor a mat2")
    return mat2.inverse(b) * a
end

function mat2.__pow(a, b)
    assertParams(ismat2(a) or isnum(a), "__sub", "a", "is not a number nor a mat2")
    assertParams(ismat2(b) or isnum(b), "__sub", "b", "is not a number nor a mat2")
    return mat2.compare(a, b, pow)
end 

function mat2.divComp(a, b)
    assertParams(ismat2(a) or isnum(a), "divComp", "a", "is not a number nor a mat2")
    assertParams(ismat2(b) or isnum(b), "divComp", "b", "is not a number nor a mat2")
    assertParams(ismat2(b) or isnum(b) and b ~= 0, "divComp", "b", "cannot be used to divide \"a\"")
    return mat2.compare(a, b, div)
end 

function mat2.fromRotation(rad)
    assertParams(isnum(rad), "fromRotation", "rad", "is not a number")
    local c, s = cos(rad), sin(rad)
    return mat2(
        c, -s,
        s, c
    )
end

function mat2.identity()
    return mat2(
        1, 0,
        0, 1
    )
end

function mat2.exchange()
    return mat2(
        0, 1,
        1, 0
    )
end 

function mat2.hilbert()
    return mat2(
        1, 1/2,
        1/2, 1/3
    )
end

function mat2.lehmer()
    return mat2(
        1, 1/2,
        1/2, 1
    )
end 

function mat2.ilehmer()
    return mat2(
        4/3, -2/3,
        -2/3, 4/3
    )
end

function mat2.upascal()
    return mat2(
        1, 1,
        0, 1
    )
end

function mat2.lpascal()
    return mat2(
        1, 0,
        1, 1
    )
end

function mat2.spascal()
    return mat2(
        1, 1,
        1, 2
    )
end


function mat2.shiftup()
    return mat2(
        0, 1,
        0, 0
    )
end

function mat2.shiftdown()
    return mat2(
        0, 0,
        1, 0
    )
end

function mat2.__call(t, aa, ab, ba, bb)
    return new(aa, ab, ba, bb)
end


return mat2