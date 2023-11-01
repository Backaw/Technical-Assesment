local RewardService = {}

local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local RewardConstants = require(Paths.Shared.Rewards.RewardConstants)
local CurrencyService = require(Paths.Services.CurrencyService)
local ItemService = require(Paths.Services.ItemService)

function RewardService.award(player: Player, reward: RewardConstants.Reward, source: string)
	if reward.Type == RewardConstants.Types.Currency then
		CurrencyService.transact(player, reward.Currency, reward.Amount, CurrencyService.ResourceType.Reward, source)
	elseif reward.Type == RewardConstants.Types.Item then
		ItemService.giveItem(player, reward.ItemType, reward.ItemName, reward.Loan)
	end
end

return RewardService
