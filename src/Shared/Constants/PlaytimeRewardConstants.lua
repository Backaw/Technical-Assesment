local PlaytimeRewardConstants = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RewardConstants = require(ReplicatedStorage.Modules.Rewards.RewardConstants)

local rewards: {
	{
		Reward: RewardConstants.Reward,
		Requirement: number,
	}
} = {}

PlaytimeRewardConstants.Rewards = rewards

return PlaytimeRewardConstants
