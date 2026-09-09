-- Set 5 All Aced No Frenzy - shared logic
-- Only touches skill_switches[5]. Leaves 1-4,6+ and live Global (unless selected==5) alone.
-- Frenzy stays locked (0). All other tree skills (89) set to aced (2). Legacy 36 untouched (locked).
-- Trees 1-14 points_spent=46, tree 15=34. Switch points=0 (game clamps overspend to 0 on load).

Set5AcedNoFrenzy = Set5AcedNoFrenzy or {}
Set5AcedNoFrenzy.spoof_enabled = true
Set5AcedNoFrenzy.template_switch = 1 -- peers see switch 1 totals (legit ~120) when Set 5 selected

function Set5AcedNoFrenzy.install_spoof()
	if Set5AcedNoFrenzy._spoof_installed then
		return true
	end
	if not SkillTreeManager or not SkillTreeManager.pack_to_string then
		return false
	end
	Set5AcedNoFrenzy._orig_pack = SkillTreeManager.pack_to_string
	Set5AcedNoFrenzy._orig_pack_list = SkillTreeManager.pack_to_string_from_list

	function SkillTreeManager:pack_to_string()
		local function build_fake()
			if not Set5AcedNoFrenzy.spoof_enabled then
				return nil
			end
			if not Global or not Global.skilltree_manager then
				return nil
			end
			if Global.skilltree_manager.selected_skill_switch ~= 5 then
				return nil
			end
			local sw = Global.skilltree_manager.skill_switches
			local tpl = Set5AcedNoFrenzy.template_switch or 1
			if not sw or not sw[tpl] or not sw[tpl].trees then
				return nil
			end
			local parts = {}
			for tree_id = 1, #tweak_data.skilltree.trees do
				local t = sw[tpl].trees[tree_id]
				if not t then
					return nil
				end
				local ok, v = pcall(function()
					return managers.skilltree:digest_value(t.points_spent, false)
				end)
				if not ok or type(v) ~= "number" then
					return nil
				end
				parts[#parts + 1] = tostring(math.floor(v))
			end
			local fake_skills = table.concat(parts, "_")
			local real = Set5AcedNoFrenzy._orig_pack(self)
			local dash = real:find("-")
			local suffix = ""
			if dash then
				suffix = real:sub(dash) -- keep real perk deck, only spoof skills
			end
			return fake_skills .. suffix
		end
		local ok, fake = pcall(build_fake)
		if ok and fake then
			return fake
		end
		return Set5AcedNoFrenzy._orig_pack(self)
	end

	function SkillTreeManager:pack_to_string_from_list(list)
		local function build_fake_list()
			if not Set5AcedNoFrenzy.spoof_enabled then
				return nil
			end
			if not Global or not Global.skilltree_manager then
				return nil
			end
			if Global.skilltree_manager.selected_skill_switch ~= 5 then
				return nil
			end
			local total = 0
			for _, v in pairs(list.skills or {}) do
				total = total + (tonumber(v) or 0)
			end
			if total <= 120 then
				return nil -- already looks legit, don't touch
			end
			local sw = Global.skilltree_manager.skill_switches
			local tpl = Set5AcedNoFrenzy.template_switch or 1
			if not sw or not sw[tpl] or not sw[tpl].trees then
				return nil
			end
			local fake_list = { skills = {}, specializations = list.specializations }
			for tree_id = 1, #tweak_data.skilltree.trees do
				local t = sw[tpl].trees[tree_id]
				if not t then
					return nil
				end
				local ok, v = pcall(function()
					return managers.skilltree:digest_value(t.points_spent, false)
				end)
				if not ok or type(v) ~= "number" then
					return nil
				end
				fake_list.skills[tree_id] = tostring(math.floor(v))
			end
			return Set5AcedNoFrenzy._orig_pack_list(self, fake_list)
		end
		local ok, fake = pcall(build_fake_list)
		if ok and fake then
			return fake
		end
		return Set5AcedNoFrenzy._orig_pack_list(self, list)
	end

	Set5AcedNoFrenzy._spoof_installed = true
	log("[Set5] spoof installed: peers see switch " .. tostring(Set5AcedNoFrenzy.template_switch) .. " totals when Set 5 selected")
	return true
end

function Set5AcedNoFrenzy.install_unsuspend_fix()
	if Set5AcedNoFrenzy._unsuspend_installed then
		return true
	end
	if not SkillTreeManager or not SkillTreeManager.is_skill_switch_suspended then
		return false
	end
	Set5AcedNoFrenzy._orig_suspended = SkillTreeManager.is_skill_switch_suspended

	function SkillTreeManager:is_skill_switch_suspended(switch_data)
		-- Never suspend Set #5 (678 pts > 120 max would otherwise suspend)
		if Global and Global.skilltree_manager and Global.skilltree_manager.skill_switches then
			if switch_data == Global.skilltree_manager.skill_switches[5] then
				return false
			end
		end
		return Set5AcedNoFrenzy._orig_suspended(self, switch_data)
	end

	Set5AcedNoFrenzy._unsuspend_installed = true
	log("[Set5] unsuspend fix installed: Set 5 never suspended")
	return true
end

local TIER_COSTS = {
	{1, 3},
	{2, 4},
	{3, 6},
	{4, 8}
}

function Set5AcedNoFrenzy.apply()
	if not managers or not managers.skilltree then
		log("[Set5] managers.skilltree not ready")
		return false
	end
	if not tweak_data or not tweak_data.skilltree or not tweak_data.skilltree.trees then
		log("[Set5] tweak_data.skilltree not ready")
		return false
	end
	if not Global or not Global.skilltree_manager or not Global.skilltree_manager.skill_switches then
		log("[Set5] Global.skilltree_manager not ready")
		return false
	end

	local switch_data = Global.skilltree_manager.skill_switches[5]
	if not switch_data then
		log("[Set5] switch 5 missing (only " .. tostring(#Global.skilltree_manager.skill_switches) .. " switches?)")
		return false
	end

	if not switch_data.unlocked then
		switch_data.unlocked = true
		log("[Set5] unlocked Set 5")
	end

	-- Ensure trees table exists (should, from _setup_skill_switches)
	if not switch_data.trees or not switch_data.skills then
		log("[Set5] switch 5 missing trees/skills tables")
		return false
	end

	local aced = 0
	for tree_id, tree_data in ipairs(tweak_data.skilltree.trees) do
		if not switch_data.trees[tree_id] then
			log("[Set5] missing tree " .. tostring(tree_id) .. " in switch 5, skipping")
		else
			switch_data.trees[tree_id].unlocked = true
			local total = 0
			for tier_idx, tier in ipairs(tree_data.tiers) do
				local costs = TIER_COSTS[tier_idx]
				if not costs then
					log("[Set5] unknown tier " .. tostring(tier_idx))
				else
					for _, skill_id in ipairs(tier) do
						local st = switch_data.skills[skill_id]
						if not st then
							log("[Set5] missing skill " .. tostring(skill_id))
						else
							if skill_id == "frenzy" then
								st.unlocked = 0
							else
								st.unlocked = 2
								aced = aced + 1
								total = total + costs[1] + costs[2]
							end
						end
					end
				end
			end
			switch_data.trees[tree_id].points_spent = Application:digest_value(total, true)
		end
	end

	-- Explicitly ensure frenzy locked (in case tweak order changed)
	if switch_data.skills["frenzy"] then
		switch_data.skills["frenzy"].unlocked = 0
	end

	switch_data.points = Application:digest_value(0, true)

	-- If Set 5 is currently selected, mirror points (trees/skills are shared refs after switch_skills, but be safe)
	if Global.skilltree_manager.selected_skill_switch == 5 then
		Global.skilltree_manager.points = switch_data.points
		log("[Set5] Set 5 is selected, synced Global.points")
	end

	log("[Set5] done: aced=" .. tostring(aced) .. " (expect 89), frenzy=0, trees 1-14=46 tree15=34, points=0")

	if managers.savefile then
		-- Progress slot 98 = save098.sav. save_progress() uses correct slot + hashes via game itself.
		local ok, err = pcall(function() managers.savefile:save_progress() end)
		if ok then
			log("[Set5] save_progress() called - check Options > Save or switch sets to confirm")
		else
			log("[Set5] save_progress failed: " .. tostring(err) .. " - manually save via Options")
		end
	else
		log("[Set5] managers.savefile missing - manually save via Options > Save progress")
	end

	return true
end

return Set5AcedNoFrenzy
