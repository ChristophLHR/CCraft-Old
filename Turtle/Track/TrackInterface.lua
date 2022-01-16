local dependencies = {
    "WindowHandler","EventHandler"
}

local installer = require("cpm");
installer.install(dependencies);

local EventHandler = require("API/EventHandler");
local windowHandler = require("API/windowHandler");


Values = {};

--WindowSettings
Window = nil;
WindowWith = nil;
WindowHeight = nil;
InfoWindow = nil;
InfoText = {};
DirectionInfo = {};
StartButton = nil;

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

Events = {
    ["Start"] = EventHandler("Start");
    ["Pause"] = EventHandler("Pause");
    ["Stop"] = EventHandler("Stop");
}

local function readXYZ()
    table.insert(DirectionInfo, windowHandler:addText(1, 1, 'Forward?', colors.white, colors.black, Window));
    windowHandler:drawAllWindows();
    term.setCursorPos(25,1);
    Values.Forward = read() or 1;
    table.insert(DirectionInfo, windowHandler:addText(25, 1, Values.Forward, colors.white, colors.black, Window));
end;

local function manageInfoBox()
    table.insert(InfoText, windowHandler:addBox(1, 1, colors.yellow, 15,4, InfoWindow));
    table.insert(InfoText, windowHandler:addText(1,1, "1. Slot Fuel", colors.black, colors.yellow, InfoWindow));
    table.insert(InfoText, windowHandler:addText(1,2, "2. Slot Ground", colors.black, colors.yellow, InfoWindow));
    table.insert(InfoText, windowHandler:addText(1,3, "3. Slot Track", colors.black, colors.yellow, InfoWindow));
end;

local function manageBuilding()
    local button;

    button = windowHandler:addButton(WindowWith - 7, 10, 'Start', colors.green, colors.white, 6, 2, Window)
    startEvent = windowHandler:getEventHandler(button, "Next");
    _ = startEvent + start;
end;

function Init()
    WindowWith, WindowHeight = term.current().getSize();
    Window = windowHandler:createWindow(term.current(), 1, 1, WindowWith, WindowHeight, "window");
    InfoWindow = windowHandler:createWindow(Window, 1, 9, 15, 4, "InfoBox");
    manageInfoBox();
    readXYZ();

    manageBuilding();
    
    windowHandler:drawAllWindows();
    windowHandler:listenToEvents(0.1);
end;


return {["Events"] = Events, ["Init"] = Init, ["Values"] = Values};