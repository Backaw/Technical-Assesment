local QuestUtil = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local QuestConstants = require(ReplicatedStorage.Modules.Quests.QuestConstants)
local StringUtil = require(ReplicatedStorage.Modules.Utils.StringUtil)

function QuestUtil.getStatAddress(stat: string)
	return ("Quests.Stats.%s"):format(stat)
end

function QuestUtil.getDescription(quest: QuestConstants.Quest)
	return quest.Description:format(StringUtil.getCompactNumber(quest.Goal))
end

return QuestUtil
