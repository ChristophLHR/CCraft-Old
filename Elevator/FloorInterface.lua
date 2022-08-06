---@class windowHandler
w = require("API/windowHandler")
f = require("API/floorController")

pretty = require("cc.pretty")


local ownChannel, groundFloor = ...
settings.load()

if(type(ownChannel) == "string") then
    ownChannel = tonumber(ownChannel)
    settings.set("NetworkID", ownChannel)
    
else
    local n = settings.get("NetworkID")
    if(n == nil) then
        error("No Network ID was set, no ID was found")
    end
    ownChannel = n
end

if(groundFloor == "true") then
    f.config.groundFloor = true
    settings.set("GroundFloor", true)
else
    local gF = settings.get("GroundFloor")
    if(gF == true) then
        f.config.groundFloor = true
    end
end
settings.save()

--Windows
local parentWindow, limitedWindow , dragableWindow
local windowWidth, windowHeight
-->

-- Buttons
local callButton, stateButton
local maxButtonText = 1

local floorButtons = {}
-->


-- Mach nen Echten AUfzugsshit, mit allen möglichen Buttons für alle Etagen. Vl mit scollen etc

function addFloor(number)

    --Todo: Das komplett dynamisch machen, sodass man auch hinten welche einfügen kann
    local wWidth, wHeight = dragableWindow.getSize()
    local bSize = math.floor(wWidth / 3) - 1 -- 3 Buttons pro Reihe
    local xMod = #floorButtons % 3 -- Button Nr.XY => X für Button
    local x =  (xMod * bSize) + (1 * xMod) + 1 -- Position X für Button
    local yMod = math.floor(#floorButtons / 3) -- Jedes dritte einen Platz nach unten Modifizierten
    local y = (yMod * bSize) + (1 * yMod) + 1 -- Position X für Button
    
    local btnText = tostring(number)
    
    table.insert( floorButtons, w:addButton(x, y, btnText, colors.white, colors.orange, bSize - 1, bSize - 1 , dragableWindow, goTo, number))


end

function initFloorController()
    local afterInit = function()
        updateUI()
        run()
    end
    local err = function ()
        error("No connection to the Elevator right know")
    end
    config = {ownChannel = ownChannel, globalChannel = 2, receiverChannel = 1, defaultTimeOut = 3}
    f:init(config, peripheral.find("modem"), 10, afterInit)
end

function readyButton()
    w:editButton(stateButton, nil, nil, "Ready", nil, colors.green, nil, nil)
end

function bussyButton()
    w:editButton(stateButton, nil, nil, "Bussy", nil, colors.orange, nil, nil)
end

function errorButton()
    w:editButton(stateButton, nil, nil, "Error", nil, colors.red, nil, nil)
end

function successButton()
    w:editButton(stateButton, nil, nil, "Success", nil, colors.green, nil, nil)
end

function callButtonEvent()

    -- w.continueListener = false
    f:goToFloor(f.config.ownPosition)

end

function goTo(args)
    local number = args[1]
    if(number ~= f.state.goalFloor)then
        bussyButton()
        w.drawChanges = true
        f:goToFloor(number, {success = successButton, error = errorButton})

        -- f:goToFloor(number)
    end

end

function refreshElevatorStats()

    if(f.state.update) then
        f.state.update = false
        updateUI()
    end

    if(f.state.currentFloor == f.state.goalFloor) then
        readyButton()
    else
        bussyButton()
    end

    for i = 1, #floorButtons do

        local number = tonumber(floorButtons[i].text)
        w:editButton(floorButtons[i], nil, nil, nil, colors.white, colors.orange, nil, nil, goTo, number)

        if(number == f.state.currentFloor) then
            w:editButton(floorButtons[i], nil, nil, nil, nil, colors.blue, nil, nil, goTo, number)
        elseif(number == f.state.goalFloor) then
            w:editButton(floorButtons[i], nil, nil, nil, nil, colors.green, nil, nil, goTo, number)
        end
        if(number == f.config.ownPosition) then
            w:editButton(floorButtons[i], nil, nil, nil, colors.black, nil, nil, nil, goTo, number)
        end
    end

    w.drawChanges = true

end

function updateUI()
    w.windows = {}
    w.windowIDMax = 0
    floorButtons = {}
    if(peripheral.wrap("left") ~= nil) then
        f.config.isClient = true
        print("PC Tower")
        parentWindow = w:addWindowAsMonitor("left","parentWindow")
    
    else
        
        local width, height = term.current().getSize()
        parentWindow = w:createWindow(term.current(),1,1, width, height, "parentWindow") -- Here ToDo
    
    end

    windowWidth, windowHeight = parentWindow.getSize()
    parentWindow.setBackgroundColor(colors.white)
    parentWindow.setTextColor(colors.black)
    -- set parentWindow
    limitedWindow = w:createWindow(parentWindow, 3, 1, windowWidth - 1, windowHeight - 5, "limitedWindow")
    limitedWindow.setBackgroundColor(colors.white)
    parentWindow.setTextColor(colors.black)
    --set Childwindow, Dragable
    dragableWindow = w:createWindow(limitedWindow, 1,1, windowWidth - 1, 1000, "dragableWindow")
    dragableWindow.setBackgroundColor(colors.white)
    parentWindow.setTextColor(colors.black)
    dragableWindow.enableYDrag = true

    -- set Buttons
    print("Building buttons")
    if(f.config.start ~= nil) then
        for i= f.config.start, f.config["end"], 1 do

            addFloor(i)

        end
    end

    -- call Button (-1 bc of the padding of the buttons)
    if(f.config.isClient) then
        callButton = w:addButton(1, windowHeight - 4, "Call", colors.white, colors.green, windowWidth - 10 - 1, 4, parentWindow, callButtonEvent)
        stateButton = w:addButton(windowWidth - 8 - 1, windowHeight - 4, "Status", colors.white, colors.red, 10, 4, parentWindow)
    else
        stateButton = w:addButton(1, windowHeight - 4, "Status", colors.white, colors.red, windowWidth, 4, parentWindow)
    end

end

function run()

    local listenToNetwork = {active = true}
    -- w:listenToEvents(0.1, 0.3)

    parallel.waitForAny(
        function ()
            f:listenToNetworkEvents(listenToNetwork, _, {update = refreshElevatorStats, updateFloors = updateUI})
        end,
        function ()
            w:listenToEvents(0.1, 0.3)
        end
    )

    print("Error, I should never finish!")

end

updateUI()
initFloorController()

-- w:listenToEvents(0.3, 0.2)
-- sleep(1)
-- updateEvent = function() pretty.print(pretty.pretty(f.state)) end
-- parallel.waitForAll(function() goTo({5}) end, function() f:listenToNetworkEvents({active = true},_, {update = updateEvent}) end)
-- goTo({1})
