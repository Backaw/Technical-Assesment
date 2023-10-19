local ProductUtil = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProductConstants = require(ReplicatedStorage.Modules.Products.ProductConstants)
local CurrencyConstants = require(ReplicatedStorage.Modules.Currency.CurrencyConstants)
local TableUtil = require(ReplicatedStorage.Modules.Utils.TableUtil)

function ProductUtil.getGamepassProducts()
	return ProductUtil.getRobuxProducts()[Enum.InfoType.GamePass]
end

function ProductUtil.getRobuxProducts()
	local robuxProducts: { [Enum.InfoType]: { [number]: { ProductConstants.Product } } } =
		{ [Enum.InfoType.Product] = {}, [Enum.InfoType.GamePass] = {} }

	for _, products in pairs(ProductConstants.Products) do
		for _, product in pairs(products) do
			local price = product.Price
			local currency = price.Currency

			if currency == CurrencyConstants.Currencies.GamePass or currency == CurrencyConstants.Currencies.DevProduct then
				local id = price.Id

				local productOfCurrency = robuxProducts[CurrencyConstants.InfoType[currency]]
				local otherProductsWithGamepass = productOfCurrency[id] or {}
				table.insert(otherProductsWithGamepass, product)

				productOfCurrency[id] = otherProductsWithGamepass
			end
		end
	end

	return robuxProducts
end

function ProductUtil.getGamepassAddress(product: ProductConstants.Product)
	return ProductUtil.getGamepassAddressFromId(product.Price.Id)
end

function ProductUtil.getGamepassAddressFromId(id: number)
	return "GamePasses." .. id
end

function ProductUtil.getProduct(type: string, name: string)
	-- ERROR: Invalid product type
	if not ProductConstants.Types[type] then
		error(("%s is an invalid product type"):format(type))
	end

	return ProductConstants.Products[type][name]
end

function ProductUtil.isPremium(product: table)
	local currency = product.Price.Currency
	return currency == CurrencyConstants.Currencies.DevProduct or currency == CurrencyConstants.Currencies.GamePass
end

return ProductUtil
