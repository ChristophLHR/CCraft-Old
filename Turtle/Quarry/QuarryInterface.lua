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
WindowWith = nil;
WindowHeight = nil;
InfoWindow = nil;
InfoText = {};
DirectionInfo = {};
StartButton = nil;
BuildingUI = {};

BUGGED = true;

local toggleColor = {
    ["true"] = colors.green,
    ["false"] = colors.red
}


function start()

    windowHandler.continueListener = false;
    term.clear();
    term.setCursorPos(1,1);
    Events.Start:invoke();
end

function Toggle(button ,newValue)
    -- Toggle Colors as well!

    if(type(newValue) == "boolean") then
        toggled = newValue;
    else
        toggled = not toggled;
    end
    windowHandler:editBox(button, nil, nil, toggleColor[tostring(toggled)], nil, nil);
    windowHandler.drawChanges = true;
    -- print(toggled)
end

Events = {
    ["Start"] = EventHandler("Start");
    ["Pause"] = EventHandler("Pause");
    ["Stop"] = EventHandler("Stop");
}

local function readXYZ()
    table.insert(DirectionInfo, windowHandler:addText(1, 1, 'Forward?', colors.white, colors.black, Window));
    windowHandler:drawAllWindows();
    term.setCursorPos(25,1);
    initX = read() or 1;
    table.insert(DirectionInfo, windowHandler:addText(25, 1, initX, colors.white, colors.black, Window));
    
    table.insert(DirectionInfo, windowHandler:addText(1, 2, 'Left?', colors.white, colors.black, Window));
    windowHandler:drawAllWindows();
    term.setCursorPos(25,2);
    initY = read() or 1;
    table.insert(DirectionInfo, windowHandler:addText(25, 2, initY, colors.white, colors.black, Window));
    
    table.insert(DirectionInfo, windowHandler:addText(1, 3, 'Height (Going up)?', colors.white, colors.black, Window));
    windowHandler:drawAllWindows();
    term.setCursorPos(25,3);
    initZ = read() or 1;

    for key, value in pairs(DirectionInfo) do
        windowHandler:removeObject(value, Window);
    end
end

local function manageInfoBox()
    table.insert(InfoText, windowHandler:addBox(1, 1, colors.yellow, 15,4, InfoWindow));
    table.insert(InfoText, windowHandler:addText(1,1, "1. Slot Fuel", colors.black, colors.yellow, InfoWindow));
    table.insert(InfoText, windowHandler:addText(1,2, "2. Slot Ground", colors.black, colors.yellow, InfoWindow));
    table.insert(InfoText, windowHandler:addText(1,3, "3. Slot Walls", colors.black, colors.yellow, InfoWindow));
    table.insert(InfoText, windowHandler:addText(1,4, "4. Slot Ceiling", colors.black, colors.yellow, InfoWindow));
end

local function manageBuilding()
    local button;
    
    table.insert(BuildingUI, windowHandler:addText(1,3,'Floor', colors.white, colors.black, Window));
    button = windowHandler:addButton(1, 5, 'x', colors.white, colors.green, 2, 2, Window);
    toggleEvent = windowHandler:getEventHandler(button, "Toggle");
    _ = toggleEvent + Toggle;
    button.parameter = button;
    table.insert(BuildingUI,button);
    
    table.insert(BuildingUI, windowHandler:addText(16,3,'Walls', colors.white, colors.black, Window));
    button = windowHandler:addButton(16, 5, 'x', colors.white, colors.green, 2, 2, Window);
    toggleEvent = windowHandler:getEventHandler(button, "Toggle");
    _ = toggleEvent + Toggle;
    button.parameter = button;
    table.insert(BuildingUI,button);

    table.insert(BuildingUI, windowHandler:addText(31,3,'Ceiling', colors.white, colors.black, Window));
    button = windowHandler:addButton(31, 5, 'x', colors.white, colors.green, 2, 2, Window);
    toggleEvent = windowHandler:getEventHandler(button, "Toggle");
    _ = toggleEvent + Toggle;
    button.parameter = button;
    table.insert(BuildingUI,button);

    button = windowHandler:addButton(WindowWith - 7, 10, 'Start', colors.green, colors.white, 6, 2, Window)
    startEvent = windowHandler:getEventHandler(button, "Next");
    _ = startEvent + start;
    table.insert(BuildingUI,button);
end

function Init()
    WindowWith, WindowHeight = term.current().getSize();
    Window = windowHandler:createWindow(term.current(), 1, 5, WindowWith, WindowHeight, "window");
    InfoWindow = windowHandler:createWindow(Window, 1, 9, 15, 4, "InfoBox");
    manageInfoBox();
    readXYZ();

    manageBuilding();
    
    windowHandler:drawAllWindows();
    windowHandler:listenToEvents(0.1);
end


return {["Events"] = Events, ["Init"] = Init, ["Values"] = {
    ["X"] = initX,
    ["Y"] = initY,
    ["Z"] = initZ,
    ["Wall"] = wall,
    ["Ceiling"] = ceiling,
    ["Floor"] = floor,
}};