local ProductController = {}

local Players = game:GetService("Players")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local Remotes = require(Paths.Shared.Remotes)
local ProductUtil = require(Paths.Shared.Products.ProductUtil)
local ProductConstants = require(Paths.Shared.Products.ProductConstants)
local CurrencyConstants = require(Paths.Shared.Currency.CurrencyConstants)
local CurrencyController = require(Paths.Controllers.CurrencyController)
local CurrencyUtil = require(Paths.Shared.Currency.CurrencyUtil)
local Snackbar = require(Paths.Controllers.UI.Components.Snackbar)
local Promise = require(Paths.Shared.Packages.Promise)
local DataController = require(Paths.Controllers.DataController)
local Signal = require(Paths.Shared.Signal)
local Sounds = require(Paths.Shared.Sounds)

local DEBUGGING = false

-------------------------------------------------------------------------------
-- PRIVATE MEMBERS
-------------------------------------------------------------------------------
local debounces: { [ProductConstants.Product]: true? } = {}
local marketplacePromptOpen = false

-------------------------------------------------------------------------------
-- PUBLIC MEMBERS
-------------------------------------------------------------------------------
ProductController.ProductPurchased = Signal.new()

-------------------------------------------------------------------------------
-- PUBLIC  METHODS
-------------------------------------------------------------------------------
function ProductController.hasGamePass(product: ProductConstants.Product)
	if product.Price.Currency ~= CurrencyConstants.Currencies.GamePass then
		error(("Product %s %s is not associated with a GamePass"):format(product.Type, product.Name))
	end

	return DataController.get(ProductUtil.getGamepassAddress(product)) ~= nil
end

function ProductController.promptPurchase(product: ProductConstants.Product, count: number?, getServerVerification: true?)
	if debounces[product] then
		return false
	end

	count = count or 1
	local price = product.Price

	local success
	if CurrencyUtil.isInGameCurrency(price.Currency) then
		if CurrencyController.transact(price.Currency, -price.Amount * count) then
			success = true
		else
			Snackbar.error(("Not enough %s"):format(price.Currency))
			return false
		end
	elseif ProductUtil.isPremium(product) then
		if marketplacePromptOpen then
			return false
		end

		marketplacePromptOpen = true
		if price.Currency == CurrencyConstants.Currencies.GamePass then
			success = if ProductController.hasGamePass(product) then true else nil
		end
	end

	debounces[product] = true

	local serverValidation = Promise.new(function(resolve)
		success = Remotes.invokeServer("PromptProductPurchase", product.Type, product.Name, count)

		if not success then
			if DEBUGGING then
				warn(("Product purchase failed for %s product %s"):format(product.Type, product.Name))
			end

			-- TODO: Reverse handler?
		end

		resolve()
	end)

	if getServerVerification or not success then
		serverValidation:await()
	end

	if success then
		ProductController.ProductPurchased:Fire(product, count)
	end

	if ProductUtil.isPremium(product) then
		marketplacePromptOpen = false
	end

	debounces[product] = nil
	return success
end

-------------------------------------------------------------------------------
-- EVENT HANDLERS
-------------------------------------------------------------------------------
ProductConstants.Products = Remotes.invokeServer("GetProducts")

return ProductController
