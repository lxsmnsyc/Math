
local ffi = require "ffi"

local cos, sin, max, abs = math.cos, math.sin, math.max, math.abs

ffi.cdef[[
    typedef struct{
        double set[2][2];
    } dmat2;
]]

local EPSILON = 0.000001;

local function exactEqual(a, b)
    return abs(a - b) <= EPSILON*max(1.0, max(abs(a), abs(b)))
end

local function assertParams(act, method, param, msg)
    assert(act, "dmat2."..method..": parameter \""..param.."\" "..msg)
end

local dmat2 = {}
setmetatable(dmat2, dmat2)

ffi.metatype("dmat2", dmat2)

local function isnum(v)
    return type(v) == "number"
end

local function isdmat2(v)
    return ffi.istype("dmat2", v)
end

local function new(aa, ab, ba, bb)
    assertParams(isnum(aa) or aa == nil or isdmat2(v), "new", "aa", "is not a number")
    assertParams(isnum(ab) or ab == nil, "new", "ab", "is not a number")
    assertParams(isnum(ba) or ba == nil, "new", "ba", "is not a number")
    assertParams(isnum(bb) or bb == nil, "new", "bb", "is not a number")
    local m = ffi.new("dmat2")
    local ms = m.set
    local m0, m1 = ms[0], ms[1]
    if(isdmat2(v)) then
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

function dmat2.compare(a, b, comp)
    local ima, imb, ina, inb = isdmat2(a), isdmat2(b), isnum(a), isnum(b)
    assertParams(ima or ina, "compare", "a", "is not a number nor a dmat2")
    assertParams(imb or inb, "compare", "b", "is not a number nor a dmat2")
    
    if(ima) then
        if(imb) then
            local as, bs = a.set, b.set
            local a0, a1, b0, b1 = as[0], as[1], bs[0], bs[1]
            return dmat2(
                comp(a0[0], b0[0]), comp(a0[1], b0[1]),
                comp(a1[0], b1[0]), comp(a1[1], b1[1])
            )
        elseif(inb) then
            local as = a.set
            local a0, a1= as[0], as[1]
            return dmat2(
                comp(a0[0], b), comp(a0[1], b),
                comp(a1[0], b), comp(a1[1], b)
            )
        end
    elseif(imb and ina) then
        local bs = b.set
        local b0, b1 = bs[0], bs[1]
        return dmat2(
            comp(a, b0[0]), comp(a, b0[1]),
            comp(a, b1[0]), comp(a, b1[1])
        )
    end

    return dmat2()
end

local function add(a, b) return a + b end
local function sub(a, b) return a - b end 
local function mul(a, b) return a * b end
local function div(a, b) return a / b end
local function pow(a, b) return a ^ b end

function dmat2.__add(a, b)
    assertParams(isdmat2(a) or isnum(a), "__add", "a", "is not a number nor a dmat2")
    assertParams(isdmat2(b) or isnum(b), "__add", "b", "is not a number nor a dmat2")
    return dmat2.compare(a, b, add)
end 

function dmat2.__sub(a, b)
    assertParams(isdmat2(a) or isnum(a), "__sub", "a", "is not a number nor a dmat2")
    assertParams(isdmat2(b) or isnum(b), "__sub", "b", "is not a number nor a dmat2")
    return dmat2.compare(a, b, sub)
end 

function dmat2.__eq(a, b)
    assertParams(isdmat2(a) or isnum(a), "__eq", "a", "is not a number nor a dmat2")
    assertParams(isdmat2(b) or isnum(b), "__eq", "b", "is not a number nor a dmat2")
    if(isdmat2(a)) then
        local as = a.set
        local a0, a1= as[0], as[1]
        if(isnum(b)) then
            return  exactEqual(a0[0], b) and exactEqual(a0[1], b) and 
                    exactEqual(a1[0], b) and exactEqual(a1[1], b)
        elseif(isdmat2(b)) then
            local bs = b.set
            local b0, b1 = bs[0], bs[1]
            return  exactEqual(a0[0], b0[0]) and exactEqual(a0[1], b0[1]) and 
                    exactEqual(a1[0], b1[0]) and exactEqual(a1[1], b1[1])
        end
    elseif(isdmat2(b) and isnum(a)) then
        local bs = b.set
        local b0, b1 = bs[0], bs[1]
        return  exactEqual(a, b0[0]) and exactEqual(a, b0[1]) and 
                exactEqual(a, b1[0]) and exactEqual(a, b1[1])
    end
    return false
end 

function dmat2.__unm(a)
    assertParams(isdmat2(a), "__unm", "a", "is not a a dmat2")
    local as = a.set
    local a0, a1= as[0], as[1]
    return dmat2(
        -a0[0], -a0[1],
        -a1[0], -a1[1]
    )
end

function dmat2.dot(a, b, r, c)
    assertParams(isdmat2(a), "dot", "a", "is not a dmat2")
    assertParams(isdmat2(b), "dot", "b", "is not a dmat2")
    assertParams(isnum(r), "dot", "r", "is not a number")
    assertParams(isnum(c), "dot", "c", "is not a number")

    local as, bs = a.set, b.set
    local ar = as[r]
    return ar[0]*b[0][c] + ar[1]*b[1][c]
end

