Hooks:PostHook(WeaponFactoryTweakData, "init", "NoNegativeStats_Init", function(self)
    local modified_count = 0
    local parts = self and self.parts

    if type(parts) ~= "table" then
        log("[NoNegativeStats] ERROR: self.parts not found or not a table.")
        return
    end

    -- Keys that look numeric/negative but are NOT bonuses: flipping them
    -- corrupts behavior (e.g. ammo_offset selects the ammo type index,
    -- sort_number controls menu ordering, both live outside the stat model).
    -- Diesel v3 data contains a live case: custom_stats.ammo_offset = -1.
    local never_flip = {
        ammo_offset = true,
        sort_number = true
    }

    -- For multipliers: reflect around 1.0 (0.9 -> 1.1, 0.5 -> 1.5)
    local function flip_multiplier(v)
        return 2 - v
    end

    -- Some multipliers are "bad when > 1" (e.g. recoil_multiplier > 1 increases recoil).
    local high_is_bad = {
        recoil_multiplier = true,
        spread_multiplier = true
    }

    for part_id, part in pairs(parts) do
        if type(part) == "table" then
            local modified = false

            -- Flip any negative flat stats: -X -> +X
            if type(part.stats) == "table" then
                for key, v in pairs(part.stats) do
                    if not never_flip[key] and type(v) == "number" and v < 0 then
                        part.stats[key] = -v
                        modified = true
                    end
                end
            end

            -- Flip custom_stats penalties into bonuses
            if type(part.custom_stats) == "table" then
                local cs = part.custom_stats

                for key, v in pairs(cs) do
                    if not never_flip[key] and type(v) == "number" then
                        -- If it's a multiplier-like value and below 1 => penalty => make it above 1
                        if (string.match(key, "multiplier$") or string.match(key, "_mul$")) and v < 1 then
                            cs[key] = flip_multiplier(v)
                            modified = true

                        -- If it's a known "high is bad" multiplier and above 1 => penalty => make it below 1
                        elseif high_is_bad[key] and v > 1 then
                            cs[key] = math.max(0.05, flip_multiplier(v)) -- clamp to avoid <= 0
                            modified = true

                        -- If it's a plain negative number in custom_stats: -X -> +X
                        elseif v < 0 then
                            cs[key] = -v
                            modified = true
                        end
                    end
                end
            end

            if modified then
                modified_count = modified_count + 1
            end
        end
    end

    log("[NoNegativeStats] Flipped negatives to positives on " .. tostring(modified_count) .. " attachments.")
end)