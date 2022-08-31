-- Definitions
---@class ScanData
---@field x number
---@field y number
---@field z number
---@field name string

---@class ScanDataTable
---@field _ ScanData

---@class ScanSettings
local ScanSettings = require("ScanSettings")

---@class HelperFunctions
local helper = require("HelperFunctions")

---@class Scanner
Scanner = {}



---comment
---@param radius any
---@return ScanDataTable
---@field x number Dasd
function Scanner.scan(radius)
    ---@type table
    local g = peripheral.find("geoScanner")
    if g == 0 then return nil end
    ---@type ScanDataTable
    local result = g.scan(radius)
    if type(result) == "string" then
        return nil;
    end
    local mapfunc = function(value)
        value["tags"] = nil
        return value
    end
    result = helper.map(result, mapfunc) --[[@as ScanDataTable]]
    -- Should be on its own program
    local filePath = ScanSettings.setGet("ScanDataFile", nil, "./ScanData/LastScanData.lua");
    local file = io.open(filePath, "w+")
    if (file ~= nil) then
        file:write(textutils.serialise(result));
        file:close();
    end
    return result;
end

return Scanner
