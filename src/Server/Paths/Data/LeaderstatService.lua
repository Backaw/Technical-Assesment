local LeaderstatService = {}

local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local PlayerDataService = require(Paths.services.Data.PlayerDataService)
local PlayersService = require(Paths.services.PlayersService)
local DataConstants = require(Paths.shared.Data.DataConstants)
local QuestUtil = require(Paths.shared.Quests.QuestUtil)
local TableUtil = require(Paths.shared.Utils.TableUtil)
local QuestConstants = require(Paths.shared.Quests.QuestConstants)

-------------------------------------------------------------------------------
-- PRIVATE MEMBERS
-------------------------------------------------------------------------------
local statToLeaderstat = TableUtil.flipKeyValuePairs(DataConstants.Leaderstats)

-------------------------------------------------------------------------------
-- PUBLIC METHODS
-------------------------------------------------------------------------------
function LeaderstatService.createValue(player: Player, name: string, value: number)
	local instance = Instance.new("IntValue")
	instance.Name = name
	instance.Value = value
	instance.Parent = player.leaderstats
end

LeaderstatService.loadPlayer = PlayersService.promisifyLoader(function(player: Player)
	local folder = Instance.new("Folder")
	folder.Name = "leaderstats"
	folder.Parent = player

	for leaderstat, statToTrack in pairs(DataConstants.Leaderstats) do
		LeaderstatService.createValue(player, leaderstat, PlayerDataService.get(player, QuestUtil.getStatAddress(statToTrack)))
	end
end, "leaderstats")

-------------------------------------------------------------------------------
-- LOGIC
-------------------------------------------------------------------------------
PlayerDataService.updated:Connect(function(event, player, value, metadata)
	if event == "QuestStatChanged" then
		local leaderstat = statToLeaderstat[metadata.Stat]
		if leaderstat then
			player.leaderstats[leaderstat].Value = value
		end
	end
end)

return LeaderstatService
