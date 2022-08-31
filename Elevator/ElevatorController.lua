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

local timing, floors = ...
settings.load();
-- set settings
if (type(timing) == "string") then
    timing = tonumber(timing);
    settings.set("Timing", timing)
else
    timing = settings.get("Timing");
    if timing == nil then
        error("No Timing set for floors")
    end
end

if (type(floors) == "string") then
    floors = tonumber(floors);
    settings.set("Floors", floors)
else
    floors = settings.get("Floors");
    if floors == nil then
        error("No FloorDistance set")
    end
end
settings.save();
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


---@type table <gps, id, networkID>
local tFloorClients = {}



function searchFunction(compareFunction, tbl_ToSearch, item)
    for key, value in pairs(tbl_ToSearch) do
        if(compareFunction(value, item)) then
            return key, value
        end
    end
    return nil
end

---comment
---@param client table <gps, networkID>
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
    -- print("Client added to the Table: "..tostring(client.id))
    -- pretty.print(pretty.pretty(tFloorClients))

    -- get ground floor
    search = function(a)
        return a.groundFloor ~= nil
    end
    groundFloor = searchFunction(search, tFloorClients)
    if(groundFloor ~= nil) then groundFloor = groundFloor - 1
    else groundFloor = 0 end
    
    tFloorInfo.currentFloor = #tFloorClients - groundFloor - 1 -- anzahl - groundlevel - eins(weil array bei 1 anfängt)

    tFloorInfo["start"] = 0 - groundFloor
    tFloorInfo["end"] = #tFloorClients - groundFloor - 1

    if(runningUpdates < 1 and (#tFloorClients > 1)) then
        runningUpdates = 0;
        refreshClients()
        goTo(0 - groundFloor) -- Das hier verschieben auf mit einem Timeout in Main!!!
    else
        -- print("there is an other registration")
    end

end

function UpdateFunction()
    modem.transmit(rpyChannel, tChannels.ownChannel, true)
    upDateFloors()
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
                        
                        goToEvent:invoke(message.args.floor);

                    elseif(message.command == "update") then
                        modem.transmit(rpyChannel, tChannels.ownChannel, true)
                        upDateFloors()

                    elseif(message.command == "init") then
                        -- sleep Event within
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

--- ToDo: Muliple Calls while one is running
---@param number integer
function goTo(number)
    local func = function(no)
        if runningUpdates > 0 then 
            print("tried to run again")
            print(debug.traceback());
        end
        runningUpdates = runningUpdates + 1;
        print("going to Floor "..no)

        tFloorInfo.goalFloor = no
        
        while tFloorInfo.goalFloor~=tFloorInfo.currentFloor do
            -- calc GPS -> do rounds
            -- -1 + -1 + 1
            -- courtine check
            local arrived = false
            print(tostring(#tFloorClients));
            print(tFloorInfo.currentFloor.." + "..groundFloor);
            print(tFloorInfo.goalFloor);
            local gps = tFloorClients[tFloorInfo.currentFloor + groundFloor + 1].gps.y
            local nextGps
            local goUp = 0
            if tFloorInfo.currentFloor < tFloorInfo.goalFloor then
                goUp = 1
                -- arrays fangen bei 1 an
                nextGps = tFloorClients[tFloorInfo.currentFloor+groundFloor + 2].gps.y
            elseif (tFloorInfo.currentFloor > tFloorInfo.goalFloor) then
                nextGps = tFloorClients[tFloorInfo.currentFloor+groundFloor].gps.y
                goUp = -1
            else 
                arrived = true
            end
            print(arrived)
            while not arrived do
                print("between floor "..tFloorInfo.currentFloor.." and Floor "..tFloorInfo.currentFloor + goUp);
                print("GoUp: "..tostring(goUp))
                -- if tFloorInfo.currentFloor < tFloorInfo.goalFloor then
                if goUp == 1 then
                    rs.setOutput("back", false)
                    -- tFloorInfo.currentFloor = tFloorInfo.currentFloor + 1
                    gps = gps + floors;
                else
                    rs.setOutput("back",true)
                    -- tFloorInfo.currentFloor = tFloorInfo.currentFloor - 1
                    gps = gps - floors;
                end
                print("GPS: "..gps)
                print(tostring(gps));
                rs.setOutput("right", true)
                -- Timers 
                local timerID = os.startTimer(timing)
                while timerID ~= 0 do
                    event = {os.pullEvent("timer")}
                    if event[2] == timerID then
                        timerID = 0;
                    end
                end
                rs.setOutput("right", false)
                timerID = os.startTimer(0.5)
                while timerID ~= 0 do
                    event = {os.pullEvent("timer")}
                    if event[2] == timerID then
                        timerID = 0;
                    end
                end
                if goUp == 1 then
                    arrived = (gps >= (nextGps - 2));
                else
                    arrived = (gps <= (nextGps + 2));
                end
                
            end
            tFloorInfo.currentFloor = tFloorInfo.currentFloor + goUp;
            print("NewGoUp and Currentfloor: ".. goUp .. " - ".. tFloorInfo.currentFloor);
            -- local nextFloor = tFloorClients[tFloorInfo.currentFloor + tFloorInfo["start"] + 1]

            upDateFloors()
        end
        print("finished")
        runningUpdates = runningUpdates - 1;
    end
    
    CCEventHandler:add( function()
        local status, error = pcall(func, number)
        if not status then
            print(error);
            debug.traceback("Error here: ");
            local timerID = os.startTimer(10)
            while timerID ~= 0 do
                event = {os.pullEvent("timer")}
                if event[2] == timerID then
                    timerID = 0;
                    os.reboot();
                end
            end
        end
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
    goToEvent = event(event);
    goToEvent:addCallback(goTo);
    -- goToEvent:addCallback(goTo);
    initEvent = event(event);
    initEvent:addCallback(initFloors)

    -- initEvent:addCallback(initFloors);
    updateEvent = event(event);
    -- updateEvent:addCallback(addFloorFunction)

    openModem()
    init()

    ccEventHandler:add(function ()
        local _, error = pcall(listenToEvents)
        print(error);
        print(debug.traceback());
        local timerID = os.startTimer(10)
            while timerID ~= 0 do
                event = {os.pullEvent("timer")}
                if event[2] == timerID then
                    timerID = 0;
                    os.reboot();
                end
            end
    end);
    ccEventHandler:start();

end

startFunction();

-- Programmstart


