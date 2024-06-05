-- All values are stored in .Stats part of a player's data
local QuestConstants = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RewardConstants = require(ReplicatedStorage.Modules.Rewards.RewardConstants)

export type Quest = {
	Name: string?,
	Stat: string?,
	Validator: ((table) -> number) | nil,
	Goal: number,
	Description: string?,
	Reward: RewardConstants.Reward | nil,
}
local templates = {
	Win = {
		Description = "Win %s times",
		Stat = "Wins",
	},
}

local quests: { [string]: Quest } = {
	Win1 = {
		Goal = 1,
	},
}

QuestConstants.Templates = templates
QuestConstants.Quests = quests
QuestConstants.DefaultStats = {
	Wins = 0,
	Playtime = 0,
	CoinsEarned = 0,
}

-------------------------------------------------------------------------------
-- LOGIC
-------------------------------------------------------------------------------
QuestConstants.Quests = quests

for questName, constants in pairs(quests) do
	constants.Name = questName

	local template = QuestConstants.Templates[questName:gsub("%d", "")]
	if template then
		constants.Description = constants.Description or template.Description
		constants.Stat = template.Stat
	end
end

return QuestConstants
