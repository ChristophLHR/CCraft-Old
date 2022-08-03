local dependencies = {
    "MiningScript",
    "WindowHandler"
}
local installer = require("cpm")
installer.install(dependencies)

---@class windowHandler
local w = require("API/windowHandler");
local Miner = require("API/MiningScript.lua");

local window, infoText;
---@class EventHandler
local startEvent;
local startButton;
local inputText; 

local function Start()
    w:editText(infoText, nil, nil, "Started", nil);
end

local function read()
    window.setCursorPos(inputText.x, inputText.y);
    w:editText(inputText, nil, nil, "", nil, nil);
    local input = read();
    input = tonumber(input);
    w:editText(inputText, nil, nil, tostring(input), nil, nil);
    startEvent:addCallback(Start);
    w:editButton(startButton, nil, nil, nil, nil, colors.green, nil, nil);

end

local function initWindow()
    local width, height = term.getSize();
    window = w:createWindow(term.current(), 1, 1, width, height, "Main");
    infoText = w:addText( 1, 2 , "Needs:", colors.white, nil, window);
    local txt = "Start";
    startButton = w:addButton(width - #txt - 4, height - 4, txt, colors.white, colors.gray, nil, nil, window);
    startEvent = w:getEventHandler(startButton, "Start");

    txt = "<insert No. of Blocks>";
    inputText = w:addText(width - #txt - 2, height - 6, txt, colors.white, nil, window);
    local e = w:getEventHandler(inputText, "Read");
    _ = e + read;

    w:listenToEvents();
end

initWindow();

