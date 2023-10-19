local DataController = {}

local Players = game:GetService("Players")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local Signal = require(Paths.shared.Signal)
local Promise = require(Paths.shared.Packages.Promise)
local Remotes = require(Paths.shared.Remotes)
local DataUtil = require(Paths.shared.Data.DataUtil)

local bank: DataUtil.Store = {}
DataController.updated = Signal.new() -- {event: string, newValue: any, eventMeta: table?}

-- We use addresses on client too only bc it's convinient to copy same addresses as client
function DataController.get(address: string)
	local value = DataUtil.getFromAddress(bank, address)
	return value
end

local loader = Promise.new(function(resolve)
	local cleanup
	cleanup = Remotes.bindEventTemp("DataInitialized", function(data)
		bank = data
		warn("PLAYER DATA", bank)

		cleanup()
		resolve()
	end)

	Remotes.fireServer("ClientReadyForData")
end)

Remotes.bindEvents({
	DataUpdated = function(address: string, newValue: any, event: string?, eventMeta: table?)
		loader:andThen(function() --- Ensures data has loaded before any changes are made, just in case
			DataUtil.setFromAddress(bank, address, newValue)
			if event then
				DataController.updated:Fire(event, newValue, eventMeta or {})
			end
		end)
	end,
})

-- Yield initialization of other modules
loader:await()

return DataController
