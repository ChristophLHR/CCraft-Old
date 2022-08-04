-- ToDo: Beim neuzeichnen der Elemente fragen ob ein element sich hinter dem Pixel befindet, um im anschluss das Entsprechende Element neu zu Zeichnen
---@class windowHandler
windowHandler = {windows = {}, continueListener = false, drawChanges = false, windowIDMax = 0}

local dependencies = {
    "guiDrawSelf",
    "EventHandler"
}
local installer = require("cpm")
installer.install(dependencies);

-- local pretty = require("cc.pretty")
package.loaded.guiDrawSelf = nil
local GuiDrawSelf = require("API/guiDrawSelf")

local EventHandler = require("API/EventHandler")

function windowHandler:addWindowAsMonitor (monitorPosition, windowName, oldWindow)

    oldWindow = oldWindow or term.current()
    -- wrap Monitor
    local monitor = peripheral.wrap(monitorPosition)
    monitor.restoreTo = term.current() -- Remember last Terminal

    monitor.setTextScale(0.5) -- set Resolution to Max
    local width, height = monitor.getSize() -- get total Px

    --Create Window
    local w  = window.create(monitor, 1, 1, width, height)
    self:addWindow(w, monitor, windowName)
    return w

end 

function windowHandler:linkWindowParent(window, parent)

    if(parent.children) then

        table.insert( parent.children, window )

    else

        parent.children = {window}
        
    end

    window.parent = parent

    -- If the parent is not known, the window is a Root window
    window.isRoot = true
    for key, w in pairs(self.windows) do

        if(w == parent) then window.isRoot = false end

    end

end

function windowHandler:createWindow(parent, x, y, width, height, windowName)

    newWindow = window.create(parent, x, y, width, height)

    self:addWindow(newWindow, parent, windowName)

    return newWindow

end

function windowHandler:addWindow(window, parent, windowName)

    --Check if it is (most likly) the correct type
    if(window.redraw) then

        self:linkWindowParent(window, parent)
        window.id = self.windowIDMax
        window.visible = true
        window.enableXDrag = window.enableXDrag or false
        window.enableYDrag = window.enableYDrag or false

        self.windowIDMax = self.windowIDMax + 1

        if(windowName) then

            self.windows[tostring(windowName)] = window

        else 

            local id = countKeyValueTable(self.windows)
            self.windows[tostring(id)] = window

        end

        if(window.guiObjecte == nil) then
            window.guiObjecte = {}
            window.maxID = 0
        end

        return window

    else

        self:printError("The object provided was not an window Element. - Function: addWindow")

    end

end

function windowHandler:removeWindow(index)

    if(type(index)=="string") then

        self.windows[index] = nil

    else

        return table.remove(self.windows, index)

    end

end

function windowHandler:setVisible(window, state, instant)

    window.visible = state
    if(instant) then 
        window.setVisible(state)
    end

end

function windowHandler:writeAt(x,y,string, window, textColor, backgroundColor)
    
    window = window or term.current()
    window.setCursorPos(x,y)
    window.write(string)

end

function windowHandler:redirectTo(window)

    --Sets the activeWindow. Can be an Monitor, can be a window within that monitor....
    if(window ~= term.current()) then
        window.restoreTo = term.redirect(window)
        self.activeWindow = window -- this could be problematic
    end

end

function windowHandler:redirectToOld(object)


    if(object.restoreTo) then

        term.redirect(object.restoreTo)

    else
        self:printDev("There is no redirectTo")
    end

end

function windowHandler:addBaseObject(x, y, width, height, window)

    -- create base element
    local baseElement = {}
    baseElement.x = x
    baseElement.y = y
    baseElement.width = width
    baseElement.height = height
    

    if(window.maxID == nil) then self:printError("Window was not added to the Handler Correctly") end

    baseElement.id = window.maxID
    window.maxID = window.maxID + 1

    -- add element to window
    if(window.guiObjecte) then table.insert(window.guiObjecte, baseElement)
    else window.guiObjecte = {baseElement} end

    -- return created element
    return baseElement

