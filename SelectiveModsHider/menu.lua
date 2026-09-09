-- Selective Mods Hider: BLT options menu (SuperBLT / 64-bit compatible).
local menu_id = "selective_mods_hider"

MenuCallbackHandler.selective_mods_hider_toggle_callback = function(self, item)
	local toggle_id = item:name()
	local mod_name = SelectiveModsHider._toggle_id_to_mod[toggle_id] or toggle_id
	SelectiveModsHider.settings[mod_name] = (item:value() == "on")
	SelectiveModsHider:save()
end

Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_SelectiveModsHider", function(menu_manager, nodes)
	MenuHelper:NewMenu(menu_id)
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus_SelectiveModsHider", function(menu_manager, nodes)
	-- Sort for a stable menu; use sanitized toggle ids since raw mod display
	-- names can contain spaces/special characters.
	local sorted_mods = {}
	for mod, _ in pairs(SelectiveModsHider.settings) do
		table.insert(sorted_mods, mod)
	end
	table.sort(sorted_mods, function(a, b) return a:lower() < b:lower() end)

	SelectiveModsHider._toggle_id_to_mod = {}
	for index, mod in ipairs(sorted_mods) do
		local toggle_id = "smh_mod_" .. tostring(index)
		SelectiveModsHider._toggle_id_to_mod[toggle_id] = mod
		MenuHelper:AddToggle({
			id = toggle_id,
			title = mod,
			desc = "Show " .. mod,
			callback = "selective_mods_hider_toggle_callback",
			value = (SelectiveModsHider.settings[mod] == true),
			menu_id = menu_id,
			localized = false
		})
	end
end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_SelectiveModsHider", function(menu_manager, nodes)
	nodes[menu_id] = MenuHelper:BuildMenu(menu_id)
	if nodes.blt_options then
		MenuHelper:AddMenuItem(
			nodes.blt_options,
			menu_id,
			"selective_mods_hider_name",
			"selective_mods_hider_desc"
		)
	else
		log("[SelectiveModsHider] nodes.blt_options not found, menu not attached.")
	end
end)

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_SelectiveModsHider", function(loc)
	local manager = loc or LocalizationManager
	if manager and manager.load_localization_file then
		manager:load_localization_file(SelectiveModsHider.path .. "en.json")
	end
end)
