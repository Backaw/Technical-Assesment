local CurrencyService = {}

local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local CurrencyConstants = require(Paths.Shared.Currency.CurrencyConstants)
local CurrencyUtil = require(Paths.Shared.Currency.CurrencyUtil)
local PlayerDataService = require(Paths.Services.Data.PlayerDataService)
local ProductService: typeof(require(Paths.Services.Products.ProductService))
local ProductConstants = require(Paths.Shared.Products.ProductConstants)
local GameAnalytics = require(Paths.Shared.Packages.GameAnalytics)
local GameAnalyticsService: typeof(require(Paths.Services.GameAnalyticsService))

-------------------------------------------------------------------------------
-- PUBLIC MEMBERS
-------------------------------------------------------------------------------
CurrencyService.ResourceType = {
	Reward = "Reward",
}

-------------------------------------------------------------------------------
-- PUBLIC METHODS
-------------------------------------------------------------------------------
-- If client initiated then you can assume that the client has already updated on it's end
function CurrencyService.transact(
	player: Player,
	currency: string,
	transacting: number,
	resourceType: string?,
	itemId: string?,
	clientInitiated: true?
)
	-- RETURN: Item type doesn't exist
	if resourceType and not CurrencyService.ResourceType[resourceType] then
		error(("%s resource item type doesn't exist"):format(resourceType))
	end

	local address = CurrencyUtil.getAddress(currency)
	if PlayerDataService.get(player, address) + transacting >= 0 then
		if transacting > 0 then
			transacting *= PlayerDataService.get(player, CurrencyUtil.getMultiplierAddress(currency))
		end

		PlayerDataService.increment(player, address, transacting, "CurrencyChanged", {
			ClientInitiated = clientInitiated,
			Currency = currency,
			Transacting = math.floor(transacting),
		})

		if resourceType then
			GameAnalyticsService.addEvent("ResourceEvent", player.UserId, {
				flowType = GameAnalytics.EGAResourceFlowType[if transacting > 1 then "Source" else "Sink"],
				currency = currency,
				amount = math.abs(transacting),
				itemType = resourceType,
				itemId = itemId,
			})
		end

		return true
	end

	return false
end

function CurrencyService.init()
	ProductService = require(Paths.Services.Products.ProductService)
	GameAnalyticsService = require(Paths.Services.GameAnalyticsService)

	-- TODO: Allow puchasing if there is a product with the name available
end

return CurrencyService