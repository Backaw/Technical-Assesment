local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Utils.CmdrUtil)
local ItemConstants = require(ReplicatedStorage.Modules.Items.ItemConstants)
local TableUtil = require(ReplicatedStorage.Modules.Utils.TableUtil)

local function stringsGetter()
	return TableUtil.toArray(ItemConstants.Types)
end

local function stringToObject(itemType: string)
	return itemType
end

return function(registry)
	registry:RegisterType("itemType", CmdrUtil.createTypeDefinition("itemType", stringsGetter, stringToObject))
end
