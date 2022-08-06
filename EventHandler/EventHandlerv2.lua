-- ---> dependencies 
local dependencies = {
    "OOP"
}
local installer = require("cpm")
installer.install(dependencies);
-- dependencies <--- 


-- ---> Class Defenition
--- init Class of Event
--- local e = require Event
--- local customEvent = e()
---@class OOP
OOP = require("API/OOP")

---@class EventHandler
Event = OOP.class(function(ref,name, callbacks)
    ref.name = name
    ref.callbacks = callbacks or {}
end);
--- Called like this: _ = <EventHandler> e + function() print("Do stuff") end |
--- Its an Overwrite of "+"
---@param ref table self
---@param callback function
---@return integer
Event.__add = function ( ref, callback )
    return ref:addCallback(callback);
end
---@param callback function
---@return integer
function Event:addCallback(callback)
    if(type(callback)=="function") then
        table.insert( self.callbacks, callback )
    end
    return #self.callbacks
end

function Event:getName()
    return self.name
end

function Event:invoke(...)
    if(self == nil) then
        print("Event has no self reference.\n=> Therefore no CallbackList \nHappens if uses 'Event.invoke()' instead of Event:invoke()")
        return nil
    end
    for _, func in pairs(self.callbacks) do
        func(...)
    end
end
-- <--- Class Defenition
return Event