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
    [2] = function ()
        floor = toggled;
        windowHandler:editText(Line5, nil, nil, 'Create Ceiling', nil, nil);
        Toggle(true);
        step = step + 1;
    end,
    [3] = function ()
        ceiling = Toggle;
        windowHandler:editText(Line5, nil, nil, 'Create Walls', nil, nil);
        Toggle(true);
        step = step + 1;
    end,
    [4] = function ()

        windowHandler:editButton(nextButton, nil, nil, 'Start', colors.white, colors.yellow, nil, nil);
        windowHandler.drawChanges = true;
        step = step + 1;
    end,
    [5] = function ()
        windowHandler.continueListener = false;
        term.clear();
        print('starting');
        sleep(2);
        Events["Start"]:invoke();
    end
}

--WindowSettings
Window = nil;
Line5 = nil;
nextButton = nil;
local nextEvent;
local toggleButton;
local toggleEvent;
local toggleColor = {
    ["true"] = colors.green,
    ["false"] = colors.red
}


function next()

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


function Init()
    local width, height = term.current().getSize();
    Window = windowHandler:createWindow(term.current(), 1, 1, width, height, "window");

    -- make this to step one!
    print("1. Slot Fuel");
    print("2. Slot Ground");
    print("3. Slot Walls");
    print("4. Slot Ceiling");
    
    -- print("Parameter: Forward, Left, Height");
    -- print("Enter:");
    -- initX, initY, initZ = read();
    
    initX = nil~=initX and initX or 1;
    initY = nil~=initY and initY or 1;
    initZ = nil~=initZ and initZ or 1;
    
    step = step + 1;


    Line5 = windowHandler:addText(1, 5, 'Create Floor?', colors.white, colors.black, Window);

    toggleButton = windowHandler:addButton(width - 4, 5, 'x', colors.white, colors.green, 3, 3, Window);
    toggleEvent = windowHandler:getEventHandler(toggleButton, "Toggle");
    _ = toggleEvent + Toggle;

    nextButton = windowHandler:addButton(width - 7, 10, 'Next', colors.green, colors.white, 6, 2, Window)
    nextEvent = windowHandler:getEventHandler(nextButton, "Next");
    _ = nextEvent + next;

    
    
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