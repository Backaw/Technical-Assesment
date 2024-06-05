local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Utils.CmdrUtil)
local QuestConstants = require(ReplicatedStorage.Modules.Quests.QuestConstants)
local TableUtil = require(ReplicatedStorage.Modules.Utils.TableUtil)

local function stringsGetter()
	return TableUtil.getKeys(QuestConstants.DefaultStats)
end

local function stringToObject(itemType: string)
	return itemType
end

return function(registry)
	registry:RegisterType("questStat", CmdrUtil.createTypeDefinition("questStat", stringsGetter, stringToObject))
end
