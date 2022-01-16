local dependencies = {
    "WindowHandler","EventHandler"
}

local installer = require("cpm");
installer.install(dependencies);

local EventHandler = require("API/EventHandler");
local windowHandler = require("API/windowHandler");



-- QuarrySettings
local initX, initY, initZ;
local floor, ceiling, wall
local toggled = false;
local step = 1;
local stepFunctions = {

}

--WindowSettings
Window = nil;
InfoWindow = nil;
InfoText = nil;
Line1 = nil;
NextButton = nil;
CeilingButtom = nil;
FloorButtom = nil;
WallsButtom = nil;

BUGGED = true;



local nextEvent;
local toggleButton;
local toggleEvent;
local toggleColor = {
    ["true"] = colors.green,
    ["false"] = colors.red
}


function start()

    stepFunctions[step]();

end

function Toggle(newValue)
    -- Toggle Colors as well!

    if(type(newValue) == "boolean") then
        toggled = newValue;
    else
        toggled = not toggled;
    end
    windowHandler:editBox(toggleButton, nil, nil, toggleColor[tostring(toggled)], nil, nil);
    windowHandler.drawChanges = true;
    print(toggled)
end

Events = {
    ["Start"] = EventHandler("Start");
    ["Pause"] = EventHandler("Pause");
    ["Stop"] = EventHandler("Stop");
}

local function readXYZ()
    print("")
end

local function printInfoBox()

end

function Init()
    local width, height = term.current().getSize();
    Window = windowHandler:createWindow(term.current(), 1, 1, width, height, "window");
    InfoWindow = windowHandler:createWindow(Window, 1, 9, 15, 4, "InfoBox");
    windowHandler:addBox(1, 1, colors.yellow, 15,4, InfoWindow);
    windowHandler:addText(1,1, "1. Slot Fuel", colors.black, colors.yellow, InfoWindow);
    windowHandler:addText(1,2, "2. Slot Ground", colors.black, colors.yellow, InfoWindow);
    windowHandler:addText(1,3, "3. Slot Walls", colors.black, colors.yellow, InfoWindow);
    windowHandler:addText(1,4, "4. Slot Ceiling", colors.black, colors.yellow, InfoWindow);
    

    -- print("Parameter: Forward, Left, Height");
    -- print("Enter:");
    -- initX, initY, initZ = read();
    
    -- initX = nil~=initX and initX or 1;
    -- initY = nil~=initY and initY or 1;
    -- initZ = nil~=initZ and initZ or 1;
    
    -- step = step + 1;


    Line1 = windowHandler:addText(1, 1, 'Forward?', colors.white, colors.black, Window);
    windowHandler:drawAllWindows();
    term.setCursorPos(1,2);
    initX = read() or 1;
    Line1 = windowHandler:addText(1, 1, 'Left?', colors.white, colors.black, Window);
    windowHandler:drawAllWindows();
    term.setCursorPos(1,2);
    initY = read() or 1;
    Line1 = windowHandler:addText(1, 1, 'Height (Going up)?', colors.white, colors.black, Window);
    windowHandler:drawAllWindows();
    term.setCursorPos(1,2);
    initZ = read() or 1;
    toggleButton = windowHandler:addButton(width - 4, 5, 'x', colors.white, colors.green, 3, 3, Window);
    toggleEvent = windowHandler:getEventHandler(toggleButton, "Toggle");
    _ = toggleEvent + Toggle;

    NextButton = windowHandler:addButton(width - 7, 10, 'Next', colors.green, colors.white, 6, 2, Window)
    nextEvent = windowHandler:getEventHandler(NextButton, "Next");
    _ = nextEvent + start;

    
    windowHandler:drawAllWindows();
    -- windowHandler:listenToEvents(0.1);
    

end


return {["Events"] = Events, ["Init"] = Init, ["Values"] = {
    ["X"] = initX,
    ["Y"] = initY,
    ["Z"] = initZ,
    ["Wall"] = wall,
    ["Ceiling"] = ceiling,
    ["Floor"] = floor,
}};