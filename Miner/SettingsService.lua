---@class SettingsService TODO: Its own File
SettingsService = {}

function SettingsService.setGet(name, value, defaultOption)
    if value ~= nil then
        settings.set(name, value);
        return value;
    end
    value = settings.get(name);
    settings.save();
    return value or defaultOption;
end

return SettingsService
