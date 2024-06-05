local RewardService = {}

local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local RewardConstants = require(Paths.Shared.Rewards.RewardConstants)
local CurrencyService = require(Paths.Services.CurrencyService)
local ItemService: typeof(require(Paths.Services.ItemService))
local BoostService = require(Paths.Services.BoostService)

function RewardService.award(player: Player, reward: RewardConstants.Reward, source: string, clientInitiated: boolean?)
	if reward.Type == RewardConstants.Types.Currency then
		CurrencyService.transact(player, reward.Currency, reward.Amount, CurrencyService.ResourceType.Reward, source, clientInitiated)
	elseif reward.Type == RewardConstants.Types.Item then
		ItemService.giveItem(player, reward.ItemType, reward.ItemName, reward.Loan)
	elseif reward.Type == RewardConstants.Types.Boost then
		BoostService.createBoost(player, reward.Name, reward.LengthInMinutes)
	end
end

function RewardService.init()
	ItemService = require(Paths.Services.ItemService)
end

return RewardService
