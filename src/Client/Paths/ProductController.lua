local ProductController = {}

local Players = game:GetService("Players")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local Remotes = require(Paths.shared.Remotes)
local ProductUtil = require(Paths.shared.Products.ProductUtil)
local ProductConstants = require(Paths.shared.Products.ProductConstants)
local CurrencyConstants = require(Paths.shared.Currency.CurrencyConstants)
local CoinController = require(Paths.controllers.CoinController)
local Snackbar = require(Paths.controllers.UI.Components.Snackbar)
local Promise = require(Paths.shared.Packages.Promise)
local DataController = require(Paths.controllers.DataController)
local Signal = require(Paths.shared.Signal)
local Sounds = require(Paths.shared.Sounds)

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
	if price.Currency == CurrencyConstants.Currencies.Coin then
		if CoinController.transact(-price.Amount * count) then
			success = true
		else
			Snackbar.error("Not enough cash")

			--[[ local amountNeeded = price.Amount - CoinController.get()
			for cashYield, cashProduct in pairs(ProductConstants.Products.Coin) do
				if tonumber(cashYield) >= amountNeeded then
					task.spawn(function()
						ProductController.promptPurchase(cashProduct)
					end)
					break
				end
			end *]]

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
