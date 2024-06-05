local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local Remotes = require(Paths.Shared.Remotes)

local devices: { [Player]: string } = {}

Players.PlayerRemoving:Connect(function(player)
	devices[player] = nil
end)

Remotes.bindEvents({
	DeviceDetermined = function(player, device)
		devices[player] = device
	end,
})

return function(_, player: Player)
	print(("(%s)%s's device: %s"):format(player.UserId, player.Name, devices[player] or "nil"))
end
