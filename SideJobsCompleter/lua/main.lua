-- Side Jobs Completer v1.2 -- Diesel 3.0 / 64-bit, pure SuperBLT
--
-- Button: Options > Mod Options > Side Jobs Completer > Complete All Side Jobs.
-- Completes + claims: generic side jobs (event_jobs pda8/pda9/cg22/pda10,
-- raid_jobs aru/jfr, future DLC via generic_side_jobs registry), tango
-- (managers.tango), legacy ChallengeManager jobs, safehouse trophies + daily.
--
-- How it works:
--  SideJobGenericDLCManager / SideJobEventManager / TangoManager all share:
--  completed_challenge(id) sets completed=true, claim_reward(id, i) grants via
--  blackmarket/custom_safehouse and sets rewarded=true. We force objectives to
--  max first so completion is deterministic and future-DLC-proof (no hardcoded
--  IDs), then call the official APIs so popups/flags/coins/inventory behave
--  like legit claims. Legacy ChallengeManager is server-validated; we set
--  validated=true around on_give_all_rewards, then restore it.
--
-- Safety: solo/offline or private lobby. BACKUP YOUR SAVE first
-- (e.g. %LOCALAPPDATA%/PAYDAY 2/saves/ or Steam userdata). Re-press is a
-- no-op (only new transitions are counted). Host is authoritative online.

SideJobsCompleter = SideJobsCompleter or {}

