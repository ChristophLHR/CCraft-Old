---@class Scanner
Scanner = {}

-- DEFINITIONS
---@class ScanData
---@field x number
---@field y number
---@field z number
---@field name string

---@class ScanDataTable
---@field _ ScanData

-- REQUIREMENTS
---@class SettingsService
local settingsService = require("SettingsService")
---@class HelperFunctions
local helper = require("HelperFunctions")
---@class Log
local log = require("Log")

-- CONTENT

---comment
---@param radius any
---@return ScanDataTable
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
    local filePath = settingsService.setGet("ScanDataFile", nil, "./ScanData/LastScanData.lua");
    log.write(filePath, result, "w+")
    return result;
end

return Scanner
