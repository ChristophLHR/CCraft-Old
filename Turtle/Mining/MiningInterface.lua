local dependencies = {
    "MiningScript",
    "WindowHandler",
    "CC-EventHandler"
}
local installer = require("cpm")
installer.install(dependencies)

---@class windowHandler
local w = require("API/windowHandler");
---@class MiningScript
local miner = require("API/MiningScript");
---@class CCEventHandler
local eHandler = require("API/CC-EventHandler");
local pretty = require("cc.pretty")

local window, width, height
local debugWindow, debugHeight, debugWidth
local infoText;
---@class EventHandler
local startEvent;
local startButton;
local inputText; 

local function updateInterFace()
    local txt =
        "X: "..miner.currentX.."/"..miner.goalX..
        " | Y: "..miner.currentY.."/"..miner.goalY

    w:editText(infoText, debugWidth, 1 ,txt, nil, nil);
    w.drawChanges = true;
    w.writeToWindow(txt, debugWindow);
end

local function startWindowListener()
    local status, err = pcall(w.listenToEvents, w, 0.3, 1);
    if not status then 
        w:errorHandler(err);
    else
        w:printDev("Crashed?");
    end
end

local function Start(no)
    w:editText(infoText, nil, nil, "Started", nil);
    w.drawChanges = true;
    miner:start(no, no)
end

local  function getInput()
    local test
    while test ~= "getInput" do
        test = os.pullEvent()
    end
    window.setCursorPos(inputText.x, inputText.y);
    w:editText(inputText, nil, nil, "reading...", nil, nil);
    w.drawChanges = true;
    local input
    input = eHandler.read();
    local no = tonumber(input);
    w:editText(inputText, width - #input - 2, nil, tostring(no), nil, nil);
    startButton.parameter = no;
    _ = startEvent + Start;
    w:editButton(startButton, nil, nil, nil, nil, colors.green, nil, nil);
    w:editText(infoText, nil, nil, "Updated", nil, nil)
    w.drawChanges = true;

end

local function initWindow()
    
    w.devMode = true;
    width, height = term.getSize();
    debugWidth = 15;
    width = width - debugWidth;
    debugHeight = height;
    window = w:createWindow(term.current(), debugWidth, 1, width, height, "Main");
    
    infoText = w:addText(1, 2 , "Needs:", colors.white, nil, window);
    local txt = "Start";
    startButton = w:addButton(width - #txt - 4, height - 8, txt, colors.white, colors.red, #txt + 2, 3, window);

    startEvent = w:getEventHandler(startButton, "Start");
    
    txt = "<insert No. of Blocks>";
    inputText = w:addText(width - #txt - 2, height - 10, txt, colors.white, nil, window);

    local inputF = function()
        os.queueEvent("getInput");
    end

    local e = w:getEventHandler(inputText, "Read");
    _ = e + inputF;
    miner.updateFunc.func = updateInterFace;
    

    -- debug
    debugWindow = w:createWindow(term.current(), 1, 1, debugWidth, debugHeight, "Debug");
    debugWindow.skip = true;
    w:addBox(1, 1, colors.red, debugWidth - 1, debugHeight - 1, debugWindow);
    w:addBox(2, 2, colors.black, debugWidth - 2, debugHeight - 2, debugWindow);
    
    eHandler:add(startWindowListener);
    getInput();
end
eHandler:add(initWindow);
eHandler:start();