--[[
	Name: Clarity of Aim
	Author: Wobin
	Date: 24/06/2026
	Version: 1.0.0
]]--

local mod = get_mod("Clarity of Aim")
mod.version = "1.0.0"

local ScriptUnit = ScriptUnit
local Managers = Managers
local HEALTH_ALIVE = HEALTH_ALIVE
local player_manager = Managers.player

local OUTLINE_NAME = "clarity_of_aim_focus"

-- Reference to our registered outline profile table (mutated by refresh).
local outline_cfg = nil

local function outline_colour()
	return {
		(mod:get("coa_colour_R") or 255) / 255,
		(mod:get("coa_colour_G") or 0) / 255,
		(mod:get("coa_colour_B") or 0) / 255,
	}
end

local function material_layers()
	if mod:get("coa_see_through") then
		return { "minion_outline", "minion_outline_reversed_depth" }
	end

	return { "minion_outline" }
end

mod:hook_require("scripts/settings/outline/outline_settings", function(settings)
	settings.MinionOutlineExtension[OUTLINE_NAME] = {
		priority = 2,
		color = outline_colour(),
		material_layers = material_layers(),
		visibility_check = function(unit)
			return HEALTH_ALIVE[unit]
		end,
	}
	outline_cfg = settings.MinionOutlineExtension[OUTLINE_NAME]
end)

mod.refresh_outline_profile = function()
	if outline_cfg then
		outline_cfg.color = outline_colour()
		outline_cfg.material_layers = material_layers()
	end
end

-- Cached outline system + the single unit we currently outline.
local outline_system = nil
local outlined_unit = nil

local function get_outline_system()
	if not outline_system then
		local state_extension = Managers.state and Managers.state.extension
		outline_system = state_extension and state_extension:system("outline_system") or nil
	end

	return outline_system
end

local function remove_our_outline(unit)
	local osys = get_outline_system()
	if osys and unit then
		local ok = pcall(function()
			osys:remove_outline(unit, OUTLINE_NAME)
		end)
		if not ok then
			outline_system = nil
		end
	end
end

local function add_our_outline(unit)
	local osys = get_outline_system()
	if not osys or not unit then
		return false
	end

	local ok = pcall(function()
		osys:remove_outline(unit, OUTLINE_NAME)
		osys:add_outline(unit, OUTLINE_NAME)
	end)
	if not ok then
		outline_system = nil
		return false
	end

	return true
end

mod.set_focus_target = function(unit)
	if unit == outlined_unit then
		return
	end

	if outlined_unit then
		remove_our_outline(outlined_unit)
		outlined_unit = nil
	end

	if unit and add_our_outline(unit) then
		outlined_unit = unit
	end
end

mod.clear_focus = function()
	mod.set_focus_target(nil)
end

-- Returns the enemy the Advanced Combat Doctrines stance is auto-aiming at, or nil.
local function read_focus_target()
	local player = player_manager:local_player_safe(1)
	if not player then
		return nil
	end

	local player_unit = player.player_unit
	if not player_unit then
		return nil
	end

	local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")
	if not buff_extension or not buff_extension:has_keyword("enable_auto_aim") then
		return nil
	end

	local smart_targeting_extension = ScriptUnit.has_extension(player_unit, "smart_targeting_system")
	if not smart_targeting_extension then
		return nil
	end

	local targeting_data = smart_targeting_extension:targeting_data()
	local target = targeting_data and targeting_data.unit
	if target and HEALTH_ALIVE[target] then
		return target
	end

	return nil
end

local UPDATE_INTERVAL = 0.05
local update_accumulator = 0

mod.update = function(dt)
	if not mod:get("coa_enabled") then
		if outlined_unit then
			mod.clear_focus()
		end

		return
	end

	update_accumulator = update_accumulator + dt
	if update_accumulator < UPDATE_INTERVAL then
		return
	end
	update_accumulator = 0

	mod.set_focus_target(read_focus_target())
end

mod.on_all_mods_loaded = function()
	mod:info("Clarity of Aim " .. tostring(mod.version) .. " loaded")
end

mod.on_setting_changed = function(setting_id)
	if not setting_id then
		return
	end

	if setting_id:find("^coa_colour") or setting_id == "coa_see_through" then
		mod.refresh_outline_profile()
		mod.clear_focus()
	elseif setting_id == "coa_enabled" then
		if not mod:get("coa_enabled") then
			mod.clear_focus()
		end
	end
end

mod.on_unload = function(exit_game)
	mod.clear_focus()
end

mod.on_game_state_changed = function(status, state_name)
	if status == "exit" then
		mod.clear_focus()
		outline_system = nil
	end
end
