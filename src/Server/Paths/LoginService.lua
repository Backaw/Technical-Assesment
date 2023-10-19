local LoginService = {}

local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local PlayersService = require(Paths.services.PlayersService)
local PlayerDataService = require(Paths.services.Data.PlayerDataService)
local QuestService = require(Paths.services.QuestService)
local GameConstants = require(Paths.shared.Game.GameConstants)

LoginService.loadPlayer = PlayersService.promisifyLoader(function(player)
	local loginTime = os.time()

	local countdown = task.spawn(function()
		while true do
			task.wait(60)
			QuestService.incrementStat(player, "MinutesPlayed", 1)
		end
	end)

	PlayersService.registerUnloadTask(player, function()
		PlayerDataService.set(player, "LastLogin", { Time = loginTime, Version = GameConstants.Version })
		task.cancel(countdown)
	end)
end, "Login")

return LoginService
