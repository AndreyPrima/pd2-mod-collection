-- Weapons Give All x999 - shared logic (no duplicates)
-- Single correct global_value per mod, removes other gv copies.

WeaponsGiveAll = WeaponsGiveAll or {}
WeaponsGiveAll.AMOUNT = 999

function WeaponsGiveAll.get_true_gv(data)
  if type(data.global_value) == "string" then
    return data.global_value
  end
  if type(data.dlc) == "string" then
    return data.dlc
  end
  if data.dlcs and #data.dlcs > 0 then
    return data.dlcs[1]
  end
  if data.infamous then
    return "infamous"
  end
  return "normal"
end

function WeaponsGiveAll.give()
  if not managers or not managers.blackmarket then
    log("[WeaponsGiveAll] managers.blackmarket not ready (run in Main Menu)")
    return false, "blackmarket not ready"
  end
  if not tweak_data or not tweak_data.blackmarket or not tweak_data.blackmarket.weapon_mods then
    log("[WeaponsGiveAll] tweak_data.blackmarket.weapon_mods not ready")
    return false, "tweak_data not ready"
  end

  local AMOUNT = WeaponsGiveAll.AMOUNT

  -- 1. Unlock + ensure correct gv exists
  local count = 0
  for id, data in pairs(tweak_data.blackmarket.weapon_mods) do
    data.unlocked = true
    data.is_a_unlockable = nil
    local true_gv = WeaponsGiveAll.get_true_gv(data)
    local ok, err = pcall(function()
      managers.blackmarket:add_to_inventory(true_gv, "weapon_mods", id, false)
    end)
    if ok then
      count = count + 1
    else
      log("[WeaponsGiveAll] add failed " .. tostring(id) .. ": " .. tostring(err))
    end
  end

  -- 2. Cleanup duplicates + force AMOUNT
  local inv = managers.blackmarket._global and managers.blackmarket._global.inventory
  if inv then
    for gv, cats in pairs(inv) do
      if cats["weapon_mods"] then
        for id, _ in pairs(cats["weapon_mods"]) do
          local data = tweak_data.blackmarket.weapon_mods[id]
          if data then
            local true_gv = WeaponsGiveAll.get_true_gv(data)
            if gv ~= true_gv then
              cats["weapon_mods"][id] = nil
            else
              cats["weapon_mods"][id] = AMOUNT
            end
          end
        end
      end
    end
  end

  -- 3. Clear "new item" marks
  local drops = managers.blackmarket._global and managers.blackmarket._global.new_drops
  if drops then
    for _, cats in pairs(drops) do
      if cats["weapon_mods"] then
        for id, _ in pairs(cats["weapon_mods"]) do
          cats["weapon_mods"][id] = nil
        end
      end
    end
  end

  log("[WeaponsGiveAll] done: " .. tostring(count) .. " mods set to " .. tostring(AMOUNT) .. ", duplicates removed")
  return true
end

return WeaponsGiveAll
