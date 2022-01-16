local dependencies = {
    "turtleController"
}

local installer = require("cpm");
installer.install(dependencies);

local tControler = require("API/turtleController");

tControler.canBeakblocks = true;
local wood = turtle.getItemDetail(1);
local seed = turtle.getItemDetail(2);
local height = 0;
local testing = false;

local dropLootSlot = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};


local function cutTree()
    if tControler:compareInspect(wood, tControler:inspect()) then

        if testing then
            print('Testing, not cutting the tree');
            return;
        end

        tControler:goStraight(1);
        while tControler:compareInspect(wood, tControler.inspectUp()) do
            tControler:goUp(1);
            height = height + 1;
        end

        while height > 0 do
            tControler:goDown(1);
            height = height - 1;
        end
        local select = turtle.getSelectedSlot();
        turtle.select(2);
        turtle.place();
        turtle.select(select);
    end
end

local function suckLoot()

    tControler:tryMove('b');
    tControler:tryMove('b');
    tControler:tryMove('d');
    tControler:tryMove('d');
    tControler:tryMove('d');
    tControler:tryMove('d');
    while(turtle.suckDown()) do end;
    tControler:tryMove('u');
    tControler:tryMove('u');
    tControler:tryMove('u');
    tControler:tryMove('u');
    tControler:tryMove('f');
    tControler:tryMove('f');

end

local function dropLoot()

    local select = turtle.getSelectedSlot();
    for i = 1, #dropLootSlot do
        turtle.select(dropLootSlot[i]);
        turtle.dropDown();
    end
    turtle.select(select);

end


local function run()

    while true do

        for j = 1, 3 do
            cutTree();
            for i = 1, 2 do
                tControler:goLeft(5);
                tControler:tryMove('tR');
                cutTree();
            end
            if(j ~= 3) then
                tControler:goLeft(1);
                tControler:goRight(5);
                tControler:goRight(11);
                tControler:tryMove('tL');
            end
        end
        tControler:goRight(11);
        tControler:goRight(10);
        tControler:goRight(1);
        tControler:tryMove('tR');
        suckLoot();
        dropLoot();
        print('Sleeping 500 seconds');
        sleep(5);
        
    end
end
run()