local Paths = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LoadingController = require(script.LoadingController)
local GameConstants = require(ReplicatedStorage.Modules.Game.GameConstants)

local INITIALIZING = {
	-- Controllers
	script.ProductController,
	script.CoreGuiController,
	script.Cmdr.CmdrController,
	script.UnitTestingController,
	script.SoundController,
	script.ItemController,
	script.LeaderboardController,
	script.InteractionController,

	-- UI
	script.UI.UIScaleController,
	script.UI.UIController,

	-- Analytics
	script.Parent:WaitForChild("GameAnalyticsClient"),
}

Paths.controllers = script
Paths.shared = ReplicatedStorage.Modules
Paths.assets = ReplicatedStorage.Assets
Paths.ui = Players.LocalPlayer.PlayerGui
Paths.initialized = LoadingController.loaded

task.defer(function()
	local ping = os.clock()

	require(script.DataController)

	for _, moduleScript in pairs(INITIALIZING) do
		LoadingController.addTask(moduleScript.Name .. "_Init", function()
			local module = require(moduleScript)

			if module.init then
				module.init()
			end
		end)
	end

	for _, moduleScript in pairs(INITIALIZING) do
		LoadingController.addTask(moduleScript.Name .. "_Start", function()
			task.spawn(function()
				local module = require(moduleScript)
				if module.start then
					module.start()
				end
			end)
		end)
	end

	Paths.initialized:andThen(function()
		print(string.format("✅ Client loaded in %.6f seconds (v%s)", os.clock() - ping, GameConstants.Version))
	end)

	LoadingController.start()
end)
return Paths
