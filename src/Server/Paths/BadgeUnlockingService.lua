local BadgeUnlockingService = {}

local BadgeService = game:GetService("BadgeService")
local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local PlayersService = require(Paths.Services.PlayersService)
local PlayerDataService = require(Paths.Services.Data.PlayerDataService)
local BadgeConstants = require(Paths.Shared.Constants.BadgeConstants)
local GameUtil = require(Paths.Shared.Game.GameUtil)
local QuestUtil = require(Paths.Shared.Quests.QuestUtil)

local DEBUGGING = false

-------------------------------------------------------------------------------
-- PUBLIC METHODS
-------------------------------------------------------------------------------
function BadgeUnlockingService.awardBadge(player: Player, badge: BadgeConstants.Badge)
	local id = badge.Id

	-- RETURN: Badge has already been awarded
	local address = "UnlockedBadges." .. id
	if PlayerDataService.get(player, address) then
		return
	end

	if DEBUGGING then
		print(("%s awarded %s badge"):format(player.Name, badge.Name))
	end

	if GameUtil.isLive() then
		-- Fetch badge information
		local success, badgeInfo = pcall(function()
			return BadgeService:GetBadgeInfoAsync(id)
		end)

		if success then
			-- Confirm that badge can be awarded
			if badgeInfo.IsEnabled then
				-- Award badge
				success = pcall(function()
					return BadgeService:AwardBadge(player.UserId, id)
				end)
				if not success then
					return
				end
			end
		end
	end

	PlayerDataService.set(player, address, true)
end

-------------------------------------------------------------------------------
-- LOGIC
-------------------------------------------------------------------------------
BadgeUnlockingService.loadPlayer = PlayersService.promisifyLoader(function(player)
	-- BadgeUnlockingService.awardBadge(player, BadgeConstants.Badges.Play)

	for _, badge in pairs(BadgeConstants.Badges) do
		local criteria = badge.AwardCriteria
		if criteria then
			local function checkCanAward(value: number)
				if value and value >= criteria.Goal then
					BadgeUnlockingService.awardBadge(player, badge)
					return true
				end
			end

			if not checkCanAward(PlayerDataService.get(player, QuestUtil.getStatAddress(criteria.Stat))) then
				local connection
				connection = PlayerDataService.Updated:Connect(function(event, otherPlayer, value, metadata)
					if event == "QuestStatChanged" and otherPlayer == player and metadata.Stat == criteria.Stat then
						checkCanAward(value)
						connection:Disconnect()
					end
				end)

				PlayersService.registerUnloadTask(player, connection)
			end
		end
	end
end, "Badges")

return BadgeUnlockingService
