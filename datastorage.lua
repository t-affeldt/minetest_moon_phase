local mod_datastorage = minetest.get_modpath("datastorage") ~= nil

local default_state = {
	change_time = true,
	day = 1,
	phase = 1
}

local function use_datastorage()
	local state = datastorage.get("moon_phases", "moon_state")
	for key, val in pairs(default_state) do
		if type(state[key]) == "nil" then
			state[key] = val
		end
	end
	return state
end

local storage
local function use_filesystem()
	local file_name = minetest.get_worldpath() .. "/moon_phases"
	minetest.register_on_shutdown(function()
		local file = io.open(file_name, "w")
		file:write(minetest.serialize(storage))
		file:close()
	end)

	local file = io.open(file_name, "r")
	if file ~= nil then
		storage = minetest.deserialize(file:read("*a"))
		file:close()
		if type(storage) == "table" then
			return storage
		end
	end
	storage = default_state
	return storage
end

local function get_storage()
	if mod_datastorage then
		return use_datastorage()
	else
		return use_filesystem()
	end
end

return get_storage