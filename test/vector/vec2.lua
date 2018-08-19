local vec2 = require "math.vector.vec2"

local a = vec2(0, 0)
assert(a:isZero(), "a is a zero vector")

local b = vec2(1, 1)
a:assign(b)
assert(a == b, "a is equal to b")

local c = a + b
assert(c:eq(vec2(1, 1)))