local AMMO_MULT = 5

local ZERO_PICKUP_MIN_RATIO = 0.02
local ZERO_PICKUP_MAX_RATIO = 0.04

Hooks:PostHook(WeaponTweakData, "init", "AmmoX5_WeaponTweak_Init", function(self)
    local edited = 0
    local zero_fixed = 0

    for weapon_id, w in pairs(self) do
        if type(w) == "table" and type(w.AMMO_MAX) == "number" then
            local old_max = w.AMMO_MAX

            -- x5 total ammo
            w.AMMO_MAX = math.floor(old_max * AMMO_MULT + 0.5)

            -- Diesel v3 game data uses AMMO_PICKUP exclusively. Read the legacy
            -- lowercase key if some mod created one, but always write back
            -- uppercase: a lowercase write would be a dead key the game never
            -- reads, silently dropping the x5 pickup.
            local pickup = w.AMMO_PICKUP
            if type(pickup) ~= "table" and type(w.ammo_pickup) == "table" then
                pickup = w.ammo_pickup
            end
            local pickup_key = "AMMO_PICKUP"

            if type(pickup) ~= "table" then
                pickup = {0, 0}
            end

            local p1 = tonumber(pickup[1]) or 0
            local p2 = tonumber(pickup[2]) or 0

            -- If pickup is 0-0 -> enable it (otherwise x5 won't change anything)
            if p1 <= 0 and p2 <= 0 then
                p1 = old_max * ZERO_PICKUP_MIN_RATIO
                p2 = old_max * ZERO_PICKUP_MAX_RATIO
                zero_fixed = zero_fixed + 1
            end

            -- x5 ammo pickup for all weapons
            pickup[1] = p1 * AMMO_MULT
            pickup[2] = p2 * AMMO_MULT
            w[pickup_key] = pickup

            edited = edited + 1
        end
    end

    log(string.format("[AmmoX5] x%d AMMO_MAX + x%d pickup applied to %d weapons. Enabled pickup for %d zero-pickup weapons.",
        AMMO_MULT, AMMO_MULT, edited, zero_fixed))
end)