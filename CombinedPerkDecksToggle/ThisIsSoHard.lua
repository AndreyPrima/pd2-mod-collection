-- ======================================================================
-- CONFIGURATION
-- true = ENABLED (bonuses apply)
-- false = DISABLED (bonuses ignored)
-- ======================================================================
CombinedPerkDecksToggle = CombinedPerkDecksToggle or {}

local deck_config = {
    ["menu_st_spec_1"]  = false, -- Crew Chief
    ["menu_st_spec_2"]  = true, -- Muscle
    ["menu_st_spec_3"]  = false, -- Armorer
    ["menu_st_spec_4"]  = false, -- Rogue
    ["menu_st_spec_5"]  = false, -- Crook
    ["menu_st_spec_6"]  = true, -- Hitman
    ["menu_st_spec_7"]  = false, -- Burglar
    ["menu_st_spec_8"]  = true, -- Infiltrator
    ["menu_st_spec_9"]  = false, -- Sociopath
    ["menu_st_spec_10"] = true, -- Gambler
    ["menu_st_spec_11"] = true, -- Grinder
    ["menu_st_spec_12"] = false, -- Yakuza
    ["menu_st_spec_13"] = false, -- Ex-President
    ["menu_st_spec_14"] = true, -- Maniac
    ["menu_st_spec_15"] = false, -- Anarchist
    ["menu_st_spec_16"] = false, -- Biker
    ["menu_st_spec_17"] = false, -- Kingpin
    ["menu_st_spec_18"] = false, -- Sicario
    ["menu_st_spec_19"] = false, -- Stoic
    ["menu_st_spec_20"] = false, -- Tag Team
    ["menu_st_spec_21"] = false, -- Hacker
    ["menu_st_spec_22"] = false, -- Leech
    ["menu_st_spec_23"] = false, -- Copycat
}
-- ======================================================================
-- FIX 3: explicit blacklist of real penalties instead of string.find("loss"/"penalty").
-- Verified against payday2-lua-latest (BuildID 25104217, skilltreetweakdata.lua,
-- upgradestweakdata.lua, playermanager.lua, playerdamage.lua):
-- - player_health_decrease_1 (Anarchist c3, value 0.5: max HP x0.5) is the ONLY
--   flat stat cut among the decks. The old filter MISSED it (no loss/penalty words).
-- - player_passive_armor_movement_penalty_multiplier (shared deck4, value 0.75:
--   armor movespeed penalty -25%) is a BONUS. The old filter DROPPED it. Leave it alone.
-- - player_perk_armor_loss_multiplier_1..4 do NOT exist in decks 1-23 (rg: 0 hits);
--   Crook in latest only grants player_perk_armor_regen_timer_multiplier_1..5 (bonus).
-- Known tradeoffs we do NOT exclude (deck mechanics; these decks ship disabled):
-- Stoic player_armor_to_health_conversion (armor -> 0),
-- Leech player_copr_out_of_health_move_slow_1 (slow x0.2 under the ability),
-- Muscle player_uncover_multiplier (+15% detection).
-- Copycat: picks live in card.multi_choice[] — the loop only takes base card
-- upgrades on purpose (taking all mutually exclusive picks would stack them).
-- ======================================================================
local excluded_upgrades = {
    ["player_health_decrease_1"] = true, -- Anarchist: max-health cut traded for armor
}

local function should_acquire(upgrade_id)
    return not excluded_upgrades[upgrade_id]
end

local function apply_combined_decks()
    if not tweak_data or not tweak_data.skilltree or not tweak_data.skilltree.specializations then
        return
    end
    if not managers or not managers.upgrades or not managers.upgrades.aquire then
        return
    end

    for _, specialization in ipairs(tweak_data.skilltree.specializations) do
        if specialization.name_id and deck_config[specialization.name_id] == true then
            for _, tree in ipairs(specialization) do
                if type(tree) == "table" and tree.upgrades then
                    for _, upgrade in ipairs(tree.upgrades) do
                        if should_acquire(upgrade) then
                            pcall(function()
                                -- Guard against re-acquire (latest: a duplicate
                                -- drops into debug_pause inside aquire).
                                local already = false
                                if managers.upgrades.aquired then
                                    already = managers.upgrades:aquired(upgrade)
                                end
                                if not already then
                                    managers.upgrades:aquire(upgrade, false)
                                end
                            end)
                        end
                    end
                end
            end
        end
    end
end

-- FIX 1: Hooks:PostHook instead of overwriting MenuTitlescreenState:at_enter
-- (the old global-_atEnter override broke other menu mods).
-- FIX 2: apply not only on the titlescreen but also after profile load
-- (UpgradesManager:load is the reset point) and init (_setup).
-- Latest has NO UpgradesManager:setup method (only init/_setup/load),
-- so a hook on "setup" would never fire — hook the real methods.
-- The immediate call covers late script loads.
if Hooks then
    if MenuTitlescreenState then
        Hooks:PostHook(MenuTitlescreenState, "at_enter", "cpdt_apply_on_title", function(self)
            apply_combined_decks()
        end)
    end
    if UpgradesManager then
        Hooks:PostHook(UpgradesManager, "init", "cpdt_apply_on_init", function(self)
            apply_combined_decks()
        end)
        Hooks:PostHook(UpgradesManager, "_setup", "cpdt_apply_on_setup", function(self)
            apply_combined_decks()
        end)
        Hooks:PostHook(UpgradesManager, "load", "cpdt_apply_on_load", function(self)
            apply_combined_decks()
        end)
    end
end

apply_combined_decks()
