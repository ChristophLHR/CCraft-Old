---@class turtleController
t = require("API/turtleControler");
t.canBeakblocks = true;

local ladderItem;
local args = {...}



local function run()
    if args[1] == "" then return end;
    ladderItem = turtle.getItemDetail(2);
    local depth = tonumber(args[1]);
    for i = 0, depth do
        t:goDown(1);
        turtle.dig();
        turtle.select(t:findItemInInventory(ladderItem));
        turtle.place(); 
    end
end

run()