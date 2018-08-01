
local ffi = require "ffi"

ffi.cdef[[
    typedef struct{
        float set[2][2];
    } mat2;
]]

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
    assertParams(isnum(ab) or aa == nil, "new", "ab", "is not a number")
    assertParams(isnum(ba) or aa == nil, "new", "ba", "is not a number")
    assertParams(isnum(bb) or aa == nil, "new", "bb", "is not a number")
    local m = ffi.new("mat2")
    if(ismat2(v)) then
        m.set[0][0] = aa.set[0][0]
        m.set[0][1] = aa.set[0][1]
        m.set[1][0] = aa.set[1][0]
        m.set[1][1] = aa.set[1][1]
    else 
        m.set[0][0] = aa or 0
        m.set[0][1] = ab or 0
        m.set[1][0] = ba or 0
        m.set[1][1] = bb or 0
    end 
    return m
end

function mat2.compare(a, b, comp)
    local ima, imb, ina, inb = ismat2(a), ismat2(b), isnum(a), isnum(b)
    assertParams(ima or ina, "compare", "a", "is not a number nor a mat2")
    assertParams(imb or inb, "compare", "b", "is not a number nor a mat2")
    
    if(ima) then
        if(imb) then
            return mat2(
                comp(a.set[0][0], b.set[0][0]), comp(a.set[0][1], b.set[0][1]),
                comp(a.set[1][0], b.set[1][0]), comp(a.set[1][1], b.set[1][1])
            )
        elseif(inb) then
            return mat2(
                comp(a.set[0][0], b), comp(a.set[0][1], b),
                comp(a.set[1][0], b), comp(a.set[1][1], b)
            )
        end
    elseif(imb and ina) then
        return mat2(
            comp(a, b.set[0][0]), comp(a, b.set[0][1]),
            comp(a, b.set[1][0]), comp(a, b.set[1][1])
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

function mat2.__unm(a)
    assertParams(ismat2(a), "__sub", "a", "is not a a mat2")
    return mat2(
        a.set[0][0], a.set[0][1],
        a.set[1][0], a.set[1][1]
    )
end

function mat2.__mul(a, b)
    local ima, imb, ina, inb = ismat2(a), ismat2(b), isnum(a), isnum(b)
    assertParams(ima or ina or iva, "__mul", "a", "is not a number, a vec2 nor a mat2")
    assertParams(imb or inb or ivb, "__mul", "b", "is not a number, a vec2 nor a mat2")

    if(ima) then
        if(imb) then
            return mat2(
                a.set[0][0]*b.set[0][0] + a.set[0][1]*b.set[1][0], a.set[0][0]*b.set[0][1] + a.set[0][1]*b.set[1][1],
                a.set[1][0]*b.set[0][0] + a.set[1][1]*b.set[1][0], a.set[1][0]*b.set[0][1] + a.set[1][1]*b.set[1][1]
            )
        elseif(inb) then
            return mat2(
                a.set[0][0]*b, a.set[0][1]*b,
                a.set[1][0]*b, a.set[1][1]*b
            )
        end 
    elseif(imb and ina) then
        return mat2(
            a*b.set[0][0], a*b.set[0][1],
            a*b.set[1][0], a*b.set[1][1]
        )
    end
    return mat2()
end

function mat2.__tostring(m)
    assertParams(ismat2(m), "__tostring", "m", "is not a mat2")
    return "mat2("..m.set[0][0]..", "..m.set[0][1]..", "..m.set[1][0]..", "..m.set[1][1]..")"
end

function mat2.transpose(m)
    assertParams(ismat2(m), "transpose", "m", "is not a mat2")

    return mat2(
        m.set[0][0], m.set[1][0],
        m.set[0][1], m.set[1][1]
    )
end 

function mat2.determinant(m)
    assertParams(ismat2(m), "determinant", "m", "is not a mat2")

    return m.set[0][0]*m.set[1][1] - m.set[0][1]*m.set[1][0]
end 

function mat2.inverse(m)
    assertParams(ismat2(m), "inverse", "m", "is not a mat2")
    return (1/mat2.determinant(m)) * mat2(a.set[1][1], -a.set[0][1], -a.set[1][0], a.set[0][0])
end

function mat2.__call(t, aa, ab, ba, bb)
    return new(aa, ab, ba, bb)
end

return mat2