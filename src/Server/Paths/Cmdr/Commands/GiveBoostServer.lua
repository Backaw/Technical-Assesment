local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local BoostService = require(Paths.Services.BoostService)

return function(context, player: Player, boost: string, lengthInMinutes: number)
	BoostService.createBoost(player, boost, if lengthInMinutes == -1 then math.huge else lengthInMinutes)
end
