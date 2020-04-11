local mod_skylayer = minetest.get_modpath("skylayer") ~= nil

local modpath = minetest.get_modpath("moon_phases");
local state = dofile(modpath .. "/datastorage.lua")()

local GSCYCLE = 0.5
moon_phases = {}

local function get_cycle_config()
	local DEFAULT_LENGTH = 4
	local config = minetest.settings:get("moon_phases_cycle") or DEFAULT_LENGTH
	config = math.floor(tonumber(config))
	if (not config) or config < 0 then
		minetest.log("warning", "[Moon Phases] Invalid cycle configuration")
		return DEFAULT_LENGTH
	end
	return config
end

local PHASE_LENGTH = get_cycle_config()
if state.day >= PHASE_LENGTH then
	state.day = 1
end

local function set_texture(player, texture)
	local sl = {}
	sl.name = "moon_phases:custom"
	sl.moon_data = {
		visible = true,
		texture = texture
	}
	if mod_skylayer then
		skylayer.add_layer(player:get_player_name(), sl)
	else
		player:set_moon(sl.moon_data)
	end
end

local function update_textures()
	for _, player in ipairs(minetest.get_connected_players()) do
		set_texture(player, "moon_" .. state.phase .. ".png")
	end
end

local function handle_time_progression()
	local time = minetest.get_timeofday()
	if time >= 0.5 and state.change_time then
		state.day = state.day + 1
		if state.day == PHASE_LENGTH then
			state.day = 1
			state.phase = (state.phase % 8) + 1
			state.change_time = false
			update_textures()
		end
	elseif time < 0.5 and not state.change_time then
		state.change_time = true
	end
end

function moon_phases.get_phase()
	return state.phase
end

function moon_phases.set_phase(phase)
	phase = math.floor(tonumber(phase))
	if (not phase) or phase < 0 or phase > 8 then
		return false
	end
	state.phase = phase
	update_textures()
	return true
end

minetest.register_on_joinplayer(function(player)
	set_texture(player, "moon_" .. state.phase .. ".png")
end)

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < GSCYCLE then return end
	handle_time_progression()
	timer = 0
end)

dofile(modpath .. "/commands.lua")