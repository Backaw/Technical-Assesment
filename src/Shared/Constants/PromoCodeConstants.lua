local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PromoCodeConstants = {}

local RewardConstants = require(ReplicatedStorage.Modules.Rewards.RewardConstants)

PromoCodeConstants.State = {
	DoesNotExist = "Invalid Code",
	UsedAlready = "Code already redeemed",
	Success = "Successfuly redeemed",
	Expired = "Code has expired",
}

local codes: { [string]: { BestBy: number, Reward: RewardConstants.Reward } } = {}

PromoCodeConstants.Codes = codes

return PromoCodeConstants
