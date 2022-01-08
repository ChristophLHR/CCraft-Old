wQuarry = require("API/windowHandler")
local modem = peripheral.wrap("back")


local parentWindow
local tabWindows = {}
local windowWidth, windowHeight
local tabButtons = {}
local tabBox
local colorTable = {colors.red, colors.green, colors.blue}
local activeWindow = 1
local digX, digY, digZ, build
local statusText

function addTabButtons()

    for i = 0, 2 do

        xPos = i*4 + 2 -- Here
        yPos = 2
        table.insert( tabButtons, wQuarry:addButton(xPos, yPos, i + 1, colors.white, colorTable[i + 1], 3, 2, parentWindow, switchTabTo, i + 1) )

    end

end

function initTabs()

end

function switchTabTo(args)

    number = args[1]
    activeWindow = number

    for i = 1, 3 do
        if(i ~= number) then
            wQuarry:setVisible(tabWindows[i],false)
        else
            wQuarry:setVisible(tabWindows[i],true)
        end
    end

    wQuarry:editBox(tabBox, nil, nil, colorTable[number])

    wQuarry.drawChanges = true

end

function com(modemID) --TODO

    modem.open(os.getComputerID())
    modem.transmit(modemID, os.computerID(), {X = digX,Y = digY, Z = digZ, build = build})
    os.startTimer(2)
    local event, side, channel, rplyChannel, msg, distance = os.pullEvent()
    return "modem_message" == event and rplyChannel == modemID and msg == true

end

function startQuarry()

    wQuarry:editText(statusText, nil, nil, "Sending...", colors.gray)
    wQuarry.drawChanges = true
    local succ = com(21)
    if(succ) then
        wQuarry:editText(statusText, nil, nil, "Starting...", colors.green)
    else
        wQuarry:editText(statusText, nil, nil, "Error...", colors.red)
    end
    wQuarry.drawChanges = true

end

function init()

    -- reset all windows
    wQuarry.windows = {}


    term.clear()
    print("Yes, - this will all be in the UI soon")
    print("Positive is the Block in to the left \nX: ")
    digX = tonumber(read())
    print("Positive is the Block in Front\nY: ")
    digY = tonumber(read())
    print("Positive is the Block up\nZ: ")
    digZ = tonumber(read())
    
    print("(x) represents the Slot in the Inventory")
    print("Build Floor(2), Wall(3) and Ceiling(4)? Y/N")
    build = read()
    if(build == "Y" or build == "y") then 
        build = true
    else 
        build = false
    end

    print("TurtleID (Should be displayed on the Turtle Monitor): ")
    local modemID = tonumber(read())

    -- com(modemID)
    

    local width, height = term.current().getSize()
    parentWindow = wQuarry:createWindow(term.current(), 1, 1, width, height, "parentWindow")

    windowWidth, windowHeight = parentWindow.getSize()
    local posX = 1 + 2 -- + Border
    local posY = 4 + 2 -- + Border
    local newWidth = windowWidth - posX * 2 - 1 -- - Border
    local newHeight = windowHeight - posY - 1 -- - Border

    table.insert(tabWindows, wQuarry:createWindow(parentWindow, posX, posY, newWidth, newHeight, "xWindow"))
    table.insert(tabWindows,wQuarry:createWindow(parentWindow, posX, posY, newWidth, newHeight, "yWindow"))
    table.insert(tabWindows,wQuarry:createWindow(parentWindow, posX, posY, newWidth, newHeight, "zWindow"))
    wQuarry:setVisible(tabWindows[2],false)
    wQuarry:setVisible(tabWindows[3],false)
    tabWindows[1].setBackgroundColor(colors.white)
    tabWindows[1].setTextColor(colors.black)
    tabWindows[2].setBackgroundColor(colors.white)
    tabWindows[2].setTextColor(colors.black)
    tabWindows[3].setBackgroundColor(colors.white)
    tabWindows[3].setTextColor(colors.black)

    addTabButtons()
    tabBox = wQuarry:addBox(posX - 1, posY - 1, colorTable[1], newWidth + 1, newHeight +1, parentWindow)

    wQuarry:addText(2,2,digX, nil, nil, tabWindows[1])
    wQuarry:addText(2,2,digY, nil, nil, tabWindows[2])
    wQuarry:addText(2,2,digZ, nil, nil, tabWindows[3])
    
    wQuarry:addButton(windowWidth - 6, 1, "Start", colors.white,colors.green , 6, 3, parentWindow, startQuarry)
    statusText = wQuarry:addText(1,windowHeight,"Waiting for Confirm", colors.white, nil, parentWindow)
end

init()
wQuarry:listenToEvents(0.5)