end

function windowHandler:editBaseObject(object, x, y, width, height)

    -- record old state of the object
    object.oldX = object.x
    object.oldY = object.y
    object.oldWidth = object.width
    object.oldHeight = object.height

    -- update object
    object.x = x or object.x
    object.y = y or object.y
    object.width = width or object.width
    object.height = height or object.height

    return object

end
---@param object table Element on a Window
---@param eventName string
---@return EventHandler
function windowHandler:getEventHandler(object, eventName)
    if(object.event==nil)then
        object.event = EventHandler(eventName or "ClickEvent")
    end
    return object.event
end

function windowHandler:addText(x, y, text, textColor, backgroundColor, window)

    --create text obj
    local txt = self:addBaseObject(x, y, #tostring(text), 1, window)
    txt.type = "text"
    txt.text = text

    -- set colors
    txt.textColor = convertColors(textColor) or window.getTextColor()
    txt.backgroundColor = convertColors(backgroundColor) or window.getBackgroundColor()

    -- return created element
    return txt

end

function windowHandler:editText(object, x, y, newText, newTextColor, newBackGroundColor )
    
    self:editBaseObject(object, x, y, #tostring(newText), 1)
    object.text = newText or object.text
    object.textColor = convertColors(newTextColor) or object.textColor
    object.backgroundColor = convertColors(newBackGroundColor) or object.backgroundColor

end

function windowHandler:addBox(x, y, backgroundColor, width, height, window)

    local box = self:addBaseObject(x, y, width, height, window)
    box.type = "box"
    box.backgroundColor = convertColors(backgroundColor) or window.getBackgroundColor()
    
    return box

end

function windowHandler:editBox(object, x, y, newBackgroundColor, width, height)

    self:editBaseObject(object, x, y, width, height)
    object.backgroundColor = convertColors(newBackgroundColor) or object.backgroundColor
    
end

function windowHandler:addButton(x, y , text, textColor, backgroundColor, width, height, window)

    window = window or self.activeWindow or term.current()
    
     -- create button object
    local button = self:addBaseObject(x, y, width, height, window)
    button.type = "button"
    button.padding = padding or 1
    button.text = text

    -- set colors
    button.textColor = convertColors(textColor) or window.getTextColor()
    button.backgroundColor = convertColors(backgroundColor) or window.getBackgroundColor()

    -- return create element
    return button

end

function windowHandler:editButton(object, x, y, newText, newTextColor, newBackgroundColor, newWidth, newHeight)

    newText = newText or object.text
    newHeight = newHeight or object.height
    newWidth = newWidth or object.width

    self:editBaseObject(object, x, y, newWidth, newHeight)
    object.text = newText
    object.textColor = convertColors(newTextColor) or object.textColor
    object.backgroundColor = convertColors(newBackgroundColor) or object.backgroundColor

end

function windowHandler:removeObject(object, window)

    local id = object.id or object -- in case someone passes the id direktly
    if(id) then

        -- the ID is not always the key
        local index = getIndex(window.guiObjecte, id)
        if index ~= nil then

            return table.remove(window.guiObjecte, index)

        end

    end

end

function windowHandler:drawObjectOnWindow(window, object)

    if(object.x and object.y and object.width and object.height) then
    
        GuiDrawSelf[object.type](GuiDrawSelf,window, object, self)
        
    else

        self:printDev("Object not fully set.")
        self:printDev("Object requires x,y,width and height")
        self:printDev("And some other stuff maybe, API is still WIP :P")

        self:printError(object)

    end

end

function windowHandler:drawAllWindowObjects(window)

    window.setVisible(false)
    if(window.visible) then

        
        if(window.guiObjecte) then
            
            for key, value in pairs(window.guiObjecte) do
                
                self:drawObjectOnWindow(window, value)
                
            end
            
        end
        
        window.setVisible(true)

    end
    

end

function windowHandler:drawChildren(w)

    self:drawAllWindowObjects(w)
    if(w.children) then

        for key, window in pairs(w.children) do
            self:drawChildren(window)

        end

    end
end

function windowHandler:drawAllWindows()

    -- reset all Windows first
    for key, window in pairs(self.windows) do

        window.clear()

    end

    -- Then draw all Windows in the Order Parent -> Child --> ChildOfChild
    for key, window in pairs(self.windows) do
        
        
        -- es sollen zuerst die RootWindows gezeichnet werden
        if(window.isRoot == true) then
            self:drawChildren(window)
        end
    end

end

function windowHandler:moveWindow(window, moveXBy, moveYBy)

    -- WIP
    local x,y = window.getPosition()
    window.reposition(x + moveXBy, y + moveYBy)

end
---comment
---@param tickRate number in seconds - Updatetimer for Screen(s)
---@param dragTimer number in secons - If drag enabled, how long after a click is a drag event
function windowHandler:listenToEvents(tickRate, dragTimer)
    -- Event are:
    -- Timouts (at which the elements will be redrawn)
    -- and Monitor Touches


    -- No motiviation to make the variables Global or the implement a Global Handler all together - so
    defaultEventTable = {
        ["timer"] = function (windowHandlerRef, frameTimer, name)

            if windowHandlerRef.drawChanges then
            
                windowHandlerRef.drawChanges = false
                windowHandlerRef:drawAllWindows()

            end
            os.cancelTimer(frameTimer)
            frameTimer = os.startTimer(tickRate)

        end
    }


    local frameTimer = os.startTimer(tickRate)
    self.continueListener = true
    self.drawChanges = true


    while self.continueListener do
        
        local event, side, xPos, yPos = os.pullEvent()
        if event == "monitor_touch" or event == "mouse_click" then
            -- This could / should be handled in its own Programm, as to avoid voiding Events
            -- But this is WIP so sue me b-tch
            local dragEventsTriggert = 0
            if(dragTimer) then

                local dragTimeOut = os.startTimer(dragTimer)
                local stillDragging = true
                local oldX = xPos
                local oldY = yPos
                -- if a dragTimer is set, and didnt trigger (stillDraggin = false), move Windows
                while (dragTimer ~= nil) and stillDragging do

                    local newEvent, newSide, newXPos, newYPos = os.pullEvent()

                    if newEvent == "monitor_touch" or newEvent == "mouse_click" or newEvent == "mouse_drag" then

                        -- changeDetection
                        self.drawChanges = true

                        --count Events
                        dragEventsTriggert = dragEventsTriggert + 1

                        -- reset Timer
                        os.cancelTimer(dragTimeOut)
                        dragTimeOut = os.startTimer(dragTimer)

                        -- get Windows with enabled Drag
                        local windows = getDragableWindows(self.windows)

                        -- each window with Drag enabled => Move
                        for key, window in pairs(windows) do

                            local modX = 0
                            local modY = 0
                            if(window.enableXDrag) then modX = newXPos - oldX end
                            if(window.enableYDrag) then modY = newYPos - oldY end

                            self:moveWindow(window, modX , modY)

                        end

                        -- new "old" mouse Position
                        oldX = newXPos
                        oldY = newYPos

                    elseif newEvent == "timer" and newSide == dragTimeOut then
                        stillDragging = false
                    else
                        
                        if(defaultEventTable[newEvent]) then
                            defaultEventTable[newEvent](self, frameTimer, newSide)
            
                        end

                    end
                end
            end

            if dragEventsTriggert == 0 then
                -- First Check if things got Draged
                local collidedWith = {}
                for wKey, window in pairs(self.windows) do
                    if window.visible then

                        local absXPos = xPos
                        local absYPos = yPos
                        -- Cut Collisions that were out of bounds of the Parent Window


                        if (window.parent and window.parent.getPosition) then
                            
                            local parentWindow = window.parent
                            local parentSize = {parentWindow.getSize()}
                            local parentPos = {parentWindow.getPosition()}
                            parentWindow = window

                            if(xPos > parentPos[1] and  xPos < parentPos[1] + parentSize[1]) then

                                if(yPos > parentPos[2] and yPos < parentPos[2] + parentSize[2]) then

                                    -- "moving" the objects relative to the absolute position of the window in the collision detection
                                    while parentWindow.parent do

                                        local x, y = parentWindow.getPosition()
                                        absXPos = absXPos - (x - 1)
                                        absYPos = absYPos - (y - 1)
                                        parentWindow = parentWindow.parent

                                    end

                                    -- Calling CollisionFunction with new X,Y Positions
                                    local col = self:collision(window, absXPos, absYPos)
                                    table.insert( collidedWith, col )

                                end
                            end

                        else

                            -- Calling CollisionFunction with old X,Y Positions
                            local col = self:collision(window, absXPos, absYPos)
                            table.insert( collidedWith, col )

                        end
                    end
                end

                for key, value in pairs(collidedWith) do
                    for wKey,wValue in pairs(value) do
                        
                        if wValue.event ~= nil then wValue.event:invoke(wValue.parameter) end

                    end

                end
            end

        else

            if(defaultEventTable[event]) then
                
                defaultEventTable[event](self, frameTimer, side)

            end

        end

    end

end

function windowHandler:collision(window, x, y)

    local collisionObjects = {}

    for key, value in pairs(window.guiObjecte) do

        if(value.x <= x and value.x + value.width >= x) then

            if(value.y <= y and value.y + value.height >= y) then

                table.insert( collisionObjects, value )

            end

        end

    end

    return collisionObjects

end

function windowHandler:setColors(window, object)
    
    local color = {["text"] = window.getTextColor(),
        ["background"] = window.getBackgroundColor()
    }
    
    if object.textColor then 
        window.setTextColor(object.textColor)
    end
    if object.backgroundColor then
        window.setBackgroundColor(object.backgroundColor)
    end
    
    return color
    
end

function windowHandler:resetColors(window, colorTable)

    window.setTextColor(colorTable.text)
    window.setBackgroundColor(colorTable.background)
    
end

function windowHandler:printInfo()
    
    term.clear()
    local i = 1
    self:writeAt(1,1,"I have " ..#self.windows.." windows")

    for key, value in pairs(self.windows) do

        self:writeAt(1,i,"Window no."..i.." with key: "..key.." X/Y: => "..value.getSize())
        i = i + 1

    end

end

function windowHandler:howTo()

    clear()
    self:writeAt(1,1, "'windowHandler:functionName', this has the 'self'-reference")
    self:writeAt(1,2, "ALL windowObjects may contain:")
    self:writeAt(3,3, "'x' and 'y'(relative to their window)")
    self:writeAt(3,4, "'type'(of the element) and 'event'")
    self:writeAt(3,5, "'width' and 'height'")

end

function windowHandler:printError(text)

    self:printDev(text)
    sleep(4)
    self:printDev(debug.traceback())

end

function windowHandler:printDev(text)
    if not self.devMode then return end;

    local native = term.native()
    local x, y = native.getCursorPos()
    local maxX, maxY = native.getSize()
    if y >= maxY - 1 then
        native.scroll(1)
        y = maxY - 1
    else
        y = y + 1
    end
    -- windowHandler:writeAt(1,y,tostring(text), native)
    windowHandler:writeAt(1,y, debug.traceback(text), native)
    os.sleep(3);
end

function countKeyValueTable(t) 
    local count = 0

    for _, _ in pairs(t) do
        count = count + 1
    end

    return count
end

function convertColors(color)

    if type(color) == "string" then color = colors[color] end
    return color

end

function getIndex(t, id)

    local index
    for key,element in pairs(t) do

        if element.id == id then return key end

    end

end

function getDragableWindows(windows)
    local _windows = {}

    for key,window in pairs(windows) do

        if(window.enableXDrag or window.enableYDrag)then

            table.insert( _windows, window )

        end

    end

    return _windows
end



return windowHandler


-- Test stuff
-- w = require("API/windowHandler")
-- w:addText(1,1,"Text",nil, nil, w.windows.test)