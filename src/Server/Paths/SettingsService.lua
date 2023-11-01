local SettingsService = {}

local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local Remotes = require(Paths.Shared.Remotes)
local Signal = require(Paths.Shared.Signal)
local PlayerDataService = require(Paths.Services.Data.PlayerDataService)
local SettingsConstants = require(Paths.Shared.Constants.SettingsConstants)

SettingsService.OptionToggled = Signal.new() -->  (player: Player, option: string, toggle: boolean)

Remotes.bindEvents({
	SettingOptionToggled = function(player: Player, option: string, toggle: boolean)
		-- RETURN: Option doesn't exist
		if not SettingsConstants.Options[option] then
			return
		end

		PlayerDataService.set(player, "Settings." .. option, toggle)
		SettingsService.OptionToggled:Fire(player, option, toggle)
	end,
})

return SettingsService
