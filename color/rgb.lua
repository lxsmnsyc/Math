local vec3 = require "math.vector.vec.vec3"

local isvec = vec3.is

local rgb = {}

local function assertParams(act, method, param, msg)
    assert(act, "triangle2."..method..": parameter \""..param.."\" "..msg)
end


function rgb.multiply(a, b)
    return a * b 
end 

function rgb.screen(a, b)
    return 1 - (1 - a)*(1 - b)
end

return vec3

