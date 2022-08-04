----------------------------------------------------
-- USAGE -------------------------------------------
-- cpm.install(dependencies)


-- dependencies Type
-- (string needs to be one of the allready implemented ones in the cpm.Programms)
-- Table of strings

-- OR

-- (Can be used to Install custom programms) =>
-- Table of tables
-- [Name : string] = {

-- + code : string (Pastebin code),
-- + gitDownload : string (GitHub RAW Code),
-- + path : string (Path the file should be at )
-- + requ : string (Forgot what this was for)

-- }

local args = {...}
local pretty = require("cc.pretty")

cpm = {}

cpm.Programms = 
{
    ["CC-EventHandler"] = {gitDownload = "ChristophLHR/CCraft/main/EventHandler/CCEventHandler.lua", path = "API/CC-EventHandler.lua"},
    ["MiningScript"] = {gitDownload = "ChristophLHR/CCraft/main/Turtle/Mining/MiningScript.lua", path="API/MiningScript.lua"},
    ["MiningInterFace"] = {gitDownload = "ChristophLHR/CCraft/main/Turtle/Mining/MiningInterface.lua",  path = "Mining.lua"},
    ["ChatColony"] = {code = "dnxDhTPa", gitDownload = "ChristophLHR/CCraft/main/Minecolonies/ChatColonyNeeds.lua", path = "ChatColony.lua"},
    ["EventHandler"] = {gitDownload = "ChristophLHR/CCraft/main/EventHandler/EventHandlerv2.lua", code = "HiG0dTbR", path = "API/EventHandler.lua"},
    ["OOP"] = {gitDownload = "ChristophLHR/CCraft/main/Basics/OOP.lua", code = "eERx21wN", path = "API/OOP.lua", requ = "API/OOP"},
    ["WindowHandler"] = {gitDownload = "ChristophLHR/CCraft/main/GUI%20Stuff/WindowHandler.lua", code = "x4EPvTUZ", path = "API/windowHandler.lua"},
    ["guiDrawSelf"] = {gitDownload = "ChristophLHR/CCraft/main/GUI%20Stuff/GUIDrawSelf.lua", code = "aNFsa3B5", path = "API/guiDrawSelf.lua"},
    ["CreateModRequestUI"] = {code = "6ek7uPec", path = "CreateModRequestUI.lua"},
    ["turtleController"] = {gitDownload = "ChristophLHR/CCraft/main/Turtle/TurtleControler.lua", code = "5U5LaGwD", path = "API/turtleController.lua"},
    ["quarry"] = {code = "8xUKSSAZ", path = "quarry.lua"},
    ["Wood"] = {gitDownload = "ChristophLHR/CCraft/main/Turtle/WoodChuck.lua",code = "0aNYtYhe", path = "wood.lua"},
    ["QuarryInterface"] = {code = "gi79PfVh", path = "API/QuarryInterface.lua"},
    ["TrackInterface"] = {gitDownload = "ChristophLHR/CCraft/main/Turtle/Track/TrackInterface.lua" , path = "API/TrackInterface.lua"},
    ["Quarry"] = {gitDownload = "ChristophLHR/CCraft/main/Turtle/Quarry.lua", path = "Quarry.lua"},
    ["Track"] = {gitDownload = "ChristophLHR/CCraft/main/Turtle/Track/Track.lua", path = "Track.lua"},
    ["cpm"] = {gitDownload = "ChristophLHR/CCraft/main/PackageManager/cpm.lua", path = "cpm.lua"},
    ["GitInstaller"] = {code = "493LbAC4", path = "GitInstaller.lua"},
}
-- pastebin run "493LbAC4" "https://raw.githubusercontent.com/ChristophLHR/CCraft/main/PackageManager/cpm.lua" "cpm.lua" "run"

cpm.commands = {
    ["install "] = cpm.Programms,
    ["update "] = cpm.Programms
}

function cpm.download(fileName, url)
    local request = http.get(url);
    if (request == nil or request.getResponseCode() ~= 200) then return false end;
    
    local file = fs.open(fileName, "w");
    if(file == nil) then return false end;
    
    local content = request.readAll();
    file.write(content);
    file.close();
    return true;
end;

function cpm.gitDownload(fileName, url)
    return cpm.download(fileName,"https://raw.githubusercontent.com/"..url);
end;

local function fillOut(shell, index, argument, previous)
    local currArg = cpm.commands
    for i = 2, #previous do
        if currArg[previous[i].." "] then
            currArg = currArg[previous[i].." "]
        else
            return nil 
        end
    end
    
    local results = {}
    for word, _ in pairs(currArg) do
        if word:sub(1, #argument) == argument then
            results[#results+1] = word:sub(#argument + 1)
        end
    end
    return results;
end

function install(dependency)
    -- print("All => ", pretty.pretty(dependency))
    local prog = cpm.Programms
    if type(dependency) == "string" then
        if (prog[dependency] == nil) then
            error(dependency.." not found");
        end
        installOne(prog[dependency])
    elseif type(dependency) == "table" then
        for _, dep in pairs(dependency) do
            if(type(dep) == "table") then
                -- print("DEP ",pretty.pretty(dep))
                -- print("Code ",pretty.pretty(dep.code),"Path ", pretty.pretty(dep.path))
                installOne(dep)
            elseif (type(dep) == "string") then
                if (prog[dep] == nil) then
                    error(dep.." not found");
                end
                installOne(prog[dep])
            end

        end
    else
        print("Could not Install, wrong type <string|table>. Got", type(dependency));
    end
end

function installOne(dependencies)

    local f = io.open(dependencies.path)
    if(f == nil) then
        if(dependencies.gitDownload ~= nil) then
            if not cpm.gitDownload(dependencies.path, dependencies.gitDownload) then
                print('Could not install '..dependencies.path);
                error('At: '..dependencies.gitDownload);
            end
        elseif (dependencies.code ~=nil) then
            shell.run("pastebin", "run", "FuQ3WvPs "..dependencies.code.." "..dependencies.path);
        else
            error("Missing path / gitDownload");
        end
    end
    io.close(f)
end

function updateOne(dependencies)
    
    if(dependencies.gitDownload ~= nil) then
        fs.delete(dependencies.path);
        if not cpm.gitDownload(dependencies.path, dependencies.gitDownload) then
            print('Could not update '..dependencies.path);
                error('At: '..dependencies.gitDownload);
        end
    elseif(dependencies.code ~= nil) then
        shell.run("pastebin", "run", "FuQ3WvPs "..dependencies.code.." "..dependencies.path);
    end
end

if #args == 0 then
    shell.setCompletionFunction("cpm.lua", fillOut)
elseif args[1] == "update" then
    if(args[2]==nil) then
        shell.run("pastebin run", cpm.Programms.GitInstaller.code , "https://raw.githubusercontent.com/"..
        cpm.Programms.cpm.gitDownload, cpm.Programms.cpm.path, "run");
    else
        -- should all be string, only accessable though the shell (so far)
        local prog = cpm.Programms[args[2]]
        updateOne(prog)
        
    end
elseif args[1] == "install" then
    install(args[2]);
end

function cpm.install(dependency)
    install(dependency)
end

return cpm