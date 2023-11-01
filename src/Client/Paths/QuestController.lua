local QuestController = {}

local Players = game:GetService("Players")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local QuestUtil = require(Paths.Shared.Quests.QuestUtil)
local QuestConstants = require(Paths.Shared.Quests.QuestConstants)
local DataController = require(Paths.Controllers.DataController)
local TableUtil = require(Paths.Shared.Utils.TableUtil)

function QuestController.getQuestProgress(quest: QuestConstants.Quest)
	local progress = DataController.get(QuestUtil.getStatAddress(quest.Stat))
	local validator = quest.Validator
	if validator then
		return validator(progress)
	elseif typeof(progress) == "table" then
		return TableUtil.length(progress)
	else
		return progress
	end
end

return QuestController
