-- install dependenices

local dependencies = {
    "turtleController",
    "TrackInterface"
}

local installer = require("cpm")
installer.install(dependencies)

tControler = require("API/turtleController")
local interface = require("API/TrackInterface")

_ = interface.Events["Start"] + function() run() end;

local trackSlot;
local fuelSlot;
local buildBlock;

tControler.canBeakblocks = true;

function run()
    print("Starting");
    print('Forward => '..tostring(interface.Values.Forward));

    fuelSlot = turtle.getItemDetail(1);
    buildBlock = turtle.getItemDetail(2);
    trackSlot = turtle.getItemDetail(3);
    tControler:tryMove('tA');
    while(interface.Values.Forward > 0) do
        turtle.select(tControler:findItemInInventory(buildBlock));
        turtle.placeDown();
        tControler:moveBack(1);
        turtle.select(tControler:findItemInInventory(trackSlot));
        turtle.place();
        interface.Values.Forward = interface.Values.Forward - 1;
        print('Steps left'..interface.Values.Forward);

    end
end


interface.Init();