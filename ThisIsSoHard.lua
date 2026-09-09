-- ======================================================================
-- НАСТРОЙКИ / CONFIGURATION
-- true = ВКЛЮЧЕНО (бонусы работают)
-- false = ВЫКЛЮЧЕНО (бонусы игнорируются)
-- ======================================================================
CombinedPerkDecksToggle = CombinedPerkDecksToggle or {}

local deck_config = {
    ["menu_st_spec_1"]  = false, -- Crew Chief (Лидер)
    ["menu_st_spec_2"]  = true, -- Muscle (Вышибала)
    ["menu_st_spec_3"]  = false, -- Armorer (Силовик)
    ["menu_st_spec_4"]  = false, -- Rogue (Шпион)
    ["menu_st_spec_5"]  = false, -- Crook (Мошенник)
    ["menu_st_spec_6"]  = true, -- Hitman (Киллер)
    ["menu_st_spec_7"]  = false, -- Burglar (Взломщик)
    ["menu_st_spec_8"]  = true, -- Infiltrator (Лазутчик)
    ["menu_st_spec_9"]  = false, -- Sociopath (Социопат)
    ["menu_st_spec_10"] = true, -- Gambler (Шулер)
    ["menu_st_spec_11"] = true, -- Grinder (Грайндер)
    ["menu_st_spec_12"] = false, -- Yakuza (Якудза)
    ["menu_st_spec_13"] = false, -- Ex-President (Экс-президент)
    ["menu_st_spec_14"] = true, -- Maniac (Маньяк)
    ["menu_st_spec_15"] = false, -- Anarchist (Анархист)
    ["menu_st_spec_16"] = false, -- Biker (Байкер)
    ["menu_st_spec_17"] = false, -- Kingpin (Кингпин)
    ["menu_st_spec_18"] = false, -- Sicario (Сикарио)
    ["menu_st_spec_19"] = false, -- Stoic (Стоик)
    ["menu_st_spec_20"] = false, -- Tag Team (Командная игра)
    ["menu_st_spec_21"] = false, -- Hacker (Хакер)
    ["menu_st_spec_22"] = false, -- Leech (Пиявка)
    ["menu_st_spec_23"] = false, -- Copycat (Подражатель)
}
-- ======================================================================
-- FIX 3: явный blacklist реальных штрафов вместо string.find("loss"/"penalty").
-- Сверено с payday2-lua-latest (BuildID 25104217, skilltreetweakdata.lua,
-- upgradestweakdata.lua, playermanager.lua, playerdamage.lua):
-- - player_health_decrease_1 (Anarchist c3, value 0.5: max HP x0.5) — ЕДИНСТВЕННЫЙ
--   плоский срез стата среди дек. Старый фильтр его ПРОПУСКАЛ (нет слов loss/penalty).
-- - player_passive_armor_movement_penalty_multiplier (shared deck4, value 0.75:
--   штраф скорости от брони -25%) — БОНУС. Старый фильтр его ВЫКИДЫВАЛ. Не трогать.
-- - player_perk_armor_loss_multiplier_1..4 в деках 1-23 ОТСУТСТВУЮТ (rg: 0 хитов);
--   Crook в latest даёт только player_perk_armor_regen_timer_multiplier_1..5 (бонус).
-- Известные трейдоффы, которые НЕ исключаем (часть механики дек, по умолчанию
-- эти деки выключены): Stoic player_armor_to_health_conversion (броня -> 0),
-- Leech player_copr_out_of_health_move_slow_1 (slow x0.2 под абилой),
-- Muscle player_uncover_multiplier (детект +15%).
-- Copycat: выборы лежат в card.multi_choice[] — цикл берёт только базовые
-- апгрейды карт, это осознанно (иначе стакнутся все взаимоисключающие пики).
-- ======================================================================
local excluded_upgrades = {
    ["player_health_decrease_1"] = true, -- Anarchist: срезка макс. здоровья в обмен на броню
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
                                -- Защита от повторного aquire (latest: дубликат
                                -- падает в debug_pause внутри aquire).
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

-- FIX 1: Hooks:PostHook вместо перезаписи MenuTitlescreenState:at_enter
-- (старый код с глобальным _atEnter ломал другие моды на меню).
-- FIX 2: применяем не только на титульнике, но и после загрузки профиля
-- (UpgradesManager:load — точка сброса) и инициализации (init/_setup).
-- В latest НЕТ метода UpgradesManager:setup (только init/_setup/load),
-- поэтому хук на "setup" никогда бы не сработал — хукаем реальные методы.
-- Немедленный вызов покрывает случай поздней загрузки скрипта.
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
