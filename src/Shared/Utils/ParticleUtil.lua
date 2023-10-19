local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ParticleUtil = {}

local assets = ReplicatedStorage.Assets.Particles

export type Particles = { [string]: ParticleEmitter }

local sharedPart = Instance.new("Part")
sharedPart.Name = "ParticleSharedPart"
sharedPart.Position = Vector3.new()
sharedPart.Anchored = true
sharedPart.Transparency = 1
sharedPart.CanCollide = false
sharedPart.Anchored = true
sharedPart.Parent = Workspace

function ParticleUtil.getTemplate(name: string)
	return assets[name]
end

-- Create particles from the template
function ParticleUtil.fromTemplate(name: string)
	local particles: Particles = {}

	for _, particle in pairs(ParticleUtil.getTemplate(name):GetDescendants()) do
		if particle:IsA("ParticleEmitter") then
			particles[particle.Name] = particle:Clone()
		end
	end

	return particles
end

function ParticleUtil.cloneTemplate(name: string, parent: Instance)
	local particles = {}

	local clones = ParticleUtil.getTemplate(name):Clone()
	for _, descendant in pairs(clones:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			particles[descendant.Name] = descendant
		end
	end

	for _, child in pairs(clones:GetChildren()) do
		child.Parent = parent
	end
	clones:Destroy()

	return particles
end

function ParticleUtil.parentToAttachment(particles: Particles, parent: BasePart?)
	local attachment = Instance.new("Attachment")
	attachment.Parent = parent or sharedPart

	ParticleUtil.parentTo(particles, attachment)

	return attachment
end

function ParticleUtil.parentTo(particles: Particles, parent: Instance)
	for _, particle in pairs(particles) do
		particle.Parent = parent
	end
end

function ParticleUtil.emit(particles: Particles, particleCount: number | { [string]: number }, parentPosition: Vector3?)
	if parentPosition then
		local parent
		for _, particle in pairs(particles) do
			parent = particle.Parent
			break
		end

		if parent:IsA("Attachment") then
			parent.WorldPosition = parentPosition
		else
			parent.Position = parentPosition
		end
	end

	if typeof(particleCount) == "table" then
		for name, count in pairs(particleCount) do
			if name ~= "All" and not particles[name] then
				warn(("Can't emit %s %s bc it doesn't exist in the particle bundle"):format(name, count))
			end
		end

		for _, particle in pairs(particles) do
			particle:Emit(particleCount[particle.Name] or particleCount.All or 0)
		end
	else
		for _, particle in pairs(particles) do
			particle:Emit(particleCount)
		end
	end
end

function ParticleUtil.toggleEnabled(particles: Particles, enabled: boolean)
	for _, particle in pairs(particles) do
		particle.Enabled = enabled
	end
end

function ParticleUtil.scale(particles: Particles | { ParticleEmitter }, scale: number)
	for _, particle in pairs(particles) do
		local sizeKeypoints = {}
		for _, keypoint in pairs(particle.Size.Keypoints) do
			table.insert(
				sizeKeypoints,
				NumberSequenceKeypoint.new(keypoint.Time, math.abs(keypoint.Value * scale), math.abs(keypoint.Envelope * scale))
			)
		end

		local squashKeypoints = {}
		for _, keypoint in pairs(particle.Squash.Keypoints) do
			table.insert(
				squashKeypoints,
				NumberSequenceKeypoint.new(keypoint.Time, math.abs(keypoint.Value * scale), math.abs(keypoint.Envelope * scale))
			)
		end

		particle.Size = NumberSequence.new(sizeKeypoints)
		particle.Squash = NumberSequence.new(squashKeypoints)
		local speed = particle.Speed
		particle.Speed = NumberRange.new(speed.Min * scale, speed.Max * scale)
	end
end

return ParticleUtil
