local DebugUtil = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MathUtil = require(ReplicatedStorage.Modules.Utils.MathUtil)

function DebugUtil.previewCFrame(cframe: CFrame, size: Vector3?, color: Color3?)
	local preview = Instance.new("WedgePart")
	preview.Size = size or Vector3.new(1, 1, 1)
	preview.CFrame = cframe
	preview.Color = color or Color3.new(255, 255, 255)
	preview.Anchored = true
	preview.CanTouch = false
	preview.CanQuery = false
	preview.CanCollide = false
	preview.Parent = workspace

	return preview
end

function DebugUtil.truncateVector3(vector: Vector3, precision: number)
	return Vector3.new(
		MathUtil.precision(vector.X, precision),
		MathUtil.precision(vector.Y, precision),
		MathUtil.precision(vector.Z, precision)
	)
end

return DebugUtil
