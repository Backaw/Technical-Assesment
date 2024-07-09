local DebugUtil = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MathUtil = require(ReplicatedStorage.Modules.Utils.MathUtil)

function DebugUtil.previewCFrame(cframe: CFrame, size: Vector3?, color: Color3?, instance: string?)
	local preview = Instance.new(instance or "WedgePart")
	preview.Size = size or Vector3.new(1, 1, 1)
	preview.CFrame = cframe
	preview.Color = color or Color3.fromRGB(0, 0, 0)
	preview.Anchored = true
	preview.CanTouch = false
	preview.CanQuery = false
	preview.CanCollide = false
	preview.Parent = workspace

	return preview
end

function DebugUtil.pointerGizmo(parent: BasePart, color: Color3?, length: number?)
	local gizmo = Instance.new("LineHandleAdornment") -- Points in direction of velocity
	gizmo.Adornee = parent
	gizmo.AlwaysOnTop = true
	gizmo.Color3 = color or Color3.fromRGB(0, 180, 255)
	gizmo.Parent = parent
	gizmo.Thickness = 3
	gizmo.Length = length or 5
	gizmo.Visible = true

	return gizmo
end

function DebugUtil.truncateVector3(vector: Vector3, precision: number)
	return Vector3.new(
		MathUtil.precision(vector.X, precision),
		MathUtil.precision(vector.Y, precision),
		MathUtil.precision(vector.Z, precision)
	)
end

return DebugUtil
