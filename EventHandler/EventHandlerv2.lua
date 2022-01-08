-- ---> dependencies 
local dependencies = {
    "OOP"
}
local installer = require("cpm")
installer.install(dependencies);
-- dependencies <--- 


-- ---> Class Defenition
OOP = require(installer.Programms["OOP"].requ)

Event = OOP.class(function(ref,name, callbacks)
    ref.name = name
    ref.callbacks = callbacks or {}
end);

Event.__add = function ( ref, callback )
    return ref:addCallback(callback);
end

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