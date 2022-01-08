-- Sub-Table for "WindowHandler" - API

local guiDrawSelf = {}

function guiDrawSelf:button (window, object, handlerRef)

    -- Draw Box
    self:box(window,object,handlerRef)
    -- Create text objekt to be drawn
    local txt = {}
    setmetatable(txt, {__index=object})
    txt.x = txt.x + math.floor(txt.width / 2) - (math.floor(#tostring(txt.text) / 2))
    txt.y = txt.y + math.floor(txt.height / 2)

    -- Draw text
    self:text(window,txt,handlerRef)


end

function guiDrawSelf:text (window, object, handlerRef)

    -- Set colors
    local oldColors = handlerRef:setColors(window,object)

    -- Draw
    handlerRef:writeAt(object.x, object.y, object.text, window)
    -- Reset colors
    handlerRef:resetColors(window,oldColors)
    
end

function guiDrawSelf:box (window, object, handlerRef)

    -- set colors and redirect everything "toBeCreated" to the window
    local oldColors = handlerRef:setColors(window,object)
    handlerRef:redirectTo(window)

    -- Draw box with paintutils lib
    -- the paintutils lib. does, for some reason, not reset the backgroundColor to what is was before...
    paintutils.drawFilledBox(object.x, object.y , object.width + object.x, object.height + object.y, object.backgroundColor)
    
    -- reset colors and redirect to the older Window
    handlerRef:redirectToOld(window)
    handlerRef:resetColors(window,oldColors)

end

return guiDrawSelf