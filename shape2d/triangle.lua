local vec2 = require "math.vector.vec.vec2"
local mat2 = require "math.matrix.mat.mat2"
local ffi = require "ffi"

local isvec = vec2.is
local length = vec2.length

local sqrt = math.sqrt

ffi.cdef[[
    typedef struct {
        vec2 a, b, c;
    } triangle2;
]]

local triangle2 = {}
setmetatable(triangle2, triangle2)

ffi.metatype("triangle2", triangle2)

local function isnum(v)
    return type(v) == "number"
end

local function istriangle2(v)
    return ffi.istype("triangle2", v)
end

local function assertParams(act, method, param, msg)
    assert(act, "triangle2."..method..": parameter \""..param.."\" "..msg)
end

function triangle2.__call(t, a, b, c)
    assertParams(isvec(a) or a == nil, "__call", "a", "is not a vec2")
    assertParams(isvec(b) or b == nil, "__call", "b", "is not a vec2")
    assertParams(isvec(c) or c == nil, "__call", "c", "is not a vec2")
    return ffi.new("triangle2", a or vec(), b or vec(), c or vec())
end

function triangle2.incenter(t)
    assertParams(istriangle2(t), "incenter", "t", "is not a triangle2")
    local P1, P2, P3 = t.a, t.b, t.c
    local A, B, C = P2 - P1, P3 - P2, P1 - P3 
    local a, b, c = length(A), length(B), length(C)
    local sum = a + b + c
    local s = sum/2
    return (b*P1 + c*P2 + a*P3) / sum, sqrt((s - a)*(s - b)*(s - c)/s)
end


function triangle2.centroid(t)
    assertParams(istriangle2(t), "centroid", "t", "is not a triangle2")
    local A, B, C = t.a, t.b, t.c
    return (A + B + C)/3
end

function triangle2.__mul(a, b)
    assertParams(isvec(a) or ismat(a), "__mul", "a", "is not a vec2 nor a mat2")
    assertParams(isvec(b) or ismat(b), "__mul", "b", "is not a vec2 nor a mat2")

end 

return triangle