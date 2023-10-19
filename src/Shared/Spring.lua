local Spring = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vector3Util = require(ReplicatedStorage.Modules.Utils.Vector3Util)
local MathUtil = require(ReplicatedStorage.Modules.Utils.MathUtil)

local MIN_DELTA_TIME = 0.1

type NumVect = number | Vector3

function Spring.new(position: NumVect, speed: NumVect?, mass: NumVect?, force: NumVect?, damping: NumVect?)
	local spring = {}

	-------------------------------------------------------------------------------
	-- PRIVATE MEMBERS
	-------------------------------------------------------------------------------
	speed = speed or 1
	mass = mass or 1
	force = force or 50
	damping = damping or 2

	local velocity: NumVect

	-------------------------------------------------------------------------------
	-- PUBLIC METHODS
	-------------------------------------------------------------------------------
	function spring:Reset(newPosition: NumVect)
		position = newPosition
		velocity = if typeof(newPosition) == "number" then 0 else Vector3.new()
	end

	function spring:Set(newPosition: NumVect)
		position = newPosition
	end

	function spring:Get(): NumVect
		return position
	end

	function spring:Impuse(impulse: NumVect)
		position = position + if typeof(impulse) == "number" then MathUtil.ifNanThen0(impulse) else Vector3Util.ifNanThen0(impulse)
	end

	function spring:Hasten(newSpeed: NumVect)
		speed = newSpeed
	end

	function spring:Update(target: NumVect, dt: number)
		local scaledSpeed = speed * dt
		local scaledDeltaTime = if typeof(speed) == "Vector3"
			then Vector3.new(
				math.min(scaledSpeed.Y, MIN_DELTA_TIME),
				math.min(scaledSpeed.Y, MIN_DELTA_TIME),
				math.min(scaledSpeed.Z, MIN_DELTA_TIME)
			)
			else math.min(scaledSpeed, MIN_DELTA_TIME)

		local impulse = target - position
		local acceleration = (impulse * force) / mass

		acceleration = acceleration - velocity * damping

		velocity = velocity + acceleration * scaledDeltaTime
		position = position + velocity * scaledDeltaTime

		return position
	end

	-------------------------------------------------------------------------------
	-- LOGIC
	-------------------------------------------------------------------------------
	spring:Reset(position)

	return spring
end

return Spring
