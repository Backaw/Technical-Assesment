local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local PlayerDataService = require(Paths.Services.Data.PlayerDataService)
local TableUtil = require(Paths.Shared.Utils.TableUtil)

return function(_, player: Player)
	TableUtil.print(PlayerDataService.get(player, ""))
end
