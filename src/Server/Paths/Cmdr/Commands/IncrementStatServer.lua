local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local QuestService = require(Paths.Services.QuestService)

return function(_, player: Player, stat: string, amount: number)
	QuestService.incrementStat(player, stat, amount)
end
