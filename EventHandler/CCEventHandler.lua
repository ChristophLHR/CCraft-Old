---TODO: ErrorHanding | 
---Allows you to run multiple Events at the same time.
---Make sure the "Main" function is added to the Eventhandler bevor starting it.
---Events like "read" will not work at all.
---Events like os.sleep might get triggert if there are other time events, as it does not check if the correct id is set
---os.startTimer(x) is better, as it gets an id back
---@class CCEventHandler
CCEventHandler = {run = false, coroutines = {}}
local Prefix = "[EventHandler]";

--- Adds the function/thread. Runs automaticly.
--- Will only stop if CC yields (on any pullEvent f.e.)
---@param c thread | function will run until yielded while adding
---@return integer No the Index the function has inside of the EventHandler
function CCEventHandler:add(c)
    if type(c) == "function" then
        c = coroutine.create(c);
    end
    assert(type(c) == "thread", Prefix.."You can only add type thread | function. Got type "..type(c))
    
    table.insert(self.coroutines, c)
    coroutine.resume(c);
    return #self.coroutines + 1
end

---Make shure the "Main" function is added to the Eventhandler bevor starting it.
---It will run in set run = true and run infinitly unless stopped from the outside
function CCEventHandler:start()
    if self.run == true then return end

    self.run = true
    local event
    local deadEvents = {}
    while self.run do
        event = {os.pullEvent()}
        assert(#self.coroutines > 0, "You have started the EventHanlder without any Function to run - would do nothing indefinitely")
        deadEvents = {}
        for i, value in ipairs(self.coroutines) do
            if coroutine.status(value) == "dead" then
                table.insert(deadEvents,i)
            else 
                coroutine.resume(value, table.unpack(event))
            end
        end
        for _, dead in ipairs(deadEvents) do
            table.remove(self.coroutines, dead)
        end
    end
end
--- WIP!
--- Will currently only get basic inputs, no special keys (Shift, etc.) supported
---@return string
function CCEventHandler.read()
    
    local function getKeyPress(key)
        local t = {
            ["one"] = 1, ["two"] = 2, ["three"] = 3, ["four"] = 4, ["five"] = 5,
            ["six"] = 6, ["seven"] = 7, ["eight"] = 8, ["nine"] = 9, ["zero"] = 0
        }
        local k = keys.getName(key);
        if t[k] ~= nil then
            return t[k]
        end
        return k;
    end
    local t = function()
        local e, key
        local keysPressed = "";
        while true do
            e = ""
            while e ~= "key" do
                e, key = os.pullEvent();
            end
            if getKeyPress(key) == "enter" then
                return keysPressed
            else
                keysPressed = keysPressed..getKeyPress(key)
            end
        end
     end
     local status, txt = pcall(t);

    if not status then
        print("Error"..txt)
        txt(txt)
    else
        return txt
    end
end

return CCEventHandler
