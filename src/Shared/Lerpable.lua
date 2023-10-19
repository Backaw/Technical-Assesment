local Lerpable = {}

function Lerpable.new<T>(value: T, speed: T?, onUpdate: (T, T) -> ()?)
	local lerpable = {}

	local initialValue = value
	local target = value

	local function alert(lastValue)
		if onUpdate then
			onUpdate(value, lastValue)
		end
	end

	function lerpable:Set(new: T): T
		local lastValue = value

		lerpable:SetTarget(new)
		value = new

		alert(lastValue)
		return value
	end

	function lerpable:Get(): T
		return value
	end

	function lerpable:Reset(): T
		local lastValue = value
		value = initialValue

		alert(lastValue)
		return value
	end

	function lerpable:GetTarget(): T
		return target
	end

	function lerpable:SetTarget(newTarget: T): T
		target = newTarget
	end

	function lerpable:Update(dt: T): T
		local lastValue = value
		value += (target - value) * dt * speed
		alert(lastValue)

		return value
	end

	function lerpable:OnUpdate(newHandler: (T) -> ())
		onUpdate = newHandler
	end

	return lerpable
end

return Lerpable
