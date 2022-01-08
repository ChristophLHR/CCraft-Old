-- install dependenices

local dependencies = {
    "turtleController",
    "QuarryInterfaceV2"
}

local installer = require("cpm")
installer.install(dependencies)

-- tControler = require("API/turtleController")
local interface = require("API/QuarryInterfaceV2")

local function run()
    interface.Init();
end
run();