-- Selective Mods Hider v1.1
-- Targets PAYDAY 2 Diesel v3 (Update 247.x, 64-bit) + SuperBLT 64-bit beta.
-- Bootstrap: settings handling + ordered loading of hook.lua / menu.lua.
-- Only main.lua is hooked (lib/managers/menumanager); the other files are
-- loaded from here via dofile so execution order is deterministic.

_G.SelectiveModsHider = _G.SelectiveModsHider or {}
SelectiveModsHider.path = ModPath
SelectiveModsHider.settings = SelectiveModsHider.settings or {}
SelectiveModsHider.settings_file_path = SavePath .. "SelectiveModsHider.json"
-- Maps sanitized MenuHelper toggle ids -> real mod display names (see menu.lua).
SelectiveModsHider._toggle_id_to_mod = SelectiveModsHider._toggle_id_to_mod or {}

function SelectiveModsHider:get_original_formated_mods_list()
	local formated_mods_list = {}
	local orig = self._orig_build_mods_list or (MenuCallbackHandler and MenuCallbackHandler.build_mods_list)
	if type(orig) ~= "function" then
		return formated_mods_list
	end
	local ok, mods_list = pcall(orig, MenuCallbackHandler)
	if not ok or type(mods_list) ~= "table" then
		return formated_mods_list
	end

	for _, mod_data in ipairs(mods_list) do
		if type(mod_data) == "table" and type(mod_data[1]) == "string" then
			formated_mods_list[mod_data[1]] = false
		end
	end

	return formated_mods_list
end

function SelectiveModsHider:sync_mods()
	local original_mods_list = self:get_original_formated_mods_list()

	-- Preserve user choices for mods that still exist; new mods default to
	-- hidden (false). Removed mods are pruned.
	for mod, _ in pairs(self.settings) do
		if original_mods_list[mod] ~= nil then
			original_mods_list[mod] = (self.settings[mod] == true)
		end
	end

	self.settings = original_mods_list
end

function SelectiveModsHider:load()
	self.settings = {}
	local file = io.open(self.settings_file_path, "r")
	if file then
		local content = file:read("*all")
		file:close()
		if content and content ~= "" then
			local ok, data = pcall(json.decode, content)
			if ok and type(data) == "table" then
				-- Only keep sane string -> boolean entries.
				local clean = {}
				for k, v in pairs(data) do
					if type(k) == "string" then
						clean[k] = (v == true)
					end
				end
				self.settings = clean
			else
				log("[SelectiveModsHider] Settings file corrupt, starting fresh.")
			end
		end
	end
end

function SelectiveModsHider:save()
	local file = io.open(self.settings_file_path, "w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

SelectiveModsHider:load()
SelectiveModsHider:sync_mods()
SelectiveModsHider:save()

-- Load order matters: hook first (installs the filter), then menu.
dofile(SelectiveModsHider.path .. "hook.lua")
dofile(SelectiveModsHider.path .. "menu.lua")
