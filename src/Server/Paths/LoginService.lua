local LoginService = {}

local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local PlayersService = require(Paths.Services.PlayersService)
local PlayerDataService = require(Paths.Services.Data.PlayerDataService)
local QuestService = require(Paths.Services.QuestService)
local GameConstants = require(Paths.Shared.Game.GameConstants)
local QuestConstants = require(Paths.Shared.Quests.QuestConstants)

LoginService.loadPlayer = PlayersService.promisifyLoader(function(player)
	local loginTime = os.time()

	local countdown = task.spawn(function()
		while true do
			task.wait(60)
			QuestService.incrementStat(player, QuestConstants.Stats.MinutesPlayed, 1)
		end
	end)

	PlayersService.registerUnloadTask(player, function()
		PlayerDataService.set(player, "LastLogin", { Time = loginTime, Version = GameConstants.Version })
		task.cancel(countdown)
	end)
end, "Login")

return LoginService
