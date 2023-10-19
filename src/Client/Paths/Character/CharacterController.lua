local CharacterController = {}

local Players = game:GetService("Players")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local CharacterUtil = require(Paths.shared.Character.CharacterUtil)
local TransitionController = require(Paths.controllers.UI.Transitions.TransitionController)
local CameraController = require(Paths.controllers.CameraController)
local UIController = require(Paths.controllers.UI.UIController)
local InstanceUtil = require(Paths.shared.Utils.InstanceUtil)
local UIConstants = require(Paths.controllers.UI.UIConstants)

local RESPAWN_TIME = Players.RespawnTime

-------------------------------------------------------------------------------
-- PRIVATE MEMBERS
-------------------------------------------------------------------------------
local player = Players.LocalPlayer

-------------------------------------------------------------------------------
-- PRIVATE METHODS
-------------------------------------------------------------------------------
local function loadCharacter(character: Model?)
	if character then
		UIController.resetToHUD({ UIConstants.States.Reward })

		CharacterUtil.safeInvokeHandler(CameraController.loadCharacter, character)

		local alive = true
		local function onDeath()
			if not alive then
				return
			end
			alive = false

			player.Character = nil :: Model

			task.wait(RESPAWN_TIME * 0.75)
			TransitionController.open("CharacterSpawning", "Wipe")
		end
		InstanceUtil.onDestroyed(character:WaitForChild("HumanoidRootPart"), onDeath)
		character:WaitForChild("Humanoid").Died:Connect(onDeath)
	end

	TransitionController.close("CharacterSpawning")
end

-------------------------------------------------------------------------------
-- PUBLIC METHODS
-------------------------------------------------------------------------------
function CharacterController.kill()
	CharacterUtil.kill(player)
end

-- Not for spawning standing on something
function CharacterController.teleportTo(spawnPoint: CFrame)
	TransitionController.play("Teleporting", "Eye", function()
		if CharacterUtil.isAlive(player) then
			local character: Model = player.Character
			character:PivotTo(spawnPoint)

			CameraController.lookForward()
			UIController.resetToHUD()

			local humanoid: Humanoid = character:WaitForChild("Humanoid")
			if humanoid:GetState() == Enum.HumanoidStateType.Seated then
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end
	end)
end

-------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------
function CharacterController.start()
	loadCharacter(player.Character)
	player.CharacterAdded:Connect(loadCharacter)
end

return CharacterController
