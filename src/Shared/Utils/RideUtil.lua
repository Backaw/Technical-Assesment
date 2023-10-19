local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local BasePartUtil = require(ReplicatedStorage.Modules.Utils.BasePartUtil)
local SlidingUtil = require(ReplicatedStorage.Modules.Sliding.SlidingUtil)

local RideUtil = {}

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { Workspace.Lobby, Workspace.SpawnedRides }

function RideUtil.canPlace(player: Player, cframe: CFrame, size: Vector3)
	local canPlace = false

	for _, part in pairs(Workspace:GetPartBoundsInBox(cframe, size, overlapParams)) do
		if part.Parent == Workspace.Lobby.Water then
			canPlace = true
		else
			local ride = RideUtil.getRideFromDescendant(part)
			if not ride or ride.Name ~= player.Name then
				canPlace = false
				break
			end
		end
	end

	if
		SlidingUtil.hasSlidingStarted(BasePartUtil.closestPoint({
			CFrame = cframe,
			Size = size,
		}, {
			CFrame = SlidingUtil.getEndCFrame(),
			Size = Vector3.new(1, 1, 1),
		}))
	then
		return false
	end
	return canPlace
end

function RideUtil.getRideFromDescendant(descendant: Instance): Model?
	if not descendant:IsDescendantOf(Workspace.SpawnedRides) then
		return
	end

	repeat
		descendant = descendant.Parent
	until descendant.Parent == Workspace.SpawnedRides

	return descendant
end

return RideUtil
