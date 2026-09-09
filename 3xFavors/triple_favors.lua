-- 3x Favors Pre-Planning v1.0 -- Diesel 3.0 / 64-bit
-- Triples the favor pool for Pre-Planning. Money costs unchanged.
--
-- How it works:
--  PrePlanningManager:get_current_budget() returns (spent, total) where
--  total = tweak_data.preplanning.locations[level_id].total_budget.
--  All gates read it: can_reserve_mission_element, can_vote_on_plan,
--  execute_reserved_mission_elements, get_current_preplan, and the UI.
--  Multiplying only the second return value by 3 therefore covers
--  reserve + vote + execute + UI in one place, for every heist
--  (including DLC/custom) without enumerating tweak_data.
--
-- Client / host:
--  The host is authoritative (_server_reserve_*, execute_* run on server).
--  So the HOST must have this mod for extra favors to actually spawn.
--  Clients should also have it, otherwise their own can_reserve check
--  blocks them from requesting over vanilla budget even if host allows.
--  With the mod on both sides it works as host and as client.
--
-- Hook via mod.txt:
--  { "hook_id" : "lib/managers/preplanningmanager", "script_path" : "triple_favors.lua" }

if RequiredScript ~= "lib/managers/preplanningmanager" then
	return
end

if not PrePlanningManager then
	return
end

ThreeXFavors = ThreeXFavors or {}
ThreeXFavors.MULT = 3

-- Guard against double-hooking on script reload (SuperBLT can reload lua).
if ThreeXFavors._hooked then
	return
end
ThreeXFavors._hooked = true

local MULT = ThreeXFavors.MULT

-- 1) Core: 3x total budget. Single choke point.
local _orig_get_current_budget = PrePlanningManager.get_current_budget
if not _orig_get_current_budget then
	return
end
function PrePlanningManager:get_current_budget(...)
	local spent, total = _orig_get_current_budget(self, ...)
	if total then
		return spent, total * MULT
	end
	return spent, total
end

-- 2) Preserve Big Bank achievement "bigbank_8" ("spend all favors").
-- Vanilla logic awards only when spent == total. With 3x that would
-- require 30/30 instead of 10/30. Keep vanilla behavior: award if
-- spent >= vanilla total, in addition to the game's own 30/30 check.
-- Award() is idempotent, so double-award is harmless.
local _orig_on_execute = PrePlanningManager.on_execute_preplanning
if not _orig_on_execute then
	log("[3xFavors] loaded, favor pool x" .. tostring(MULT) .. " (no achievement guard: on_execute missing)")
	return
end
function PrePlanningManager:on_execute_preplanning(...)
	local spent, total = nil, nil
	if self.has_current_level_preplanning and self:has_current_level_preplanning() then
		-- pcall: get_current_budget asserts if location data missing.
		local ok, s, t = pcall(function() return self:get_current_budget() end)
		if ok then
			spent, total = s, t
		end
	end

	_orig_on_execute(self, ...)

	if spent and total and managers.job and managers.achievment then
		local ok_level, level_id = pcall(function() return managers.job:current_level_id() end)
		if ok_level and level_id == "big" then
			local vanilla_total = total / MULT
			if spent >= vanilla_total then
				pcall(function() managers.achievment:award("bigbank_8") end)
			end
		end
	end
end

log("[3xFavors] loaded, favor pool x" .. tostring(MULT))
