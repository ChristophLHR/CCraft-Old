---@class FindPathToBlocks
local findPath = require("FindPathToBlocks");

---@class ScanSettings
local ScanSettings = require("ScanSettings")

local distance = ScanSettings.setGet("Scan", nil, 7)

local scan = findPath.find(distance);
scan = findPath.sortFilteredScan(scan)
textutils.pagedPrint(textutils.serialise(findPath.createPath(scan)))
