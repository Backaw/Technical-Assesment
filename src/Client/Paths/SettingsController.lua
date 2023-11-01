local SettingsController = {}

local Players = game:GetService("Players")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local DataController = require(Paths.Controllers.DataController)
local SettingsConstants = require(Paths.Shared.Constants.SettingsConstants)
local Remotes = require(Paths.Shared.Remotes)
local Signal = require(Paths.Shared.Signal)
local Limiter = require(Paths.Shared.Limiter)

SettingsController.OptionToggled = Signal.new() -- (option : string, value : boolean)

local cache = DataController.get("Settings") :: { [string]: boolean }

local function isOptionValid(option: SettingsConstants.Option)
	if not SettingsConstants.Options[option.Name] then
		error(("%s is an invalid setting option"):format(option.Name))
	end
end

function SettingsController.get(option: SettingsConstants.Option)
	isOptionValid(option)
	return cache[option.Name]
end

function SettingsController.set(option: SettingsConstants.Option, value: boolean)
	isOptionValid(option)

	cache[option.Name] = value
	SettingsController.OptionToggled:Fire(option, cache[option.Name])

	Limiter.indecisive("ServerSettingToggling", option.Name, 0.2, function()
		Remotes.fireServer("SettingOptionToggled", option.Name, value)
	end)
end

function SettingsController.onOptionToggled(option: SettingsConstants.Option, handler: (boolean) -> ())
	handler(SettingsController.get(option))
	return SettingsController.OptionToggled:Connect(function(toggledOption, toggle)
		if toggledOption == option then
			handler(toggle)
		end
	end)
end

function SettingsController.flip(option: SettingsConstants.Option)
	local value = not SettingsController.get(option)
	SettingsController.set(option, value)
	return value
end

return SettingsController
