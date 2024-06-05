local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Utils.CmdrUtil)
local BoostConstants = require(ReplicatedStorage.Modules.Constants.BoostConstants)
local TableUtil = require(ReplicatedStorage.Modules.Utils.TableUtil)

local function stringsGetter()
	return TableUtil.getKeys(BoostConstants.Boosts)
end

local function stringToObject(itemType: string)
	return itemType
end

return function(registry)
	registry:RegisterType("boost", CmdrUtil.createTypeDefinition("boost", stringsGetter, stringToObject))
end
