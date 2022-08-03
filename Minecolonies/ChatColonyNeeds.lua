Box = peripheral.find("chatBox");
C = peripheral.find("colonyIntegrator");
Pretty = require("cc.pretty");
Actions = {
    ["Info"] = function (username) GetInfos(username) end,
    ["Req"] = function (username, message) GetReq(username, message) end,
}

function Split(s, delimiter)
    local result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function CheckAction(username, message)
    print(username.. " wrote ".. message);
    message = Split(message, " ");
    if type(Actions[message[1]]) == "function" then
        Actions[message[1]](username, message);
    end
end;

function GetInfos(username)
    local t = C.getWorkOrders();
    for _,v in pairs(t) do
        print(username.." ".. v.id .. " " .. v.type.. "!");
        Box.sendMessageToPlayer(tostring(v.id), username,v.type);
        os.sleep(1);
    end
end

function GetReq(username, message)
    local t = C.getWorkOrderResources(tonumber(message[2]));
    print(Pretty.pretty(t));
    for _,v in pairs(t) do
        print((v.displayName) .. " needed: " ..v.needed);
        if( v.needed > 0 )then
            Box.sendMessageToPlayer(tostring(v.needed), username, v.displayName);
            os.sleep(1);
        end
    end
end

function Main()
    while true do
        local _, username, message = os.pullEvent("chat");
        CheckAction(username, message);
    end
end;

Main();