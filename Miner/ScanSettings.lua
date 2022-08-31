---@class ScanSettings TODO: Its own File
ScanSettings = {}

function ScanSettings.setGet(name, value, defaultOption)
    if value ~= nil then
        settings.set(name, value);
        return value;
    end
    value = settings.get(name);
    settings.save();
    return value or defaultOption;
end

return ScanSettings
