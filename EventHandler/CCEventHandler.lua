---Allows you to run multiple Events at the same time.
---Make sure the "Main" function is added to the Eventhandler bevor starting it.
---Events like "read" will not work at all.
---Events like os.sleep might get triggert if there are other time events, as it does not check if the correct id is set
---os.startTimer(x) is better, as it gets an id back
---@class CCEventHandler
CCEventHander = {run = false, coroutines = {}}
local Prefix = "[EventHandler]";

--- Adds the function/thread. Runs automaticly.
--- Will only stop if CC yields (on any pullEvent f.e.)
---@param c thread | function will run until yielded while adding
---@return integer No the Index the function has inside of the EventHandler
function CCEventHander:add(c)
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
function CCEventHander:start()
    if self.run == true then return end

    self.run = true
    local event
    -- os.sleep(1)
    while self.run do
        event = {os.pullEvent()}
        assert(#self.coroutines > 0, "You have started the EventHanlder without any Function to run - would do nothing indefinitely")
        for _, value in ipairs(self.coroutines) do
            coroutine.resume(value, table.unpack(event))
        end
    end
end