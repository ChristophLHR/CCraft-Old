local turtleController = {}
-- Important: Errorhandler as a Callback in Key: "errorHandler"
-- TODOS: SaveStates.

turtleController.freeRefuelSlot = true
turtleController.refuelSlot = 1
turtleController.canBeakblocks = false

-- Override if needed
turtleController.errorHandler = function(err) 
    error(err);
end

turtleController.moveSet = {
    ["f"] = turtle.forward,
    ["tR"] = turtle.turnRight,
    ["tL"] = turtle.turnLeft,
    ["tA"] = function() turtle.turnLeft() turtle.turnLeft() end,
    ["u"] = turtle.up,
    ["d"] = turtle.down,
    ["b"] = turtle.back
}

turtleController.moveHandler = {
    ["f"] = turtle.dig,
    ["u"] = turtle.digUp,
    ["d"] = turtle.digDown,
    ["b"] = function() 
        self:tryMove('tA');
        self:tryMove('f');
        self:tryMove('tA');
    end
}

turtleController.actionSet = {
    ["dig"] = turtle.dig,
    ["digU"] = turtle.digUp,
    ["digD"] = turtle.digDown
}

function turtleController:refuel(number)

    --WIP
    local oldSlot = turtle.getSelectedSlot()
    turtle.select(turtleController.refuelSlot)
    local couldRefuel = turtle.refuel(number)

    if couldRefuel == false then
        if(self.freeRefuelSlot) then
            print("Finding Fuel")
            if pcall(
                function ()
                    turtle.select(self:findFuel())
                    couldRefuel = turtle.refuel(number)
                end
            ) then 
                couldRefuel = true
            else
                print('could not find Fuel');
            end
        end
    end

    turtle.select(oldSlot)
    return couldRefuel

end

function turtleController:goStraight(number, callBackAfterEach, parameter)
    --TODO Errorcatches
    for i = 1, number do

        turtle.dig()
        self:tryMove("f")
        if(callBackAfterEach) then callBackAfterEach(parameter) end

    end
end

function turtleController:goLeft(number, callBackAfterEach, parameter)
    self:tryMove("tL")
    self:goStraight(number, callBackAfterEach, parameter)
end

function turtleController:goRight(number , callBackAfterEach, parameter)
    self:tryMove("tR")
    self:goStraight(number, callBackAfterEach, parameter)
end

function turtleController:goUp(number , callBackAfterEach, parameter)

    for i = 1, number do
        turtle.digUp()
        self:tryMove("u")
        if(callBackAfterEach) then callBackAfterEach(parameter) end
    end
end

function turtleController:goDown(number, callBackAfterEach, parameter)

    for i = 1, number do
        turtle.digDown()
        self:tryMove("d")
        if(callBackAfterEach) then callBackAfterEach(parameter) end
    end
end

function turtleController:goBack( number, fast, callBackAfterEach, parameter)
    if(fast and number > 1) then
        turtleController:tryMove('tA');
        turtleController:goStraight(number, callBackAfterEach, parameter);
        turtleController:tryMove('tA');
        return
    end
    for i = 1, number do
        self:tryMove("b");
        if(callBackAfterEach) then callBackAfterEach(parameter) end
    end
end

function turtleController:run()

    --TODO: Wenn bildschirm zu klein wird.
    
end

function turtleController:tryMove(string)
    if(self.moveSet[string]() == false) then
        if(turtle.getFuelLevel()==0) then
            if(self:refuel(1) == false) then
                -- TODO: Find new RefuelSlot, if allowed
                    if(self.errorHandler) then
                        self.errorHandler("Out of Fuel")
                    else
                        error('Could not refuel');
                    end
            else
                self:tryMove(string)
            end
        elseif self.canBeakblocks then
            if(self.moveHandler[string]()) then
                self:tryMove(string)
            elseif(self.errorHandler) then
                self.errorHandler("Can not dig item")
            end
        else
            if(self.errorHandler) then
                self.errorHandler("sth is in the way")
            end
        end
    end
end

function turtleController:tryAction(string)
    if(self.actionSet[string]()==false) then
    
            print("couldnt Do action: "..string)
            --TODO duh
            return false

    end
end



function turtleController:findItem(compareFunction, searchedItem)
    -- searchedItem is optional. Could be a string, table or whatever the CompareFunction needs
    local currentSlot = turtle.getSelectedSlot()

    if(compareFunction(currentSlot, searchedItem)) then return currentSlot end

    for i = 1, 16 do
        if(compareFunction(i, searchedItem)) then turtle.select(currentSlot) return i end
        
    end

    return nil
    
end

-- turtle.inspect hat immer einen .name
function turtleController:compareInspect(compareItemA, compareItemB) 
    -- Todo. Compare does not work yet
    if(compareItemA == nil or compareItemB == nil) then
        return compareItemA == compareItemB;
    end

    local iName, bName;
    if(type(compareItemA)=="table") then
        iName = compareItemA.name;
    else
        iName = compareItemA;
    end
    if(type(compareItemB)=="table") then
        bName = compareItemB.name;
    else
        bName = compareItemB;
    end
    return iName == bName;

end


function turtleController:findFuel()

    local compareFunc = function(slot) turtle.select(slot) return turtle.refuel(0) end
    return self:findItem(compareFunc)

end

function turtleController:findItemInInventory(searchedItem)

    local compFunc = function(slot, sItem)
        local item = turtle.getItemDetail(slot)
        if(item == nil) then return false end
        if(item.name == sItem) then return true end
        return item.name == sItem.name
    end

    return self:findItem(compFunc, searchedItem)
end

function turtleController:inspect()
    local _,ret = turtle.inspect();
    return ret;
end

function turtleController:inspectUp()
    local _,ret = turtle.inspectUp();
    return ret;
end

function turtleController:inspectDown()
    local _,ret = turtle.inspectDown();
    return ret;
    
end

return turtleController