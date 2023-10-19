local Component = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Modules.Maid)

export type Component = typeof(Component.new())

function Component.new()
	local component = {}

	-------------------------------------------------------------------------------
	-- PRIVATE VARIABLES
	-------------------------------------------------------------------------------
	local maid = Maid.new()

	-------------------------------------------------------------------------------
	-- PUBLIC METHODS
	-------------------------------------------------------------------------------
	function component:GetMaid(): Maid.Maid
		return maid
	end

	function component:Destroy()
		maid:Destroy()
	end

	return component
end

return Component
