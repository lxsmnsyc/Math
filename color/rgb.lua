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

local function overlay(a, b)
    if(a < 0.5) then
        return 2*a*b
    end
    return 1 - 2*(1 - a)*(1 - b)
end


function rgb.overlay(a, b)

    local ar, ag, ab = a.x, a.y, a.z
    local br, bg, bb = b.x, b.y, b.z

    return vec3(overlay(ar, br), overlay(ag, bg), overlay(ab, bb))
end

local function softlightPS(a, b)
    if(b < 0.5) then
        return 2*a*b + a*a*(1 - 2*b)
    end
    return 2*a*(1 - b) + sqrt(a)*(2*b - 1)
end

function rgb.softlightPS(a, b)
    local ar, ag, ab = a.x, a.y, a.z
    local br, bg, bb = b.x, b.y, b.z
    return vec3(softlightPS(ar, br), softlightPS(ag, bg), softlightPS(ab, bb))
end

function rgb.softlightPT(a, b)
    return (1 - 2*b)*a*a + 2*b*a
end

local function softlightIH(a, b)
    return a^(2^(2^(0.5 - b)))
end

function rgb.softlightIH(a, b)
    local ar, ag, ab = a.x, a.y, a.z
    local br, bg, bb = b.x, b.y, b.z
    return vec3(softlightIH(ar, br), softlightIH(ag, bg), softlightIH(ab, bb))
end 
return rgb

