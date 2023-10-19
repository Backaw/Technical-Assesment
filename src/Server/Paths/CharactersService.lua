local CharactersService = {}

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Paths = require(ServerScriptService.Paths)
local PlayersService = require(Paths.services.PlayersService)
local Permissions = require(Paths.shared.Permissions)
local CharacterUtil = require(Paths.shared.Character.CharacterUtil)
local CharacterConstants = require(Paths.shared.Character.CharacterConstants)

-------------------------------------------------------------------------------
-- PRIVATE METHODS
-------------------------------------------------------------------------------
local function loadCharacter(character: Model)
	if not character then
		return
	end

	local player = Players:GetPlayerFromCharacter(character)

	local humanoid: Humanoid = character.Humanoid
	humanoid.WalkSpeed = CharacterConstants.WalkSpeed
	humanoid.Died:Connect(function()
		-- Unload handlers
	end)

	task.spawn(function()
		local prefix = ""
		if Permissions.isTester(player) then
			prefix = "🧪 "
		elseif Permissions.isAdmin(player) then
			prefix = "⚒️ "
		end

		local nametag: BillboardGui = ServerStorage.Nametag:Clone()
		nametag.Parent = character.Head
		nametag.TextLabel.Text = prefix .. player.DisplayName

		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end)

	repeat
		task.wait()
	until character.Parent

	-- Handlers
end

-------------------------------------------------------------------------------
-- PUBLIC METHODS
-------------------------------------------------------------------------------
CharactersService.loadPlayer = PlayersService.promisifyLoader(function(player)
	loadCharacter(player.Character)
	player.CharacterAdded:Connect(loadCharacter)
end, "character")

return CharactersService
