local sphere = require "math.shape3d.sphere"

local shapes = {}
setmetatable(shapes, shapes)


return {
    sphere = sphere
}