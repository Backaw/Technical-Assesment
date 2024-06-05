local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local ItemService = require(Paths.Services.ItemService)

return function(_, player: Player, itemType: string, itemName: string)
	ItemService.giveItem(player, itemType, itemName)
end
