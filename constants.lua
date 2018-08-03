-- all constants are provided by the OEIS or 
-- the On-Line Encyclopedia of Integer Sequences 
-- (https://oeis.org)

-- pi
-- https://en.wikipedia.org/wiki/Pi
-- https://oeis.org/A000796
local PI    = 3.14159265358979323846264

-- base of natural logarithm
-- https://en.wikipedia.org/wiki/E_(mathematical_constant)
-- https://oeis.org/A001113
local E     = 2.71828182845904523536028

-- golden ratio
-- https://en.wikipedia.org/wiki/Golden_ratio
-- https://oeis.org/A001622
local PHI   = 1.618033988749894848204586

-- square root of 2
-- https://en.wikipedia.org/wiki/Square_root_of_2
-- https://oeis.org/A002193
local PYTHAGORAS = 1.41421356237309504880168

-- square root of 3
-- https://en.wikipedia.org/wiki/Square_root_of_3
-- https://oeis.org/A002194
local THEODORUS = 1.73205080756887729352744

-- square root of 5
-- https://en.wikipedia.org/wiki/Square_root_of_5
-- https://oeis.org/A002163
local SQRT_OF_5 = 2.23606797749978969640917

-- Golden Angle
-- https://en.wikipedia.org/wiki/Golden_angle
-- https://oeis.org/A096627
local GOLDEN_ANGLE = 137.50776405003785464634873

-- https://oeis.org/A131988
local GOLDEN_RADIAN =  2.39996322972865332223155

return {
    PI = PI, 
    E = E, 
    PHI = PHI, 
    PYTHAGORAS = PYTHAGORAS,
    SQRT_OF_2 = PYTHAGORAS,
    THEODORUS = THEODORUS,
    SQRT_OF3 =  THEODORUS,
    SQRT_OF_5 = SQRT_OF_5,
    GOLDEN_ANGLE = GOLDEN_ANGLE,
    GOLDEN_RADIAN = GOLDEN_RADIAN
}