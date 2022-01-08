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
    ["EventHandler"] = {code = "HiG0dTbR", path = "API/EventHandler.lua", requ = "API/EventHandler"},
    ["DependenciesScript"] = {code = "qndnG9Q6", path = "API/DependenciesScript.lua", requ = "API/DependenciesScript"},
    ["OOP"] = {code = "eERx21wN", path = "API/OOP.lua", requ = "API/OOP"},
    ["WindowHandler"] = {code = "x4EPvTUZ", path = "API/windowHandler.lua", requ = "API/windowHandler"},
    ["guiDrawSelf"] = {code = "aNFsa3B5", path = "API/guiDrawSelf.lua", requ = "API/guiDrawSelf"},
    ["CreateModRequestUI"] = {code = "6ek7uPec", path = "CreateModRequestUI.lua"},
    ["turtleController"] = {code = "5U5LaGwD", path = "API/turtleController.lua"},
    ["quarry"] = {code = "8xUKSSAZ", path = "quarry.lua"},
    ["Wood"] = {code = "0aNYtYhe", path = "wood.lua"},
    ["QuarryInterfaceV2"] = {code = "gi79PfVh", path = "API/QuarryInterfaceV2"},
    ["QuarryV2"] = {code = "6cAWHg9J", path = "QuarryV2"},
    ["cpm"] = {gitDownload = "ChristophLHR/CCraft/main/PackageManager/cpm.lua", path = "cpm.lua"},
    ["GitInstaller"] = {code = "493LbAC4", path = "GitInstaller.lua"},
}

cpm.commands = {
    ["install "] = cpm.Programms,
    ["update "] = cpm.Programms
}


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
        installOne(prog[dependency].code, prog[dependency].path)
    elseif type(dependency) == "table" then
        for _, dep in pairs(dependency) do
            if(type(dep) == "table") then
                -- print("DEP ",pretty.pretty(dep))
                -- print("Code ",pretty.pretty(dep.code),"Path ", pretty.pretty(dep.path))
                installOne(dep)
            elseif (type(dep) == "string") then
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
            cpm.gitDownload(dependencies.path, dependencies.gitDownload);
        elseif (dependencies.code ~=nil) then
            shell.run("pastebin", "run", "FuQ3WvPs "..dependencies.code.." "..dependencies.path);
        end
    end
    io.close(f)
end

function updateOne(dependencies)
    
    if(dependencies.gitDownload ~= nil) then
        fs.delete(dependencies.path);
        cpm.gitDownload(dependencies.path, dependencies.gitDownload);
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

function cpm.download(fileName, url)
    local request = http.get(url);
    if (request.getResponseCode() ~= 200) then return false end;
    
    local file = fs.open(fileName, "w");
    if(file == nil) then return false end;
    
    local content = request.readAll();
    file.write(content);
    file.close();
    return true;
end;

function cpm.gitDownload(fileName, url)
    return cpm.download("https://raw.githubusercontent.com/"..fileName, url);
end;

return cpm