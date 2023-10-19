local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local PlayerDataService = require(Paths.services.Data.PlayerDataService)

return function(context, player: Player)
	PlayerDataService.wipe(player)
end
