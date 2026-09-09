-- Hook: lib/managers/skilltreemanager
-- Loads shared logic, installs spoof (peers see switch 1 totals when Set 5 selected).
-- Does NOT auto-apply skills (to avoid overwriting your future Set 5 edits).
-- Use Options > Mod Keybinds > "Ace Set 5 (no Frenzy)" in Main Menu.
if not Set5AcedNoFrenzy then
	local f = ModPath .. "set5_logic.lua"
	if io and io.file_is_readable and io.file_is_readable(f) then
		dofile(f)
	else
		-- BLT always has ModPath; fallback direct
		dofile(ModPath .. "set5_logic.lua")
	end
end

if Set5AcedNoFrenzy and Set5AcedNoFrenzy.install_spoof then
	Set5AcedNoFrenzy.install_spoof()
end

if Set5AcedNoFrenzy and Set5AcedNoFrenzy.install_unsuspend_fix then
	Set5AcedNoFrenzy.install_unsuspend_fix()
end

log("[Set5] loaded - only touches Skill Set 5. Press keybind in Main Menu to apply (89 aced, Frenzy locked). Spoof on: peers see switch 1. Unsuspend fix on.")
