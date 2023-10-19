local ProductConstants = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyConstants = require(ReplicatedStorage.Modules.Currency.CurrencyConstants)

export type Product = {
	Name: string?,
	Alias: string?,
	Price: CurrencyConstants.Price,
	Type: string?,
	Model: Model?,
	Icon: string?,
}

local products: { [string]: { [string]: Product } } = {
	-- Item products are created below
	Coin = {},
	Multiplier = {},
}

ProductConstants.Products = products
ProductConstants.Types = {
	Coin = "Coin",
}

return ProductConstants
