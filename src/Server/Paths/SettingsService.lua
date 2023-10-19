local SettingsService = {}

local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local Remotes = require(Paths.shared.Remotes)
local Signal = require(Paths.shared.Signal)
local PlayerDataService = require(Paths.services.Data.PlayerDataService)
local SettingsConstants = require(Paths.shared.Constants.SettingsConstants)

SettingsService.optionToggled = Signal.new() -->  (player: Player, option: string, toggle: boolean)

Remotes.bindEvents({
	SettingOptionToggled = function(player: Player, option: string, toggle: boolean)
		-- RETURN: Option doesn't exist
		if not SettingsConstants.Options[option] then
			return
		end

		PlayerDataService.set(player, "Settings." .. option, toggle)
		SettingsService.optionToggled:Fire(player, option, toggle)
	end,
})

return SettingsService
