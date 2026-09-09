-- Keybind: Give All Weapon Mods x999. Run in Main Menu.
if not WeaponsGiveAll then
  dofile(ModPath .. "weapons_logic.lua")
end

local ok, err = WeaponsGiveAll.give()
if ok then
  log("[WeaponsGiveAll] keybind applied OK - check Blackmarket, then restart game to save.")
else
  log("[WeaponsGiveAll] keybind FAILED: " .. tostring(err) .. " - try in Main Menu after profile loaded.")
end
