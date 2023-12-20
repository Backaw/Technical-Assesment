local ReplicatedStorage = game:GetService("ReplicatedStorage")
--[[
    Wrapper for a boolean variable that manages potentially conflicting value changes.

    Example:
        local toggle = Toggle.new(true)

        toggle:Set(false, "a")
        print(toggle:Get()) -- false
        toggle:Set(false, "b")
        print(toggle:Get()) -- false
        toggle:Set(true, "a")
        print(toggle:Get()) -- false
        toggle:Set(true, "b")
        print(toggle:Get()) -- true

]]

local Toggle = {}

local Signal = require(ReplicatedStorage.Modules.Signal)

function Toggle.new(initialValue: boolean)
	local toggle = {}

	-------------------------------------------------------------------------------
	-- PRIVATE MEMBERS
	-------------------------------------------------------------------------------
	local jobs: { any } = {}
	local value = initialValue

	-------------------------------------------------------------------------------
	-- PUBLIC MEMBERS
	-------------------------------------------------------------------------------
	toggle.Changed = Signal.new() --> (newValue : boolean)

	-------------------------------------------------------------------------------
	-- PUBLIC METHODS
	-------------------------------------------------------------------------------
	--[[
        Change the value, if flipping back the value to the initial value, all jobs must agree
        RETURNS: Whether or not value was changed
    ]]
	function toggle:Set(job: any, newValue: boolean)
		local changed = false

		if newValue ~= initialValue then
			-- RETURN: Job already exists
			if table.find(jobs, job) then
				return
			end

			if value ~= newValue then
				value = not initialValue
				changed = true

				toggle.Changed:Fire(newValue)
			end

			table.insert(jobs, job)
		else
			local jobIndex = table.find(jobs, job)
			-- RETURN: Job doesn't exist
			if not jobIndex then
				return
			end

			table.remove(jobs, jobIndex)

			if #jobs == 0 then
				value = initialValue
				changed = true

				toggle.Changed:Fire(newValue)
			end
		end

		return changed
	end

	function toggle:RemoveJob(job: any)
		if table.find(jobs, job) then
			toggle:Set(job, not value)
		end
	end

	function toggle:ForceSet(newValue)
		toggle.Changed:Fire(newValue)

		jobs = {}
		value = newValue
	end

	function toggle:ForceSetQuiet(newValue)
		jobs = {}
		value = newValue
	end

	function toggle:Get(): boolean
		return value
	end

	function toggle:GetJobs()
		return jobs
	end

	return toggle
end

return Toggle
