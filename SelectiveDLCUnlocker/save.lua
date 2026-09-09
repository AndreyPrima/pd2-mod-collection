_G.SelectiveDlcUnlocker = {}
SelectiveDlcUnlocker.path = ModPath
SelectiveDlcUnlocker.settings_path = SavePath .. "SelectiveDlcUnlocker.json"
SelectiveDlcUnlocker.settings = {}
SelectiveDlcUnlocker.all_dlc_data = {}
 
function SelectiveDlcUnlocker:get_settings_key(dlc_name)
	return "unlock_" .. tostring(dlc_name)
end
 
function SelectiveDlcUnlocker:get_loc_key(dlc_name)
	return "selective_dlc_unlocker_" .. tostring(dlc_name)
end
 
function SelectiveDlcUnlocker:get_dlc_name_by_data(check_data)
	for dlc_name, dlc_data in pairs(self.all_dlc_data) do
		if dlc_data == check_data then
			return dlc_name
		end
	end
	
	return ""
end
 
function SelectiveDlcUnlocker:unlock_dlc(dlc_data)
	return self.settings[self:get_settings_key(self:get_dlc_name_by_data(dlc_data))] or false
end
 
function SelectiveDlcUnlocker:Save()
	local file = io.open(self.settings_path, "w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end
 
function SelectiveDlcUnlocker:Load()
	local file = io.open(self.settings_path, "r")
	if file then
		self.settings = json.decode(file:read("*all"))
		file:close()
	end
end
 
function SelectiveDlcUnlocker:AddAllDlcs()
	for name, data in pairs(self.all_dlc_data) do
		local key = self:get_settings_key(name)
		self.settings[key] = self.settings[key] or data.verified or false
	end
end
 
SelectiveDlcUnlocker.all_dlc_data = Global.dlc_manager.all_dlc_data
SelectiveDlcUnlocker:Load()
SelectiveDlcUnlocker:AddAllDlcs()
SelectiveDlcUnlocker:Save()