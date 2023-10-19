local PlaytimeRewardService = {}

local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local PlayersService = require(Paths.services.PlayersService)
local RewardService = require(Paths.services.RewardService)
local Remotes = require(Paths.shared.Remotes)
local PlaytimeRewardConstants = require(Paths.shared.Constants.PlaytimeRewardConstants)

-------------------------------------------------------------------------------
-- PRIVATE MEMBERS
-------------------------------------------------------------------------------
local claimInfo: { [Player]: {
	JoinTime: number,
	ClaimedRewards: { number },
}? } = {}

-------------------------------------------------------------------------------
-- PRIVATE MEMBERS
-------------------------------------------------------------------------------
PlaytimeRewardService.loadPlayer = PlayersService.promisifyLoader(function(player)
	claimInfo[player] = {
		JoinTime = os.time(),
		ClaimedRewards = {},
	}

	PlayersService.registerUnloadTask(player, function()
		claimInfo[player] = nil
	end)
end, "PlaytimeRewardService")

-------------------------------------------------------------------------------
-- LOGIC
-------------------------------------------------------------------------------
Remotes.bindEvents({
	PlaytimeRewardClaimed = function(player: Player, index: number)
		local info = claimInfo[player]

		-- RETURN: Player has already claimed this reward
		if table.find(info.ClaimedRewards, index) then
			return
		end

		-- RETURN: Not time to claim yet
		local constants = PlaytimeRewardConstants.Rewards[index]
		if constants.Requirement > os.time() - info.JoinTime then
			return
		end

		RewardService.award(player, constants.Reward, "PlaytimeReward")
		table.insert(info.ClaimedRewards, index)
	end,
})

return PlaytimeRewardService
