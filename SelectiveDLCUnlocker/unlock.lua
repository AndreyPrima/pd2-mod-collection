if WinSteamDLCManager then
    local old_steam_check = old_steam_check or WinSteamDLCManager._check_dlc_data
    function WinSteamDLCManager:_check_dlc_data(dlc_data)
        return SelectiveDlcUnlocker ~= nil and SelectiveDlcUnlocker:unlock_dlc(dlc_data) or old_steam_check(self, dlc_data)
    end
end
 
if WinEpicDLCManager then
    local old_epic_check = old_epic_check or WinEpicDLCManager._check_dlc_data
    function WinEpicDLCManager:_check_dlc_data(dlc_data)
        return SelectiveDlcUnlocker ~= nil and SelectiveDlcUnlocker:unlock_dlc(dlc_data) or old_epic_check(self, dlc_data)
    end
end

if WINDLCManager then
    local old_win_check = old_win_check or WINDLCManager._check_dlc_data
    function WINDLCManager:_check_dlc_data(dlc_data)
        return SelectiveDlcUnlocker ~= nil and SelectiveDlcUnlocker:unlock_dlc(dlc_data) or old_win_check(self, dlc_data)
    end
end