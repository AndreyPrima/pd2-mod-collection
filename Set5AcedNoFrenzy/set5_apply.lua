-- Keybind: Ace Set 5 (no Frenzy). Run in Main Menu (run_in_menu=true).
if not Set5AcedNoFrenzy then
	dofile(ModPath .. "set5_logic.lua")
end

local ok = Set5AcedNoFrenzy.apply()
if ok then
	if managers and managers.menu and managers.menu.show_changelog then
		-- no popup, just log + chat hint if possible
	end
	log("[Set5] keybind applied OK - open Skills > Set 5 to verify, then ensure save (switch sets or Options > Save).")
else
	log("[Set5] keybind FAILED - see log above. Try in Main Menu after profile loaded.")
end
