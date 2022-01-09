-- install dependenices

local dependencies = {
    "turtleController",
    "QuarryInterface"
}

local installer = require("cpm")
installer.install(dependencies)

-- tControler = require("API/turtleController")
local interface = require("API/QuarryInterface")

_ = interface.Events["Start"] + function() print("Starting") end

interface.Init();
run();