function dmat2.__mul(a, b)
    local ima, imb, ina, inb = isdmat2(a), isdmat2(b), isnum(a), isnum(b)
    assertParams(ima or ina, "__mul", "a", "is not a number, a vec2 nor a dmat2")
    assertParams(imb or inb, "__mul", "b", "is not a number, a vec2 nor a dmat2")

    if(ima) then
        if(imb) then
            local as, bs = a.set, b.set
            local a0, a1, b0, b1 = as[0], as[1], bs[0], bs[1]
            local a00, a01, a10, a11 = a0[0], a0[1], a1[0], a1[1]
            local b00, b01, b10, b11 = b0[0], b0[1], b1[0], b1[1]
            return dmat2(
                a00*b00 + a01*b10, a00*b01 + a01*b11,
                a10*b00 + a11*b10, a10*b01 + a11*b11
            )
        elseif(inb) then
            local as = a.set
            local a0, a1= as[0], as[1]
            return dmat2(
                a0[0]*b, a0[1]*b,
                a1[0]*b, a1[1]*b
            )
        end 
    elseif(imb and ina) then
        local bs = b.set
        local b0, b1 = bs[0], bs[1]
        return dmat2(
            a*b0[0], a*b0[1],
            a*b1[0], a*b1[1]
        )
    end
    return dmat2()
end

function dmat2.mulComp(a, b)
    assertParams(isdmat2(a) or isnum(a), "mulComp", "a", "is not a number nor a dmat2")
    assertParams(isdmat2(b) or isnum(b), "mulComp", "b", "is not a number nor a dmat2")
    return dmat2.compare(a, b, mul)
end


function dmat2.__tostring(m)
    assertParams(isdmat2(m), "__tostring", "m", "is not a dmat2")
    return "dmat2("..m.set[0][0]..", "..m.set[0][1]..", "..m.set[1][0]..", "..m.set[1][1]..")"
end

function dmat2.transpose(m)
    assertParams(isdmat2(m), "transpose", "m", "is not a dmat2")
    
    local ms = m.set
    local m0, m1= ms[0], ms[1]
    return dmat2(
        m0[0], m1[0],
        m0[1], m1[1]
    )
end 

function dmat2.determinant(m)
    assertParams(isdmat2(m), "determinant", "m", "is not a dmat2")
    local ms = m.set
    local m0, m1= ms[0], ms[1]
    return m0[0]*m1[1] - m0[1]*m1[0]
end 

function dmat2.adjugate(m)
    assertParams(isdmat2(m), "adjugate", "m", "is not a dmat2")
    local ms = m.set
    local m0, m1= ms[0], ms[1]
    return dmat2(
        m1[1], -m0[1], 
        -m1[0], m0[0]
    )
end

function dmat2.inverse(m)
    assertParams(isdmat2(m), "inverse", "m", "is not a dmat2")
    local ms = m.set
    local m0, m1= ms[0], ms[1]
    local deter = dmat2.determinant(m)
    assertParams(not exactEqual(deter, 0), "inverse", "m", "has a zero determinant")
    return (1/deter) * dmat2.adjugate(m)
end

function dmat2.__div(a, b)
    assertParams(isdmat2(a) or isnum(a), "__div", "a", "is not a number nor a dmat2")
    assertParams(isdmat2(b) or isnum(b), "__div", "b", "is not a number nor a dmat2")
    return dmat2.inverse(b) * a
end

function dmat2.__pow(a, b)
    assertParams(isdmat2(a) or isnum(a), "__sub", "a", "is not a number nor a dmat2")
    assertParams(isdmat2(b) or isnum(b), "__sub", "b", "is not a number nor a dmat2")
    return dmat2.compare(a, b, pow)
end 

function dmat2.divComp(a, b)
    assertParams(isdmat2(a) or isnum(a), "divComp", "a", "is not a number nor a dmat2")
    assertParams(isdmat2(b) or isnum(b), "divComp", "b", "is not a number nor a dmat2")
    assertParams(isdmat2(b) or isnum(b) and not exactEqual(b, 0), "divComp", "b", "cannot be used to divide \"a\"")
    return dmat2.compare(a, b, div)
end 

function dmat2.fromRotation(rad)
    assertParams(isnum(rad), "fromRotation", "rad", "is not a number")
    local c, s = cos(rad), sin(rad)
    return dmat2(
        c, -s,
        s, c
    )
end

function dmat2.identity()
    return dmat2(
        1, 0,
        0, 1
    )
end

function dmat2.exchange()
    return dmat2(
        0, 1,
        1, 0
    )
end 

function dmat2.hilbert()
    return dmat2(
        1, 1/2,
        1/2, 1/3
    )
end

function dmat2.lehmer()
    return dmat2(
        1, 1/2,
        1/2, 1
    )
end 

function dmat2.ilehmer()
    return dmat2(
        4/3, -2/3,
        -2/3, 4/3
    )
end

function dmat2.upascal()
    return dmat2(
        1, 1,
        0, 1
    )
end

function dmat2.lpascal()
    return dmat2(
        1, 0,
        1, 1
    )
end

function dmat2.spascal()
    return dmat2(
        1, 1,
        1, 2
    )
end


function dmat2.shiftup()
    return dmat2(
        0, 1,
        0, 0
    )
end

function dmat2.shiftdown()
    return dmat2(
        0, 0,
        1, 0
    )
end

function dmat2.__call(t, aa, ab, ba, bb)
    return new(aa, ab, ba, bb)
end

function dmat2.is(m)
    return isdmat2(m)
end

function dmat2.row(m, r)
    assertParams(isdmat2(m), "row", "m", "is not a dmat2")
    assertParams(isnum(r), "row", "r", "is not a number")
    local ms = m.set
    return ms[r][0], ms[r][1]
end

function dmat2.col(m, c)
    assertParams(isdmat2(m), "col", "m", "is not a dmat2")
    assertParams(isnum(c), "col", "c", "is not a number")
    local ms = m.set
    return ms[0][c], ms[1][c]
end




return dmat2