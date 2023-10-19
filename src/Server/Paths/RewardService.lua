local RewardService = {}

local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local RewardConstants = require(Paths.shared.Rewards.RewardConstants)
local CoinService = require(Paths.services.CoinService)
local ItemService = require(Paths.services.ItemService)

function RewardService.award(player: Player, reward: RewardConstants.Reward, source: string)
	if reward.Type == RewardConstants.Types.Coin then
		CoinService.transact(player, reward.Amount, CoinService.ResourceType.Reward, source)
	elseif reward.Type == RewardConstants.Types.Item then
		ItemService.giveItem(player, reward.ItemType, reward.ItemName, reward.Loan)
	end
end

return RewardService
