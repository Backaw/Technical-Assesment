local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RewardUtil = {}

local RewardConstants = require(ReplicatedStorage.Modules.Rewards.RewardConstants)
local StringUtil = require(ReplicatedStorage.Modules.Utils.StringUtil)
local ItemConstants = require(ReplicatedStorage.Modules.Items.ItemConstants)
local Images = require(ReplicatedStorage.Modules.Images)

local REWARD_TYPES = RewardConstants.Types

function RewardUtil.getIcon(reward: RewardConstants.Reward)
	local rewardType = reward.Type
	return if rewardType == REWARD_TYPES.Cash
		then Images.Currencies.Cash
		elseif rewardType == REWARD_TYPES.Item then ItemConstants.Items[reward.ItemType][reward.ItemName].Icon
		else ""
end

function RewardUtil.getDescription(reward: RewardConstants.Reward)
	local rewardType = reward.Type
	return if rewardType == REWARD_TYPES.Cash
		then StringUtil.commafiedNumber(reward.Amount) .. " cash"
		elseif rewardType == REWARD_TYPES.Item then ("%s %s"):format(StringUtil.seperateSnakeCase(reward.ItemName), reward.ItemType)
		else ""
end

return RewardUtil
