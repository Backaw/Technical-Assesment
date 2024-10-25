local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local PlayerDataService = require(Paths.Services.Data.PlayerDataService)

return function(_, player: Player)
	PlayerDataService.wipe(player)
end
