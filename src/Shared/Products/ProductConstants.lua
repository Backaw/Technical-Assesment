local ProductConstants = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyConstants = require(ReplicatedStorage.Modules.Currency.CurrencyConstants)
local RewardConstants = require(ReplicatedStorage.Modules.Rewards.RewardConstants)

export type Product = {
	Name: string?,
	Alias: string?,
	Price: CurrencyConstants.Price,
	Type: string?,
	Icon: string?,
	LimitedTime: boolean?,
}

export type ProductList = { [string]: Product }
export type ProductCategories = { [string]: ProductList }

local products: { [string]: { [string]: Product } } = {
	-- Item products are created below
	Coin = {},
	Multiplier = {},
}

local bundles: { [string]: {
	Name: string?,
	ExpiresAt: number?,
	Icon: string,
	Gamepass: number,
	Rewards: { RewardConstants.Reward },
} } =
	{}

ProductConstants.Products = products
ProductConstants.Types = {
	Coin = "Coin",
}
ProductConstants.Bundles = bundles

return ProductConstants
