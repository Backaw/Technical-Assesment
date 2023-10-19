local NukeService = {}

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local Paths = require(ServerScriptService.Paths)
local Remotes = require(Paths.shared.Remotes)
local ProductService = require(Paths.services.Products.ProductService)
local ProductConstants = require(Paths.shared.Products.ProductConstants)
local CharacterUtil = require(Paths.shared.Character.CharacterUtil)
local EventConstants = require(Paths.shared.Constants.EventConstants)
local Signal = require(Paths.shared.Signal)

local debounce = false
-------------------------------------------------------------------------------
-- PUBLIC MEMBERS
-------------------------------------------------------------------------------
NukeService.NukeLaunched = Signal.new() --> (launcher : Player)

-------------------------------------------------------------------------------
-- LOGIC
-------------------------------------------------------------------------------
ProductService.registerValidator(ProductConstants.Products.Event.Nuke, function()
	return not debounce
end)

-- EVENT HANDLERS
ProductService.productPurchased:Connect(function(player: Player, product: ProductConstants.Product)
	if product == ProductConstants.Products.Event.Nuke then
		NukeService.NukeLaunched:Fire(player)

		for _, otherPlayer in pairs(Players:GetPlayers()) do
			Remotes.fireClient(otherPlayer, "NukeLaunched", player)

			if player ~= otherPlayer then
				task.delay(otherPlayer:GetNetworkPing(), function()
					CharacterUtil.kill(otherPlayer)
				end)
			end
		end

		debounce = true
		task.delay(EventConstants.Nuke.Cooldown, function()
			debounce = false
		end)
	end
end)

Remotes.declareEvent("NukeLaunched")

return NukeService
