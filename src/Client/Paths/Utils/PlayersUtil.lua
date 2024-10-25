local PlayersUtil = {}

local Players = game:GetService("Players")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local Maid = require(Paths.Shared.Maid)
local InstanceUtil = require(Paths.Shared.Utils.InstanceUtil)
local CharacterUtil = require(Paths.Shared.Character.CharacterUtil)

function PlayersUtil.loadPlayers(playerHandler: (player: Player, maid: Maid.Maid) -> (((Model) -> ())?, ((Model) -> ())?))
	local maid = Maid.new()

	local function loadPlayer(player)
		local playerMaid = Maid.new()
		local playerMaidTask = maid:Add(playerMaid)

		local characterLoadHandler, characteUnloadHandler = playerHandler(player, playerMaid)

		local function loadCharacter()
			playerMaid:RemoveIfExits("Death")

			-- RETURN: Character doesn't exist
			if not CharacterUtil.isAlive(player) then
				return
			end

			local character = player.Character
			if characterLoadHandler then
				characterLoadHandler(character)
			end

			playerMaid:Add(
				character:WaitForChild("Humanoid").Died:Connect(function()
					if characteUnloadHandler then
						characteUnloadHandler(character)
					end
				end),
				"Death"
			)
		end

		loadCharacter()
		playerMaid:Add(player.CharacterAdded:Connect(loadCharacter))

		playerMaid:Add(InstanceUtil.onDestroyed(player, function()
			maid:Remove(playerMaidTask)
		end))
	end

	maid:Add(Players.PlayerAdded:Connect(loadPlayer))
	for _, player in pairs(Players:GetPlayers()) do
		loadPlayer(player)
	end

	return maid
end

function PlayersUtil.getThumbnail(player: Player)
	local success, result =
		pcall(Players.GetUserThumbnailAsync, Players, player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	return if success then result else ""
end

return PlayersUtil
