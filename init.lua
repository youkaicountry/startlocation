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
startlocation.location = {}

startlocation.location.x = 0
startlocation.location.y = 0
startlocation.location.z = 0
startlocation.location.initialized = false

function startlocation.set_start(x, y, z)
    startlocation.location.x = x
    startlocation.location.y = y
    startlocation.location.z = z
    startlocation.location.initialized = true
    startlocation.save()
    end

function startlocation.move_player_to(player)
    if startlocation.location.initialized == false then
        minetest.chat_send_all("No start location. One should be set via the setstart command.")
        return
    end
    player:setpos({x=startlocation.location.x, y=startlocation.location.y, z=startlocation.location.z})
    end
    
function startlocation.load()
    local input = io.open(minetest.get_worldpath() .. "/startlocation", "r")
    if input then
	    startlocation.location = minetest.deserialize(input:read("*l"))
	    io.close(input)
    end
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
	give_to_singleplayer= false,
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
        startlocation.set_start(pos.x, pos.y, pos.z)
        minetest.chat_send_player(player:get_player_name(), "New start location set.")
		return true, ""
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
		return true, ""
	end,
})

minetest.register_on_respawnplayer(function(player)
	
    return true
end)

startlocation.load()
