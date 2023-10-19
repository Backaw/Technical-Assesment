local Vector3Util = {}

local AXIIS = { X = true, Y = true, Z = true }

function Vector3Util.ifNanThen0(vector: Vector3): Vector3
	local x, y, z = vector.X, vector.Y, vector.Z
	if x ~= x or x == math.huge or x == -math.huge then
		x = 0
	end
	if y ~= y or y == math.huge or y == -math.huge then
		y = 0
	end
	if z ~= z or z == math.huge or z == -math.huge then
		z = 0
	end

	return Vector3.new(x, y, z)
end

function Vector3Util.getUnit(vector: Vector3)
	return Vector3Util.ifNanThen0(vector.Unit)
end

function Vector3Util.max(vector1: Vector3, vector2: Vector3): Vector3
	return Vector3.new(math.max(vector1.X, vector2.X), math.max(vector1.Y, vector2.Y), math.max(vector1.Z, vector2.Z))
end

function Vector3Util.abs(vector: Vector3): Vector3
	return Vector3.new(math.abs(vector.X), math.abs(vector.Y), math.abs(vector.Z))
end

function Vector3Util.sign(vector: Vector3): Vector3
	return Vector3.new(math.sign(vector.X), math.sign(vector.Y), math.sign(vector.Z))
end

function Vector3Util.floor(vector: Vector3)
	return Vector3.new(math.floor(vector.X), math.floor(vector.Y), math.floor(vector.Z))
end

function Vector3Util.average(vectors: { Vector3 }): Vector3
	local sum = Vector3.new()
	for _, vector in vectors do
		sum += vector
	end
	local count = #vectors
	return if count == 0 then sum else sum / count
end

function Vector3Util.maxComponent(vector: Vector3): number
	return math.max(vector.X, vector.Y, vector.Z)
end

function Vector3Util.isPointInBounds(point: Vector3, boundsPosiiton: Vector3, boundsSize: Vector3): boolean
	boundsSize /= 2
	return (point.X <= boundsPosiiton.X + boundsSize.X and point.X >= boundsPosiiton.X - boundsSize.X)
		and (point.Y <= boundsPosiiton.Y + boundsSize.Y and point.Y >= boundsPosiiton.Y - boundsSize.Y)
		and (point.Z <= boundsPosiiton.Z + boundsSize.Z and point.Z >= boundsPosiiton.Z - boundsSize.Z)
end

function Vector3Util.getImpactInDirection(vector: Vector3, direction: Vector3): Vector3
	local magnitude = vector:Dot(direction) / direction.Magnitude
	return Vector3Util.ifNanThen0(direction.Unit * magnitude)
end

function Vector3Util.forEveryAxis(callback: (string) -> ())
	for axis in pairs(AXIIS) do
		callback(axis)
	end
end

return Vector3Util
