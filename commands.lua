minetest.register_privilege("moonphase", {
	description = "Change the phase of the moon",
	give_to_singleplayer = false
})

minetest.register_chatcommand("moonphase", {
	description ="Display current moon phase",
	func = function(playername, param)
		local msg = "Current moon phase: " .. moon_phases.get_phase()
			.. "\nRun set_moonphase [1-8] to change this."
		minetest.chat_send_player(playername, msg)
	end
})

minetest.register_chatcommand("set_moonphase", {
	params = "<phase>",
	description = "Set moon phase to given value",
	privs = {moonphase = true},
	func = function(playername, param)
		if param == nil or param == "" then
			minetest.chat_send_player(playername, "Provide a number between 1 and 8")
		else
			local change = moon_phases.set_phase(param)
			if change then
				minetest.chat_send_player(playername, "Moon phase changed successfully")
			else
				minetest.chat_send_player(playername, "Invalid argument. Provide a number between 1 and 8.")
			end
		end
	end
})