---@class FindPathToBlocks
local findPath = require("FindPathToBlocks");

---@class SettingsService
local ScanSettings = require("SettingsService")

local tController = require("TurtleControler")

tController.canBeakblocks = true

local distance = ScanSettings.setGet("Scan", nil, 7)

local scan = findPath.find(distance);
scan = findPath.sortFilteredScan(scan)
local path = findPath.createPath(scan);
textutils.pagedPrint(textutils.serialise(path))

for k, v in pairs(path) do
    tController:compactMove(v)
end
