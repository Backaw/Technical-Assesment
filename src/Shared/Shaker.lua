local Shaker = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenableValue = require(ReplicatedStorage.Modules.TweenableValue)

type NumVect = number | Vector3
export type Shaker = typeof(Shaker.new())

Shaker.Defaults = {
	Speed = 10,
	Magnitude = 1.5,
	RotationalMagnitude = 0.8,
	DecaySpeed = 3,
	BuildTweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
}

function Shaker.new(speed: NumVect?, magnitude: NumVect?, rotationalMagnitude: NumVect?, decaySpeed: number?, buildTweenInfo: TweenInfo?)
	local shaker = {}

	-------------------------------------------------------------------------------
	-- PRIVATE MEMBERS
	-------------------------------------------------------------------------------
	speed = speed or Shaker.Defaults.Speed
	magnitude = magnitude or Shaker.Defaults.Magnitude
	rotationalMagnitude = rotationalMagnitude or Shaker.Defaults.RotationalMagnitude
	decaySpeed = decaySpeed or Shaker.Defaults.DecaySpeed
	buildTweenInfo = buildTweenInfo or Shaker.Defaults.BuildTweenInfo

	local et = 0
	local factor = TweenableValue.new("NumberValue", 0, buildTweenInfo)
	local totalOffset: CFrame = CFrame.new()

	-------------------------------------------------------------------------------
	-- PRIVATE METHODS
	-------------------------------------------------------------------------------
	local function getPerlinValue(id: number)
		return math.clamp(math.noise(id, et, 10), -1, 1)
	end

	-------------------------------------------------------------------------------
	-- PUBLIC METHODS
	-------------------------------------------------------------------------------
	function shaker:Update(dt: number): CFrame
		local offset: CFrame
		local factorValue = factor:Get()
		if factorValue ~= 0 then
			et += dt * math.pow(factorValue, 1 / 2) * speed

			-- Bind movement to the desired range
			local positionalOffset = CFrame.new(Vector3.new(getPerlinValue(1), getPerlinValue(50), 0) * magnitude * factorValue)
			local rotationalOffset = CFrame.fromEulerAnglesXYZ(
				math.rad(positionalOffset.X * rotationalMagnitude),
				math.rad(positionalOffset.X * rotationalMagnitude),
				math.rad(positionalOffset.Y * rotationalMagnitude)
			)

			offset = positionalOffset * rotationalOffset
			totalOffset *= offset

			if not factor:IsPlaying() then
				factor:Set(math.max(0, factorValue - dt * decaySpeed))
			end
		else
			-- Reset camera to original state
			local newTotalOffset = totalOffset:Lerp(CFrame.new(), dt * 1.5)
			offset = totalOffset:ToObjectSpace(newTotalOffset)
			totalOffset = newTotalOffset
		end

		return offset
	end

	function shaker:Impulse(factorGoal: number): Tween
		return factor:Haste(factorGoal, buildTweenInfo.Time * factorGoal)
	end

	function shaker:Reset()
		factor:Reset()
	end

	return shaker
end

return Shaker
