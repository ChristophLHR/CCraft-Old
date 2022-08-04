local dependencies = {
    "turtleController",
}
local installer = require("cpm")
installer.install(dependencies)

---@class turtleController
-- tControler = require("API/turtleController")

---@class MiningScript
MiningScript = {goalX = 0, goalY = 0, currentX = 0, currentY = 0, updateFunc = {func = function () end, parameter = {}}}

--Normal Mining
local function stripMine()

end

local function updateInterface(ref)
    if type(ref.updateFunc.func) == "function" then
        ref.updateFunc.func(table.unpack(ref.updateFunc.parameter));
    end
end

function MiningScript:start(x, y)
    self.goalX = x;
    self.goalY = y;
    updateInterface(self)
end

return MiningScript