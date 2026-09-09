-- Selective Mods Hider: network filter.
-- Intercepts MenuCallbackHandler:build_mods_list (still present and unchanged
-- in Diesel v3 / Update 247.x) and only returns mods the user toggled ON.
-- The lobby "Installed Mods" list on other clients is built from
-- NetworkPeer:synced_mods(), which is fed by this function.

if SelectiveModsHider._hooked then
	return
end

local Orig_MenuCallbackHandler_BuildModsList = MenuCallbackHandler and MenuCallbackHandler.build_mods_list
if type(Orig_MenuCallbackHandler_BuildModsList) ~= "function" then
	log("[SelectiveModsHider] MenuCallbackHandler.build_mods_list not found, filter not installed.")
	return
end

-- Stash for main.lua's startup sync (avoids double-capture).
SelectiveModsHider._orig_build_mods_list = SelectiveModsHider._orig_build_mods_list or Orig_MenuCallbackHandler_BuildModsList

function MenuCallbackHandler:build_mods_list(...)
	local settings = _G.SelectiveModsHider and _G.SelectiveModsHider.settings or {}
	local ok, mods = pcall(Orig_MenuCallbackHandler_BuildModsList, self, ...)
	if not ok or type(mods) ~= "table" then
		return {}
	end

	local return_mods = {}
	for _, mod_data in ipairs(mods) do
		if type(mod_data) == "table" and settings[mod_data[1]] == true then
			table.insert(return_mods, mod_data)
		end
	end

	return return_mods
end

SelectiveModsHider._hooked = true
