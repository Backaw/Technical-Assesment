local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Utils.CmdrUtil)
local TableUtil = require(ReplicatedStorage.Modules.Utils.TableUtil)
local ProductUtil = require(ReplicatedStorage.Modules.Products.ProductUtil)

local function stringsGetter()
	return TableUtil.getKeys(ProductUtil.getCmdrGamepasses())
end

local function stringToObject(itemType: string)
	return itemType
end

return function(registry)
	registry:RegisterType("gamepass", CmdrUtil.createTypeDefinition("gamepass", stringsGetter, stringToObject))
end
