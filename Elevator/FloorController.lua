pretty = require("cc.pretty")

---@class FloorController
local floorController = {}

local m

floorController.config = {

    ownPosition, ownChannel, globalChannel, receiverChannel, defaultTimeOut = 3, groundFloor, isClient = false
    -- "start" and "end" will be added from the ElevatorController
}

floorController.state = {

    ["ownGoal"] = nil,
    ["goalFloor"] = nil,
    ["currentFloor"] = nil,
    ["finished"] = nil,
    ["listenToEvent"] = nil,
    ["update"] = false
    
}

function floorController:init(config, modem, timeout , callback, ...)

    if(modem == nil) then
        error("Need modem as the second parameter.")
    end

    m = modem
    self:updateConfig(config)
    
    
    -- self.config._modem.transmit(updateChannel, 9999, 9999) TODO, + updateChannel is not a thing anymore
    m.open(self.config.ownChannel)

    m.open(self.config.globalChannel)


    if(self.config.isClient) then 
   
        
        local active = {active = true}
        updateFloors = function(...)
            active.active = false
            if(callback) then
                if(type(callback) == "table") then
                    if(callback.updateFloors) then
                    print("Calling")
                    callback.updateFloors(...)
                    elseif(callback.update) then
                        callback.update(...)
                    end
                else
                    callback(...)
                end
            end
        end

        err = function(...)
            active.active = false
            if(callback) then
                if(type(callback) == "table" and callback.error) then
                    callback.error()
                else
                    callback(...)
                end
            end
        end
        self:startUp()

        
        self:listenToNetworkEvents(active, timeout or self.config.defaultTimeOut, {updateFloors = updateFloors, error = err}, ...)
    else
        self:updateStatus(callback, ...)
    end
end

function floorController:listenToNetworkEvents(tbl_Active, timeout, callback, ...)

    local args = {...}
    local timer

    if(timeout) then 
        timer = os.startTimer(timeout)
    end
    
    print(tbl_Active);
    print(timeout);
    print(callback);
    print(args);
    while tbl_Active.active do
        local event, key, channel, _, data = os.pullEvent()
        if event=="modem_message" then
            print("got Event");
            if channel == self.config.ownChannel then
                if(type(data) == "table") then
                    self.config.ownPosition = data.floor
                    print("Got as answer: "..tostring(data.floor))
                    pretty.print(pretty.pretty(data))
                    
                end
                if(callback) then
                    if(type(callback) == "table") then
                        if(callback.success and data==true) then
                            callback.success(...)
                        elseif(callback.updateFloors and type(data) == "table") then
                            callback.updateFloors(...)
                        end
                    end
                end

            elseif channel == self.config.globalChannel then
                if(type(data) == "table" and data.info ~= nil) then
                    if(data.info.start ~= self.config.start or data.info["end"] ~= self.config["end"]) then
                        print("Update!!")
                        self.config.start = data.info.start
                        self.config["end"] = data.info["end"]
                        self.state.update = true
                    end
                    self.state.currentFloor = data.info.currentFloor
                    self.state.goalFloor = data.info.goalFloor
                    if(callback) then
                        if(type(callback) == "table" and callback.update) then
                            callback.update(args)
                        end
                    end
                elseif(data.command ~= nil) then
                    if(data.command == "startUp") then
                        self:startUp()
                    end
                end


            end


        elseif event=="timer" and key == timer then
            if(callback) then
                if(type(callback) == "table" and callback.error) then
                    callback.error()
                end
            end
            tbl_Active.active = false
            break
        end
    end


end

function floorController:goToFloor(number, callback, ...)
    
    m.transmit(self.config.receiverChannel, self.config.ownChannel, {command = "goTo", args = {floor = number}})
    local active = {active = true}
    --ToDo: indicate Loading?
    succ = function(...)
        active.active = false
        if(callback) then
            if(type(callback) == "table" and callback.success) then
                callback.success()
            else
                callback(...)
            end
        end
    end

    err = function(...)
        active.active = false
        if(callback) then
            if(type(callback) == "table" and callback.error) then
                callback.error()
            else
                callback(...)
            end
        end
    end

    local args = {...}
    self:listenToNetworkEvents(active, self.config.defaultTimeOut, {success = succ, error = err}, ...)

end

function floorController:updateStatus(callback, ...)
    local active = {active = true}

    m.transmit(self.config.receiverChannel, self.config.ownChannel, {command = "update"})

    up = function(...)
        active.active = false
        if(callback) then
            if(type(callback) == "table" and callback.update) then
                callback.update()
            else
                callback(...)
            end
        end
    end
    err = function(...)
        active.active = false
        if(callback) then
            if(type(callback) == "table" and callback.error) then
                callback.error(...)
            end
        end
    end

    self:listenToNetworkEvents(active, self.config.defaultTimeOut, {update = up, error = err})

end

function floorController:startUp()
    if(self.config.isClient) then
        print("I am a Client")
        local info = {}
        info.id = os.getComputerID()
        info.networkID = self.config.ownChannel
        for tries = 3, 0, -1 do
            _x, _y, _z = gps.locate()
            if(_x and _y and _z) then
                info.gps = {x = _x, y = _y, z = _z}
                info.groundFloor = self.config.groundFloor
                m.transmit(self.config.receiverChannel ,self.config.ownChannel, {command = "init", args = info})
                print("Send")
                return
            end
            os.sleep(1)
        end

        error("Could not get GPS signal!")
    end
end

function floorController:updateConfig(newConfig)

    print("Channel = ", newConfig.ownChannel)
    self.config.ownPosition = newConfig.ownPosition or self.config.ownPosition
    self.config.ownChannel = newConfig.ownChannel or self.config.ownChannel
    self.config.globalChannel = newConfig.globalChannel or self.config.globalChannel
    self.config.receiverChannel = newConfig.receiverChannel or self.config.receiverChannel
    self.config.defaultTimeOut = newConfig.defaultTimeOut or self.config.defaultTimeOut

end

function openChannel(channel)

    m.open(channel)

end

return floorController