-- All values are stored in .Stats part of a player's data
local QuestConstants = {}

export type Quest = {
	Name: string?,
	Stat: string?,
	Validator: ((table) -> number) | nil,
	Goal: number,
	Description: string?,
}

local templates = {
	Kill = {
		Description = "Kill %s people",
		Stat = "Kills",
	},
}

local quests: { [string]: Quest } = {
	Kill1 = {
		Goal = 1,
	},
}

QuestConstants.Quests = quests
QuestConstants.DefaultStats = {
	Kills = 0,
	Deaths = 0,
	Playtime = 0,
}

-------------------------------------------------------------------------------
-- LOGIC
-------------------------------------------------------------------------------
for questName, constants in pairs(quests) do
	constants.Name = questName

	local template = templates[questName:gsub("%d", "")]
	if template then
		constants.Description = constants.Description or template.Description
		constants.Stat = template.Stat
	end
end

return QuestConstants
