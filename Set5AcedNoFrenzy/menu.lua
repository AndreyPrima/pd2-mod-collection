-- Menu: Options > Mod Options > Set 5 + Weapons - buttons (no keybind needed)
local _modpath = ModPath

local STRINGS = {
  ["set5weap_menu_title"] = "Set 5 + Weapon Mods",
  ["set5weap_menu_desc"] = "Ace Set 5 without Frenzy, and give all weapon mods x999.",
  ["set5weap_btn_ace"] = "Ace Set 5 (no Frenzy)",
  ["set5weap_btn_ace_desc"] = "Apply all-aced except Frenzy to Skill Set 5. Run in Main Menu.",
  ["set5weap_btn_weapons"] = "Give All Weapon Mods x999",
  ["set5weap_btn_weapons_desc"] = "Give 999 of every weapon attachment, remove duplicates. Run in Main Menu.",
}

local function add_loc(loc_mgr)
  if loc_mgr and loc_mgr.add_localized_strings then
    loc_mgr:add_localized_strings(STRINGS)
  end
end

if managers and managers.localization then
  add_loc(managers.localization)
end
Hooks:Add("LocalizationManagerPostInit", "Set5Weapons_Loc", function(loc)
  add_loc(loc)
end)

local function show_msg(title, msg)
  local ok = false
  if managers and managers.menu then
    -- vanilla dialog (most reliable in menu)
    if managers.menu.show_ok_message then
      local p_ok = pcall(function()
        managers.menu:show_ok_message(title, msg)
      end)
      ok = p_ok
    end
  end
  if not ok and QuickMenu then
    pcall(function()
      QuickMenu:new(title, msg, {{ text = "OK", is_cancel_button = true }}):show()
    end)
  end
  log("[" .. tostring(title) .. "] " .. tostring(msg))
end

local function ensure_set5()
  if not Set5AcedNoFrenzy then
    dofile(_modpath .. "set5_logic.lua")
  end
  return Set5AcedNoFrenzy
end

local function ensure_weapons()
  if not WeaponsGiveAll then
    dofile(_modpath .. "weapons_logic.lua")
  end
  return WeaponsGiveAll
end

MenuCallbackHandler.Set5Weapons_ace_btn = function(self, item)
  local mod = ensure_set5()
  if not mod or not mod.apply then
    show_msg("Set 5", "Logic not loaded. Check BLT log.")
    return
  end
  local ok = mod.apply()
  if ok then
    show_msg("Set 5", "Set 5 aced (89 skills, Frenzy locked). Open Skills > Set 5 to verify, then save.")
  else
    show_msg("Set 5", "FAILED - run in Main Menu after profile loaded. See BLT log.")
  end
end

MenuCallbackHandler.Set5Weapons_weapons_btn = function(self, item)
  local mod = ensure_weapons()
  if not mod or not mod.give then
    show_msg("Weapon Mods", "Logic not loaded. Check BLT log.")
    return
  end
  local ok, err = mod.give()
  if ok then
    show_msg("Weapon Mods", "Done: all attachments set to 999, duplicates removed. Check Blackmarket, then restart game to save.")
  else
    show_msg("Weapon Mods", "FAILED: " .. tostring(err) .. " - run in Main Menu after profile loaded.")
  end
end

local MENU_ID = "set5weapons_options"

Hooks:Add("MenuManagerSetupCustomMenus", "Set5Weapons_Setup", function(menu_manager, nodes)
  MenuHelper:NewMenu(MENU_ID)
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "Set5Weapons_Populate", function(menu_manager, nodes)
  MenuHelper:AddButton({
    id = "set5weapons_ace",
    title = "set5weap_btn_ace",
    desc = "set5weap_btn_ace_desc",
    callback = "Set5Weapons_ace_btn",
    menu_id = MENU_ID,
    localized = true,
    priority = 10,
  })
  MenuHelper:AddButton({
    id = "set5weapons_give",
    title = "set5weap_btn_weapons",
    desc = "set5weap_btn_weapons_desc",
    callback = "Set5Weapons_weapons_btn",
    menu_id = MENU_ID,
    localized = true,
    priority = 9,
  })
end)

Hooks:Add("MenuManagerBuildCustomMenus", "Set5Weapons_Build", function(menu_manager, nodes)
  nodes[MENU_ID] = MenuHelper:BuildMenu(MENU_ID)
  local parent = nodes.lua_mod_options_menu or nodes.blt_options or nodes.options
  MenuHelper:AddMenuItem(parent, MENU_ID, "set5weap_menu_title", "set5weap_menu_desc")
end)

log("[Set5Weapons] menu loaded - Options > Mod Options > Set 5 + Weapon Mods")
