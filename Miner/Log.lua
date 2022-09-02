---@class Log All IO Log writing should be hanlded here
--- settings Used:
--- MaxFileLength & ErrorFile
Log = {}



local errorFilePath
local maxFileLength

local function getMaxFileLength()
    if maxFileLength ~= nil then return maxFileLength end
    if not pcall(function()
        local settingsService = require("SettingsService") --[[@as SettingsService]]
        maxFileLength = settingsService.setGet("MaxFileLength", nil, 10000)
    end) then
        maxFileLength = 10000
    end
    return maxFileLength
end

---@param file file*?
---@param content string | number | table Content to fill the File with
local function write(file, content, filePath)
    local c
    if type(content) == "table" then
        c = "local tableCreatedByLog = " .. textutils.serialise(content);
    else
        c = content
    end

    -- if over MaxFileLength, override all
    local size = file:seek("end")
    size = size or 0
    if size > getMaxFileLength() then
        print("Size", size)
        file:close();
        io.open(filePath, "w+")
    end

    ---@diagnostic disable-next-line: need-check-nil
    file:write(c);
    ---@diagnostic disable-next-line: need-check-nil
    file:close();
end

local function getErrorFile()
    if errorFilePath ~= nil then return errorFilePath end
    if not pcall(function()
        local settingsService = require("SettingsService") --[[@as SettingsService]]
        errorFilePath = settingsService.setGet("ErrorFile", nil, "Logs/Errors.lua")
    end) then
        errorFilePath = "Logs/Errors.lua"
    end
    return errorFilePath
end

---Log Write...
---@param filePath string Path incl. Filename
---@param content string | number | table Content to fill the File with
---@param dataAccess string How to access the File ("w", "w+", "a", "a+")
function Log.write(filePath, content, dataAccess)
    dataAccess = dataAccess or "w+"
    local file = io.open(filePath, dataAccess);

    if file == nil then
        Log.ErrorHandler("\nCould not open to File: \"" .. filePath .. "\"", nil, true);
        return
    end
    local succ, err = pcall(function() write(file, content, filePath) end)
    if not succ then
        Log.ErrorHandler(err, nil, true)
    end
end

---@param content string
---@param filePath string
---@param traceback boolean
function Log.ErrorHandler(content, filePath, traceback)
    filePath = filePath or getErrorFile();
    local errorFile = io.open(filePath, "a+")
    if traceback then
        content = debug.traceback(content);
    end
    local succ, err = pcall(function() write(errorFile, content, filePath) end)
    if not succ then error(err) end
end

return Log
