local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Utils.CmdrUtil)
local CurrencyConstants = require(ReplicatedStorage.Modules.Currency.CurrencyConstants)

local function stringsGetter()
	return CurrencyConstants.IngameCurrencies
end

local function stringToObject(itemType: string)
	return itemType
end

return function(registry)
	registry:RegisterType("currency", CmdrUtil.createTypeDefinition("currency", stringsGetter, stringToObject))
end
