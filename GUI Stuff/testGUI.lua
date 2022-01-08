w = require("API/windowHandler")

local leftWindow = w:addWindowAsMonitor("left","leftMonitor")

local function toggleListener()
    if(w.continueListener == true) then
        w.continueListener = false
        w:printDev("Listener => false")

    else
        -- Does not work like that, the event never gets listened to
        w:printDev("Listener => actived")
        w:listenToEvents(3)
    end
end

local function changeButtonColors()
    w:printDev("Text: "..toggleEventButton.text)
    w:editButton(toggleEventButton, nil, nil, nil, colors.white, colors.black, nil, toggleListener)
    -- w:editButton(changeEventButton, nil, nil, "I don't do anything anymore", colors.black, colors.white, nil, nil)
    w:removeObject(changeEventButton, w.windows.leftMonitor)
    w:editText(txt, nil, nil, "Things were Modified", colors.red, nil, nil)
    w.drawChanges = true
end



toggleEventButton = w:addButton(8,8,"toggle event listener",colors.black, colors.white, 1, w.windows.leftMonitor, toggleListener)
changeEventButton = w:addButton(8,11,"ChangeButtonColors",colors.black, colors.yellow, 2, w.windows.leftMonitor, changeButtonColors)


txt = w:addText(1,1, "Header", nil, nil, w.windows.leftMonitor)

w.drawChanges = true
w:listenToEvents(1)