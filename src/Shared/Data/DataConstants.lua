local DataConstants = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SettingConstans = require(ReplicatedStorage.Modules.Constants.SettingsConstants)
local TableUtil = require(ReplicatedStorage.Modules.Utils.TableUtil)

DataConstants.Version = {
	Live = 1,
	QA = 1,
	Dev = 1,
}

local leaderstats: { [string]: string } = {}
local leaderboards: { [string]: { Stat: string, Formatter: ((number, boolean) -> string) | nil } } = {}

DataConstants.Leaderboards = leaderboards
DataConstants.Leaderstats = leaderstats

DataConstants.DefaultPlayerData = function()
	local store = {}

	store.Coins = 0
	store.RedeemedCodes = {}
	store.Settings = TableUtil.getProperties(SettingConstans.Options, "Default")

	store.Banned = false

	return store
end

return DataConstants
