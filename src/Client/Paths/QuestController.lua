local QuestController = {}

local Players = game:GetService("Players")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local QuestUtil = require(Paths.shared.Quests.QuestUtil)
local QuestConstants = require(Paths.shared.Quests.QuestConstants)
local DataController = require(Paths.controllers.DataController)
local TableUtil = require(Paths.shared.Utils.TableUtil)

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
