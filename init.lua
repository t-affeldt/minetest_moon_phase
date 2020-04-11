local mod_skylayer = minetest.get_modpath("skylayer") ~= nil

local modpath = minetest.get_modpath("moon_phases");

local GSCYCLE = 0.5							-- global step cycle
local DEFAULT_LENGTH = 4				-- default cycle length
local DEFAULT_STYLE = "classic"	-- default texture style

moon_phases = {}
local state = minetest.get_mod_storage()
if not state:contains("day") then
	state:from_table({
		day = 1,
		phase = 1,
		change_time = 1
	})
end

-- retrieve and parse mod configuration
local function get_cycle_config()
	local config = minetest.settings:get("moon_phases_cycle") or DEFAULT_LENGTH
	config = math.floor(tonumber(config))
	if (not config) or config < 0 then
		minetest.log("warning", "[Moon Phases] Invalid cycle configuration")
		return DEFAULT_LENGTH
	end
	return config
end

local PHASE_LENGTH = get_cycle_config()

-- set the moon texture of a player to the given texture
local function set_texture(player, texture)
	local sl = {}
	sl.name = "moon_phases:custom"
	sl.moon_data = {
		visible = true,
		texture = texture,
		scale = 0.8
	}
	if mod_skylayer then
		skylayer.add_layer(player:get_player_name(), sl)
	else
		player:set_moon(sl.moon_data)
	end
end

-- update moon textures of all online players
local function update_textures()
	local phase = state:get_int("phase")
	for _, player in ipairs(minetest.get_connected_players()) do
		set_texture(player, "moon_" .. phase .. ".png")
	end
end

-- check for day changes
local function handle_time_progression()
	local time = minetest.get_timeofday()
	local day = state:get_int("day")
	local phase = state:get_int("phase")
	local change_time = state:get_int("change_time") == 1
	if time >= 0.5 and change_time then
		day = day + 1
		state:set_int("day", day)
		if day % PHASE_LENGTH == 0 then
			state:set_int("phase", (phase % 8) + 1)
			state:set_int("change_time", 0)
			update_textures()
		end
	elseif time < 0.5 and not change_time then
		state:set_int("change_time", 1)
	end
end

-- return the current moon phase
function moon_phases.get_phase()
	return state:get_int("phase")
end

-- set the current moon phase
-- @param phase int Phase between 1 and 8
function moon_phases.set_phase(phase)
	phase = math.floor(tonumber(phase))
	if (not phase) or phase < 1 or phase > 8 then
		return false
	end
	state:set_int("phase", phase)
	update_textures()
	return true
end

-- set the moon texture of newly joined player
minetest.register_on_joinplayer(function(player)
	local phase = state:get_int("phase")
	-- phase might not have been set at server start
	if phase < 1 then phase = 1 end
	set_texture(player, "moon_" .. phase .. ".png")
end)

-- check for day changes and call handlers
local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < GSCYCLE then return end
	handle_time_progression()
	timer = 0
end)

-- include API for chat commands
dofile(modpath .. "/commands.lua")