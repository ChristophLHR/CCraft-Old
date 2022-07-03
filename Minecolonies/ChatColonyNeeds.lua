Box = peripheral.find("chatBox");
C = peripheral.find("colonyIntegrator");

Actions = {
    ["Info"] = function (username) GetInfos(username) end,
    ["Req"] = function (username, message)  end,
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
        print(username);
        print(v.id);
        print(v.type);
        Box.sendMessageToPlayer(v.id, username,v.type);
    end
end

function GetReq(username, message)
    local t = C.getWorkOrderResources(message[2]);
    for _,v in pairs(t) do
        if v.needed > 0 then
            Box.sendMessageToPlayer(v.needed, username, v.displayName);
        end
    end
end

function Main()
    while true do
        local _, username, message = os.pullEvent("chat");
        CheckAction(username, message)
    end
end;

Main();