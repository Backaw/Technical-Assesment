local GameAnalyticsService = {}

local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local GameAnalytics = require(Paths.shared.Packages.GameAnalytics)
local GameConstants = require(Paths.shared.Game.GameConstants)
local ProductUtil = require(Paths.shared.Products.ProductUtil)
local TableUtil = require(Paths.shared.Utils.TableUtil)
local PlayersService = require(Paths.services.PlayersService)
local CoinService = require(Paths.services.CoinService)
local GameUtil = require(Paths.shared.Game.GameUtil)

local DEBUGGING = false

local IS_LIVE = GameUtil.isLive()
local IS_TRACKING = false and (RunService:IsStudio() or IS_LIVE)

local onPlayerReady: BindableEvent = game:GetService("ReplicatedStorage"):WaitForChild("OnPlayerReadyEvent")

function GameAnalyticsService.addEvent(eventType: string, playerId: number, options: table)
	if IS_TRACKING then
		task.spawn(function()
			if not GameAnalytics:isPlayerReady(playerId) then
				repeat
					onPlayerReady.Event:Wait()
				until GameAnalytics:isPlayerReady(playerId)
			end

			GameAnalytics["add" .. eventType](GameAnalytics, playerId, options)
		end)
	end
end

GameAnalyticsService.loadPlayer = PlayersService.promisifyLoader(function(player: Player)
	if IS_TRACKING then
		GameAnalytics:PlayerJoined(player)
		PlayersService.registerUnloadTask(player, function()
			GameAnalytics:PlayerRemoved(player)
		end)
	end
end, "GameAnalytics")

function GameAnalyticsService.init()
	if IS_TRACKING then
		GameAnalytics:initialize({
			build = GameConstants.Version,

			gameKey = "",
			secretKey = "",

			enableInfoLog = false,
			enableVerboseLog = false,

			--debug is by default enabled in studio only
			enableDebugLog = DEBUGGING,

			automaticSendBusinessEvents = true,
			reportErrors = true,

			availableResourceCurrencies = { "Coin" },
			availableResourceItemTypes = CoinService.getResourceTypes(),
			availableGamepasses = TableUtil.getKeys(ProductUtil.getGamepassProducts()),
		})
	end
end

return GameAnalyticsService
