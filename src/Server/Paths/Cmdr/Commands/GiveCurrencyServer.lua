local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local CurrencyService = require(Paths.Services.CurrencyService)

return function(_, player: Player, currency: string, amount: number)
	CurrencyService.transact(player, currency, amount)
end
