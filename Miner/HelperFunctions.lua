---@class HelperFunctions
HelperFunctions = {}
---help function: filter
---@param tbl table
---@param func function must return true | false
function HelperFunctions.filter(tbl, func, ...)
    local t = {}
    local i = 1
    for k, v in pairs(tbl) do
        if func(v, table.unpack(arg)) then
            t[i] = v;
            i = i + 1;
        end
    end
    return t
end

---help Function: map
---@param tbl table
---@param func function
function HelperFunctions.map(tbl, func, ...)
    local t = {}
    for k, v in pairs(tbl) do
        t[k] = func(v, table.unpack(arg))
    end
    return t
end

--- untested!
---@param tbl table
---@param leftIndex number Normaly 0
---@param rightIndex number Normaly tablelength
---@param func function null | function to check if bigger. return left > right only!
---@param ... unknown custom Parameters for your function
---@return table
function HelperFunctions.quickSort(tbl, leftIndex, rightIndex, func, ...)
    local i = leftIndex;
    local j = rightIndex;
    local pivot = tbl[leftIndex]
    while i <= j do
        if (type(func) == "function") then
            while func(pivot, tbl[i], table.unpack(arg)) do
                i = i + 1;
            end
            while func(tbl[j], pivot, table.unpack(arg)) do
                j = j - 1;
            end
        else
            while pivot > tbl[leftIndex] do
                i = i + 1;
            end
            while tbl[rightIndex] > pivot do
                j = j - 1;
            end
        end
        if i <= j then
            local tmp = tbl[i]
            tbl[i] = tbl[j]
            tbl[j] = tmp
            i = i + 1
            j = j - 1
        end
    end

    if (leftIndex < j) then
        HelperFunctions.quickSort(tbl, leftIndex, j, func, table.unpack(arg))
    end
    if (i < rightIndex) then
        HelperFunctions.quickSort(tbl, i, rightIndex, func, table.unpack(arg))
    end
    return tbl;
end

--- copies table
---@param orig table
---@return table
---@source http://lua-users.org/wiki/CopyTable
function HelperFunctions.copyTable(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[HelperFunctions.copyTable(orig_key)] = HelperFunctions.copyTable(orig_value)
        end
        setmetatable(copy, HelperFunctions.copyTable(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

return HelperFunctions
