local ProductService = {}

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local MarketplaceService = game:GetService("MarketplaceService")
local Paths = require(ServerScriptService.Paths)
local Promise = require(Paths.shared.Packages.Promise)
local Signal = require(Paths.shared.Signal)
local Remotes = require(Paths.shared.Remotes)
local CurrencyConstants = require(Paths.shared.Currency.CurrencyConstants)
local ProductConstants = require(Paths.shared.Products.ProductConstants)
local ProductUtil = require(Paths.shared.Products.ProductUtil)
local PlayerDataService = require(Paths.services.Data.PlayerDataService)
local CoinService = require(Paths.services.CoinService)
local PlayersService = require(Paths.services.PlayersService)
local GameAnalytics = require(Paths.shared.Packages.GameAnalytics)

local MAX_PRICE_LOAD_ATTEMPTS = 5

type Validator = (Player, number) -> boolean

-------------------------------------------------------------------------------
--  PRIVATE MEMBERS
-------------------------------------------------------------------------------
local clientRelaying = Promise.resolve()
local validators: { [ProductConstants.Product]: Validator } = {}

-------------------------------------------------------------------------------
-- PUBLIC METHODS
-------------------------------------------------------------------------------
ProductService.productPurchased = Signal.new() --> (player : Player, product : ProductConstants.Product)

-------------------------------------------------------------------------------
-- PRIVATE METHODS
-------------------------------------------------------------------------------
function ProductService.hasGamePass(player: Player, product: ProductConstants.Product)
	return PlayerDataService.get(player, ProductUtil.getGamepassAddress(product)) ~= nil
end

function ProductService.purchaseProduct(player: Player, productType: string, productName: string, count: number?)
	local success = false

	count = count or 1

	-- RETURN: Product doesn't exist
	local product = ProductConstants.Products[productType][productName]
	if not product then
		return false
	end

	-- RETURN: Purchase isn't available atm
	local validator = validators[product]
	if validator then
		if not validator(player, count) then
			return false
		end
	end

	local price = product.Price
	if price.Currency == CurrencyConstants.Currencies.Free then
		success = true
	elseif price.Currency == CurrencyConstants.Currencies.Coin then
		success = CoinService.transact(player, -price.Amount * count, productType, productName, true)
	else
		count = 1

		if price.Currency == CurrencyConstants.Currencies.DevProduct then
			local id = price.Id

			MarketplaceService:PromptProductPurchase(player, price.Id)
			_, _, _, success = Promise.fromEvent(MarketplaceService.PromptProductPurchaseFinished, function(purchasorId, purchaseId)
				return Players:GetPlayerByUserId(purchasorId) == player and id == purchaseId
			end):await()
			if success then
				PlayerDataService.append(player, "DevProducts", {
					Timestamp = os.time(),
					Id = id,
				})
			end
		elseif price.Currency == CurrencyConstants.Currencies.GamePass then
			if ProductService.hasGamePass(player, product) then
				success = true
			else
				local id = price.Id

				MarketplaceService:PromptGamePassPurchase(player, price.Id)
				_, _, _, success = Promise.fromEvent(MarketplaceService.PromptGamePassPurchaseFinished, function(purchasor, purchaseId)
					return player == purchasor and id == purchaseId
				end):await()

				if success then
					PlayerDataService.set(player, ProductUtil.getGamepassAddress(product), true, "GamePassPurchased", {
						Id = id,
					})
				end
			end
		end
	end

	if success then
		ProductService.productPurchased:Fire(player, product, count)
	end

	return success
end

function ProductService.registerValidator(product: ProductConstants.Product, validator: Validator)
	validators[product] = validator
end

-- Register items purchased outsite of the game
ProductService.loadPlayer = PlayersService.promisifyLoader(function(player: Player)
	local userId = player.UserId

	for id, products in pairs(ProductUtil.getGamepassProducts()) do
		local address = ProductUtil.getGamepassAddressFromId(id)

		if not PlayerDataService.get(player, address) then
			Promise.retry(function()
				return Promise.new(function(resolve)
					local owned = MarketplaceService:UserOwnsGamePassAsync(userId, id)
					resolve(owned)
				end)
			end, 3):andThen(function(owned)
				if owned then
					for _, product in products do
						ProductService.productPurchased:Fire(player, product)
					end

					PlayerDataService.set(player, address, id, "GamePassPurchased", {
						Id = id,
					})
				end
			end)
		end
	end
end, "gamepasses")

function ProductService.start()
	-- Generate complex products
	for _, generator in pairs(script.Parent.Generators:GetChildren()) do
		local productType = generator.Name:gsub("ProductGenerator", "")

		-- ERROR: Invalid product type
		if not ProductConstants.Types[productType] then
			error(("The following product generator has an invalid name: %s"):format(generator:GetFullName()))
		end

		ProductConstants.Products[productType] = require(generator).getProducts()
	end

	-- Apply robux prices
	local promises = {}
	for infoType, idsToProducts in pairs(ProductUtil.getRobuxProducts()) do
		for id, products in pairs(idsToProducts) do
			local priceInRobux

			table.insert(
				promises,
				Promise.retry(function()
					return Promise.new(function(resolve, reject)
						local success, info = pcall(function()
							return MarketplaceService:GetProductInfo(id, infoType)
						end)
						if success then
							resolve(info)
						else
							reject(info)
						end
					end)
				end, MAX_PRICE_LOAD_ATTEMPTS)
					:andThen(function(info)
						priceInRobux = info.PriceInRobux
					end)
					:catch(function()
						priceInRobux = 0
					end)
					:finally(function()
						for _, product in pairs(products) do
							product.Price.PriceInRobux = priceInRobux
						end
					end)
			)
		end
	end

	for productType, productList in pairs(ProductConstants.Products) do
		for name, product in pairs(productList) do
			product.Type = productType
			product.Name = name
		end
	end

	clientRelaying = clientRelaying:andThen(function()
		return Promise.all(promises)
	end)
end

MarketplaceService.ProcessReceipt = function(info)
	GameAnalytics:ProcessReceiptCallback(info)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

Remotes.bindFunctions({
	PromptProductPurchase = ProductService.purchaseProduct,
	GetProducts = function()
		clientRelaying:await()
		return ProductConstants.Products
	end,
})

Remotes.declareEvent("ShopItemsRotated")

return ProductService
