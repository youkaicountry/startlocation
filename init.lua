--[[
Start Location Minetest mod
Copyright (C) 2015  Nathaniel Caldwell (YoukaiCountry)

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
]]--

startlocation = {}
startlocation.location = {x=0, y=0, z=0}
startlocation.initialized = false

function startlocation.set_start(pos)
	startlocation.location = vector.round(pos)
	startlocation.initialized = true
	startlocation.save()
end

-- Returns true if successful, else false
function startlocation.move_player_to(player)
	if not startlocation.initialized then
		minetest.chat_send_all("No start location. One should be set via the setstart command.")
		return false
	end
	player:setpos(startlocation.location)
    return true
end

function startlocation.move_all_online()
    for _,player in ipairs(minetest.get_connected_players()) do
        startlocation.move_player_to(player)
    end
end

function startlocation.load()
	local input = io.open(minetest.get_worldpath() .. "/startlocation", "r")
	if not input then
		return
	end
	startlocation.location = minetest.deserialize(input:read("*l"))
	startlocation.initialized = true
	io.close(input)
end

function startlocation.save()
	local output = io.open(minetest.get_worldpath() .. "/startlocation", "w")
	output:write(minetest.serialize(startlocation.location))
	io.close(output)
end

minetest.register_on_newplayer(function(player)
	startlocation.move_player_to(player)
end)

minetest.register_privilege("startlocation", {
	description = "Can use /setstart and /gotostart",
	give_to_singleplayer = false
})

minetest.register_chatcommand("setstart", {
	params = "",
	privs = {startlocation=true},
	description = "Set the start location to your current location.",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		local pos = player:getpos()
		startlocation.set_start(pos)
		return true, "New start location set."
	end,
})

minetest.register_chatcommand("gotostart", {
	params = "",
	privs = {startlocation=true},
	description = "Teleport to the start location.",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		startlocation.move_player_to(player)
	end,
})

minetest.register_chatcommand("allongotostart", {
	params = "",
	privs = {startlocation=true},
	description = "Teleport all online players to the start location.",
	func = function(name, param)
		startlocation.move_all_online()
	end,
})

minetest.register_on_respawnplayer(function(player)
	return startlocation.move_player_to(player)
end)

startlocation.load()