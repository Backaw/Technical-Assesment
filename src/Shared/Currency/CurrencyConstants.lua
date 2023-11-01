local CurrencyConstants = {}

export type Currency = "Free" | "Coin" | "GamePass" | "ProductId"

CurrencyConstants.Currencies = {
	Coin = "Coin",
	GamePass = "GamePass",
	DevProduct = "DevProduct",
	Free = "Free",
}

CurrencyConstants.IngameCurrencies = { CurrencyConstants.Currencies.Coin }

CurrencyConstants.InfoType = {
	[CurrencyConstants.Currencies.GamePass] = Enum.InfoType.GamePass,
	[CurrencyConstants.Currencies.DevProduct] = Enum.InfoType.Product,
}

export type Price = {
	Currency: "Free",
} | {
	Currency: "Coin",
	Amount: number,
} | {
	Currency: "GamePass",
	Id: number,
	PriceInRobux: number?,
} | {
	Currency: "DevProduct",
	Id: number,
	PriceInRobux: number?,
}

return CurrencyConstants
