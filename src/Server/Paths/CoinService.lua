local CoinService = {}

local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local CurrencyConstants = require(Paths.shared.Currency.CurrencyConstants)
local CurrencyUtil = require(Paths.shared.Currency.CurrencyUtil)
local PlayerDataService = require(Paths.services.Data.PlayerDataService)
local ProductService: typeof(require(Paths.services.Products.ProductService))
local ProductConstants = require(Paths.shared.Products.ProductConstants)
local GameAnalytics = require(Paths.shared.Packages.GameAnalytics)
local GameAnalyticsService: typeof(require(Paths.services.GameAnalyticsService))
local TableUtil = require(Paths.shared.Utils.TableUtil)
local QuestService: typeof(require(Paths.services.QuestService))

local ADDRESS = CurrencyUtil.getAddress(CurrencyConstants.Currencies.Coin)
local MULTIPLIER_ADDRESS = CurrencyUtil.getMultiplierAddress(CurrencyConstants.Currencies.Coin)

-------------------------------------------------------------------------------
-- PUBLIC MEMBERS
-------------------------------------------------------------------------------
CoinService.ResourceType = {
	PromoCode = "PromoCode",
	Reward = "Reward",
	Gameplay = "Gameplay",
}

-------------------------------------------------------------------------------
-- PUBLIC METHODS
-------------------------------------------------------------------------------
-- If client initiated then you can assume that the client has already updated on it's end
function CoinService.transact(
	player: Player,
	transacting: number,
	resourceType: string?,
	resourceId: string?,
	clientInitiated: true?,
	robuxPurchase: true?
)
	-- RETURN: Item type doesn't exist
	if resourceType and not CoinService.ResourceType[resourceType] then
		error(("%s resource item type doesn't exist"):format(resourceType))
	end

	local multipliedTransacting = transacting
	if PlayerDataService.get(player, ADDRESS) + transacting >= 0 then
		if transacting > 0 then
			multipliedTransacting *= PlayerDataService.get(player, MULTIPLIER_ADDRESS)
			if not robuxPurchase then
				QuestService.incrementStat(player, "CoinEarned", multipliedTransacting)
			end
		end

		PlayerDataService.increment(player, ADDRESS, multipliedTransacting, "CoinChanged", {
			ClientInitiated = clientInitiated,
			Transacting = math.floor(multipliedTransacting),
		})

		if resourceType or robuxPurchase then
			local itemType, itemId
			if robuxPurchase then
				itemType = "Coin"
				itemId = tostring(transacting)
			else
				itemType = resourceType
				itemId = resourceId
			end

			GameAnalyticsService.addEvent("ResourceEvent", player.UserId, {
				currency = "Coin",
				flowType = if transacting > 0 then GameAnalytics.EGAResourceFlowType.Source else GameAnalytics.EGAResourceFlowType.Sink,
				amount = math.abs(multipliedTransacting),
				itemType = itemType,
				itemId = itemId,
			})
		end

		return true
	end

	return false
end

function CoinService.getResourceTypes()
	return TableUtil.toArray(CoinService.ResourceType)
end

function CoinService.init()
	ProductService = require(Paths.services.Products.ProductService)
	GameAnalyticsService = require(Paths.services.GameAnalyticsService)
	QuestService = require(Paths.services.QuestService)

	ProductService.productPurchased:Connect(function(player: Player, product: ProductConstants.Product)
		if product.Type == CurrencyConstants.Currencies.Coin then
			CoinService.transact(player, tonumber(product.Name), nil, nil, nil, true)
		end
	end)

	for productType in pairs(ProductConstants.Types) do
		CoinService.ResourceType[productType] = productType
	end
end

return CoinService
