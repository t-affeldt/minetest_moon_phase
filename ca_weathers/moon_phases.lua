local name = "moon_phases:phase"
local mod_climate_api = minetest.get_modpath("climate_api") ~= nil

local GSCYCLE = 0.5								-- global step cycle
local DEFAULT_LENGTH = 4					-- default cycle length
local DEFAULT_STYLE = "realistic"	-- default texture style
local PHASE_COUNT = 8							-- number of phases to go through

-- retrieve mod configuration
local PHASE_LENGTH = minetest.settings:get("moon_phases_cycle") or DEFAULT_LENGTH
local TEXTURE_STYLE = minetest.settings:get("moon_phases_style") or DEFAULT_STYLE

local moon_phases = {}
local state = minetest.get_mod_storage()
local phase = 1

-- return the current moon phase
function moon_phases.get_phase()
	return phase
end

-- set the current moon phase
-- @param phase int Phase between 1 and PHASE_COUNT
function moon_phases.set_phase(nphase)
	phase = math.floor(tonumber(nphase))
	if (not nphase) or nphase < 1 or nphase > PHASE_COUNT then
		return false
	end
	local day = params.day_count
	local date_offset = state:get_int("date_offset")
	local progress = (day + date_offset - 1) % PHASE_LENGTH + 1
	local phase_offset = (nphase - phase + PHASE_COUNT) % PHASE_COUNT
	local add_offset = (phase_offset * PHASE_LENGTH) - progress
	if add_offset == 0 then add_offset = nil end
	phase = nphase
	state:set_int("date_offset", add_offset)
end

-- set the moon's texture style for the given player
function moon_phases.set_style(player, style)
	if style ~= "classic" and style ~= "realistic" then
		return false
	end
	local meta_data = player:get_meta()
	if style == DEFAULT_STYLE then style = nil end
	meta_data:set_string("moon_phases:texture_style", style)
	return true
end

-- calculate the current sky layout for a given player
local function generate_effects(params)
	local override = {}

	local time = params.time
	local day = params.day_count
	local date_offset = state:get_int("date_offset")
	day = day + date_offset
	if time > 0.5 then
		day = day + 1
	end

	local meta_data = params.player:get_meta()
	local style = meta_data:get_string("moon_phases:texture_style")
	if style ~= "classic" and style ~= "realistic" then
		style = TEXTURE_STYLE
	end

	phase = ((math.ceil(day / PHASE_LENGTH) - 1) % PHASE_COUNT) + 1
	override["climate_api:skybox"] = {
		moon_data = {
			texture = "moon_" .. phase .. "_" .. style .. ".png",
			scale = 0.8
		}
	}
	return override
end

local function update_sky(player)
	local params = {}
	params.time = minetest.get_timeofday()
	params.day_count = minetest.get_day_count()
	params.player = player
	local sky = generate_effects(params)
	player:set_moon(sky.moon_data)
end

local timer = 0
local function handle_time_progression(dtime)
	timer = timer + dtime
	if timer < GSCYCLE then return end
	for _, player in ipairs(minetest.get_connected_players()) do
		update_sky(player)
	end
	timer = 0
end

if mod_climate_api then
	-- register moon cycles as weather preset
	climate_api.register_weather(name, {}, generate_effects)
else
	-- set the moon texture of newly joined player
	minetest.register_on_joinplayer(update_sky)

	-- check for changes and update player skies
	minetest.register_globalstep(handle_time_progression)
end