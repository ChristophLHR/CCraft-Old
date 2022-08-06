local dependencies = {
    "EventHandler",
    "CC-EventHandler"
}
local installer = require("cpm")
installer.install(dependencies);
---@class EventHandler
local event = require("API/EventHandler")
---@class CCEventHandler
local ccEventHandler = require("API/CC-EventHandler");
local pretty = require("cc.pretty")

args = {...}
local modem
-- all eventHandlers
---@class EventHandler
local goToEvent
---@class EventHandler
local initEvent 
---@class EventHandler
local updateEvent
os.sleep(1) -- GPS might need a sec to startup

local runningUpdates = 0;


local tChannels = {
    ["ownChannel"] = 1, ["globalChannel"] = 2
}

local tFloorInfo = {
    ["currentFloor"] = nil,
    ["goalFloor"] = nil,
    ["start"] = nil,
    ["end"] = nil
}


local groundFloor = 0

-- Functions

local tFloorClients = {}

function searchFunction(compareFunction, tbl_ToSearch, item)
    for key, value in pairs(tbl_ToSearch) do
        if(compareFunction(value, item)) then
            return key, value
        end
    end
    return nil
end

function initFloors(client)
    
    -- if the Client Already exists: Replace, otherwise insert.
    search = function(tFloorClient, _client)
        return tFloorClient.id == _client.id
    end

    key, item = searchFunction(search, tFloorClients, client)
    if(key) then
        tFloorClients[key] = client
    else
        table.insert( tFloorClients, client )
    end

    -- get the Order correct
    sort = function(a, b)
        return a.gps.y < b.gps.y
    end
    table.sort(tFloorClients, sort)
    print("Client added to the Table: "..tostring(client.id))
    -- pretty.print(pretty.pretty(tFloorClients))

    -- get ground floor
    search = function(a)
        return a.groundFloor ~= nil
    end
    groundFloor = searchFunction(search, tFloorClients)
    if(groundFloor ~= nil) then groundFloor = groundFloor - 1
    else groundFloor = 0 end
    
    tFloorInfo.currentFloor = #tFloorClients - groundFloor

    tFloorInfo["start"] = 0 - groundFloor
    tFloorInfo["end"] = #tFloorClients - groundFloor - 1

    print("currentFloor = "..#tFloorClients)
    if(runningUpdates == 0) then
        refreshClients()
        goTo(0 - groundFloor) -- Das hier verschieben auf mit einem Timeout in Main!!!
    else
        print("there is an other registration")
    end

end

function UpdateFunction()
    modem.transmit(rpyChannel, tChannels.ownChannel, true)
    upDateFloors()
end

local function addFloorFunction()
    refreshClients()
    goTo(0 - groundFloor) -- Das hier verschieben auf mit einem Timeout in Main!!!
end

function listenToEvents()


    while true do

        event, side, channel, rpyChannel, message = os.pullEvent()
        if(event == "modem_message") then
            if(message and type(message) == "table") then
                if(message.command) then

                    if(message.command == "goTo") then

                        modem.transmit(rpyChannel, tChannels.ownChannel, true)
                        -- sleep Event within
                        -- goToEvent:queueEvent({"goTo", message.args.floor})
                        goToEvent:invoke(message.args.floor);

                    elseif(message.command == "update") then
                        modem.transmit(rpyChannel, tChannels.ownChannel, true)
                        upDateFloors()

                    elseif(message.command == "init") then
                        -- sleep Event within
                        -- goToEvent:queueEvent({"init", message.args})
                        initEvent:invoke(message.args);
                    else

                        print("unkown Command:")
                        print(message.command)

                    end

                else
                    
                    print("message does not contain a command:")
                    print(message)

                end

            else

                print("No Message")

            end
        end
    end
end

function openModem(position)

    modem = peripheral.find("modem")
    modem.open(tChannels.ownChannel)
    modem.open(tChannels.globalChannel)

end

function goTo(number)
    CCEventHandler:add(function ()
        runningUpdates = runningUpdates + 1;
        print("going to Floor "..number)

        tFloorInfo.goalFloor = number
        
        while tFloorInfo.goalFloor~=tFloorInfo.currentFloor do

            -- Invert the Flow ( Go either up or down )
            if tFloorInfo.currentFloor < tFloorInfo.goalFloor then
                
                rs.setOutput("back", false)
                tFloorInfo.currentFloor = tFloorInfo.currentFloor + 1
                
            else
                
                rs.setOutput("back",true)
                tFloorInfo.currentFloor = tFloorInfo.currentFloor - 1
                
            end
            rs.setOutput("right", true)
            -- Timers 

            local timerID = os.startTimer(1)
            while timerID == 0 do
                event = {os.pullEvent("timer")}
                print("Resetting Timer 1")
                if event[2] == timerID then
                    print("Finished Timer 1")
                    timerID = 0;
                end
            end
            rs.setOutput("right",false)
            
            timerID = os.startTimer(1)
            while true do
                print("Resetting Timer 2")
                event = {os.pullEvent("timer")}
                if event[2] == timerID then
                    print("Finished Timer 2")
                    timerID = 0;
                end
            end
            upDateFloors()
            print("finished")

        
        end
        runningUpdates = runningUpdates - 1;
        print("Running Updates: "..runningUpdates);
    end)
end

function init()
    modem.transmit(tChannels.globalChannel, tChannels.ownChannel, {command = "startUp"})
end

function refreshClients()

    -- update all Clients
    for nr, _client in pairs(tFloorClients) do
        if(_client.networkID ~= nil) then
            local data = {floor = nr - groundFloor - 1}
            -- pretty.print(pretty.pretty(data))
            modem.transmit(_client.networkID, tChannels.ownChannel, data)
        end
    end



    if(tFloorInfo.currentFloor~=nil and tFloorInfo.goalFloor~=nil) then
        upDateFloors()
    end
end

function upDateFloors()

    -- print("Updating")
    modem.transmit(tChannels.globalChannel, tChannels.ownChannel, {info = tFloorInfo})

end

local function startFunction()
    goToEvent = event();
    goToEvent:addCallback(goTo);
    initEvent = event();
    initEvent:addCallback(initFloors);
    updateEvent = event();
    updateEvent:addCallback(addFloorFunction)

    openModem()
    init()

    ccEventHandler:add(listenToEvents);
    ccEventHandler:start();

end

startFunction();

-- Programmstart


