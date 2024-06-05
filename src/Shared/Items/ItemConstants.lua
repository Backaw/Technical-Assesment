local ItemConstants = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyConstants = require(ReplicatedStorage.Modules.Currency.CurrencyConstants)
local QuestConstants = require(ReplicatedStorage.Modules.Quests.QuestConstants)

export type ItemSource = CurrencyConstants.Price | { Level: number } | nil | QuestConstants.Quest

export type Item = {
	Name: string,
	Alias: string?,
	Type: string,
	Icon: string,
	Source: ItemSource,
}

ItemConstants.Types = {}

ItemConstants.FriendlyTypeNames = {}

return ItemConstants
