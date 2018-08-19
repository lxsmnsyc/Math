local comparator = {}

local function assertParams(act, method, param, msg)
    assert(act, "comparator."..method..": parameter \""..param.."\" "..msg)
end

local function defaultCompare(a, b)
    if(a == b) then return 0 end
    return (a < b) and 1 or -1
end

function comparator.new(c)
    assertParams(type(c) == "function", "new", "c", "is not a function.")
    local new = {comp = c or defaultCompare}
    setmetatable(new, comparator)
    return new 
end 

local function __eq(a, b)
    return self.comp(a, b) == 0
end 

local function __lt(a, b)
    return self.comp(a, b) < 0;
end

local function __gt(a, b)
    return self.comp(a, b) > 0;
end

local function __le(a, b)
    return self.comp(a, b) <= 0;
end

local function __ge(a, b)
    return self.comp(a, b) >= 0;
end


local function __ne(self, a, b)
    return self.comp(a,b) ~= 0;
end

comparator.eq = __eq
comparator.ne = __ne
comparator.lt = __lt 
comparator.gt = __gt
comparator.ge = __ge
comparator.le = __le 

return comparator