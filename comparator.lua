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

function comparator:eq(a, b)
    return self.comp(a, b) == 0
end 

function comparator:lt(a, b)
    return self.comp(a, b) < 0;
end

function comparator:gt(a, b)
    return self.comp(a, b) > 0;
end

function comparator:le(a, b)
    return self.comp(a, b) <= 0;
end

function comparator:ge(a, b)
    return self.comp(a, b) >= 0;
end


function comparator:ne(a, b)
    return self.comp(a,b) ~= 0;
end

return comparator