if not SideJobsCompleter._core_defined then
	SideJobsCompleter._core_defined = true
	SideJobsCompleter._running = false

	local TAG = "[SJC] "

	local function log_sjc(msg)
		log(TAG .. tostring(msg))
	end

	local function is_table(v)
		return type(v) == "table"
	end

	-- Mark one objective (and any nested event choice objectives) complete.
	local function finish_objective(obj)
		if not is_table(obj) then
			return
		end
		local choices = obj.challenge_choices
		if is_table(choices) then
			for idx, choice in ipairs(choices) do
				if is_table(choice) then
					if choice.max_progress then
						choice.progress = choice.max_progress
					end
					choice.completed = true
				end
			end
			local saved = obj.challenge_choices_saved_values
			if is_table(saved) then
				for idx, entry in ipairs(saved) do
					if is_table(entry) then
						local choice = choices[idx]
						if is_table(choice) and choice.max_progress then
							entry.progress = choice.max_progress
						end
						entry.completed = true
					end
				end
			end
		end
		if obj.max_progress then
			obj.progress = obj.max_progress
		end
		obj.completed = true
	end

	-- Force every objective of a challenge (or trophy) to done.
	function SideJobsCompleter:force_complete_objectives(challenge)
		if not is_table(challenge) or not is_table(challenge.objectives) then
			return
		end
		for _, obj in ipairs(challenge.objectives) do
			finish_objective(obj)
		end
	end

	-- Prefill event collective_stats so save/UI stay consistent.
	function SideJobsCompleter:prefill_event_collectives()
		local ej = managers and managers.event_jobs
		local stats = ej and ej._global and ej._global.collective_stats
		if not is_table(stats) then
			return
		end
		for _, stat in pairs(stats) do
			if is_table(stat) and is_table(stat.all) then
				if not is_table(stat.found) then
					stat.found = {}
				end
				local have = {}
				for _, id in ipairs(stat.found) do
					have[id] = true
				end
				for _, id in ipairs(stat.all) do
					if not have[id] then
						stat.found[#stat.found + 1] = id
						have[id] = true
					end
				end
			end
		end
	end

	-- Claim every reward of a challenge; counts only new transitions.
	local function claim_all_rewards(manager, challenge, stats)
		if not is_table(challenge.rewards) then
			return
		end
		for i = 1, #challenge.rewards do
			local reward = challenge.rewards[i]
			local was = is_table(reward) and reward.rewarded
			pcall(function() manager:claim_reward(challenge.id, i) end)
			if is_table(reward) and reward.rewarded and not was then
				stats.rewards_new = stats.rewards_new + 1
			end
		end
	end

	-- Complete + claim every challenge exposed by one manager object.
	-- Works for event/raid (SideJob*Manager) and tango (same method names).
	function SideJobsCompleter:complete_manager(manager, stats, tag)
		if not is_table(manager) or type(manager.challenges) ~= "function" then
			return
		end
		local ok, challenges = pcall(function() return manager:challenges() end)
		if not ok or not is_table(challenges) then
			return
		end
		for _, c in ipairs(challenges) do
			if is_table(c) and c.id then
				local was = c.completed
				pcall(function() self:force_complete_objectives(c) end)
				pcall(function() manager:completed_challenge(c.id) end)
				-- Persist completed even if can_progress() (e.g. tango
				-- without DLC) blocked the official call.
				c.completed = true
				if not was then
					stats.jobs_new = stats.jobs_new + 1
				end
				claim_all_rewards(manager, c, stats)
			end
		end
		if tag then
			log_sjc("manager done: " .. tostring(tag))
		end
	end

	-- Managers, deduped by table identity: generic registry first (covers
	-- event_jobs + raid_jobs + future DLC), then explicit ones (tango is NOT
	-- in the generic registry; event/raid as fallback).
	local function collect_managers()
		local list, seen = {}, {}
		local function add(m)
			if is_table(m) and type(m.challenges) == "function" and not seen[m] then
				seen[m] = true
				list[#list + 1] = m
			end
		end
		local generic = managers and managers.generic_side_jobs
		if is_table(generic) and type(generic.side_jobs) == "function" then
			local ok, entries = pcall(function() return generic:side_jobs() end)
			if ok and is_table(entries) then
				for _, entry in ipairs(entries) do
					if is_table(entry) then
						add(entry.manager)
					end
				end
			end
		end
		if managers then
			add(managers.event_jobs)
			add(managers.raid_jobs)
			add(managers.tango)
		end
		return list
	end

	function SideJobsCompleter:complete_modern_jobs(stats)
		if not managers then
			return
		end
		self:prefill_event_collectives()
		for _, m in ipairs(collect_managers()) do
			pcall(function()
				self:complete_manager(m, stats, tostring(m.global_table_name or m.save_table_name or "mgr"))
			end)
		end
	end

	function SideJobsCompleter:complete_legacy_challenges(stats)
		local cm = managers and managers.challenge
		local stored = Global.challenge_manager
		if not cm or not is_table(stored) or not is_table(stored.challenges) then
			return
		end
		local prev = stored.validated
		stored.validated = true
		for key, def in pairs(stored.challenges) do
			if is_table(def) and def.id then
				pcall(function()
					if not cm:has_active_challenges(def.id, key) then
						cm:activate_challenge(def.id, key, def.category)
					end
				end)
				pcall(function()
					local active = cm:get_active_challenge(def.id, key)
					if is_table(active) then
						local was = active.completed
						if is_table(active.objectives) then
							for _, obj in ipairs(active.objectives) do
								finish_objective(obj)
							end
						end
						active.completed = true
						if not was then
							stats.legacy_new = stats.legacy_new + 1
						end
						cm:on_give_all_rewards(def.id, key)
					end
				end)
			end
		end
		stored.validated = prev
	end

	function SideJobsCompleter:complete_trophies_and_daily(stats)
		local sh = managers and managers.custom_safehouse
		if not sh then
			return
		end
		pcall(function()
			local trophies = sh:trophies()
			if is_table(trophies) then
				for _, trophy in ipairs(trophies) do
					if is_table(trophy) and trophy.id and not trophy.completed then
						if is_table(trophy.objectives) then
							for _, obj in ipairs(trophy.objectives) do
								finish_objective(obj)
							end
						end
						sh:complete_trophy(trophy.id)
						if trophy.completed then
							stats.trophies_new = stats.trophies_new + 1
						end
					end
				end
			end
		end)
		pcall(function()
			local daily = sh.get_daily_challenge and sh:get_daily_challenge() or nil
			local was = daily and daily.trophy and daily.trophy.completed
			sh:complete_daily()
			sh:reward_daily()
			if not was then
				stats.daily_new = 1
			end
		end)
	end

	function SideJobsCompleter:save_game()
		local sf = managers and managers.savefile
		if is_table(sf) and type(sf.save_game) == "function" then
			pcall(function() sf:save_game() end)
		end
	end

	function SideJobsCompleter:notify(msg)
		log_sjc(msg)
		local hud = managers and managers.hud
		if is_table(hud) and type(hud.show_hint) == "function" then
			pcall(function() hud:show_hint({ text = tostring(msg) }) end)
		end
	end

	function SideJobsCompleter:run()
		if self._running then
			return
		end
		if not managers then
			log_sjc("managers not ready, open main menu first")
			return
		end
		self._running = true
		local stats = { jobs_new = 0, rewards_new = 0, legacy_new = 0, trophies_new = 0, daily_new = 0 }
		pcall(function() self:complete_modern_jobs(stats) end)
		pcall(function() self:complete_legacy_challenges(stats) end)
		pcall(function() self:complete_trophies_and_daily(stats) end)
		pcall(function() self:save_game() end)
		self._running = false
		local msg = string.format("Side jobs done: %d new jobs (%d new rewards), %d new legacy, %d new trophies, daily %s. Restart game if UI lags.",
			stats.jobs_new, stats.rewards_new, stats.legacy_new, stats.trophies_new,
			stats.daily_new == 1 and "done" or "already done")
		self:notify(msg)
		pcall(function()
			QuickMenu:new("Side Jobs Completer", msg, { { text = "OK", is_cancel_button = true } }, true)
		end)
	end
end

-- Menu wiring: only on menumanager load. gamesetup hook just ensures the
-- global exists in-game too (core above already ran).
-- Uses the standard 3-hook submenu pattern (cf. SelectiveModsHider):
-- Setup (NewMenu) -> Populate (AddButton on OWN menu) -> Build (attach own
-- menu under nodes.blt_options). Adding a button directly to blt_options
-- without NewMenu crashes (MenuHelper:GetMenu returns nil).
if RequiredScript == "lib/managers/menumanager" then
	if not SideJobsCompleter._menu_wired then
		SideJobsCompleter._menu_wired = true
		local menu_id = "sjc_options"
		Hooks:Add("LocalizationManagerPostInit", "SJC_Loc", function(loc)
			pcall(function()
				loc:add_localized_strings({
					["sjc_menu_title"] = "Side Jobs Completer",
					["sjc_menu_desc"] = "Complete and claim all side jobs, trophies and daily."
				})
			end)
		end)
		Hooks:Add("MenuManagerSetupCustomMenus", "SJC_Setup", function(menu_manager, nodes)
			MenuHelper:NewMenu(menu_id)
		end)
		Hooks:Add("MenuManagerPopulateCustomMenus", "SJC_Populate", function(menu_manager, nodes)
			MenuHelper:AddButton({
				id = "sjc_complete_all",
				title = "Complete All Side Jobs",
				desc = "Complete + claim every side job (event/raid/tango/legacy) and safehouse trophies/daily. BACKUP YOUR SAVE first. Use solo/offline.",
				callback = "sjc_complete_all_clbk",
				menu_id = menu_id,
				priority = 100,
				localized = false
			})
		end)
		Hooks:Add("MenuManagerBuildCustomMenus", "SJC_Build", function(menu_manager, nodes)
			nodes[menu_id] = MenuHelper:BuildMenu(menu_id)
			if nodes.blt_options then
				MenuHelper:AddMenuItem(nodes.blt_options, menu_id, "sjc_menu_title", "sjc_menu_desc")
			else
				log("[SJC] nodes.blt_options missing, submenu not attached")
			end
		end)
		MenuCallbackHandler.sjc_complete_all_clbk = function(self, item)
			QuickMenu:new(
				"Complete All Side Jobs?",
				"Complete + claim ALL side jobs, trophies and daily? BACKUP YOUR SAVE first. Continue?",
				{
					{ text = "Yes, complete all", callback = function() SideJobsCompleter:run() end },
					{ text = "Cancel", is_cancel_button = true }
				},
				true
			)
		end
		log("[SJC] menu wired: Options > Mod Options > Side Jobs Completer > Complete All Side Jobs")
	end
elseif RequiredScript == "lib/setups/gamesetup" then
	log("[SJC] loaded")
end
