local CoinController = {}

local Players = game:GetService("Players")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local Signal = require(Paths.shared.Signal)
local DataController = require(Paths.controllers.DataController)
local CurrencyUtil = require(Paths.shared.Currency.CurrencyUtil)
local CurrencyConstants = require(Paths.shared.Currency.CurrencyConstants)

-------------------------------------------------------------------------------
-- PRIVATE MEMBERS
-------------------------------------------------------------------------------
local cache: number = DataController.get(CurrencyUtil.getAddress(CurrencyConstants.Currencies.Coin))

-------------------------------------------------------------------------------
-- PUBLIC MEMBERS
-------------------------------------------------------------------------------
CoinController.changed = Signal.new() -- (newValue : number, oldValue : number)

-------------------------------------------------------------------------------
-- PUBLIC METHODS
-------------------------------------------------------------------------------
function CoinController.get()
	return cache
end

function CoinController.transact(transacting: number, serverInitiated: true?)
	if transacting > 0 and not serverInitiated then
		transacting *= DataController.get(CurrencyUtil.getMultiplierAddress("Coin"))
	end

	local nextValue = cache + math.floor(transacting)
	if nextValue >= 0 then
		CoinController.changed:Fire(nextValue, cache)
		cache = nextValue

		return true
	end

	return false
end

-------------------------------------------------------------------------------
-- LOGIC
-------------------------------------------------------------------------------

DataController.updated:Connect(function(event, _, metadata)
	if event == "CoinChanged" and not metadata.ClientInitiated then
		CoinController.transact(metadata.Transacting, true)
	end
end)

return CoinController
