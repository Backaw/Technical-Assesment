local HUDScreen = {}

local Players = game:GetService("Players")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local UIController = require(Paths.Controllers.UI.UIController)
local UIConstants = require(Paths.Controllers.UI.UIConstants)
local UIUtil = require(Paths.Controllers.UI.Utils.UIUtil)
local SquishyButton = require(Paths.Controllers.UI.Components.SquishyButton)

local UI_STATE = UIConstants.States.HUD

-------------------------------------------------------------------------------
-- PRIVATE MEMBERS
-------------------------------------------------------------------------------
local uiStateMachine = UIController.getStateMachine()

local screen: ScreenGui = Paths.UI.HUD

-------------------------------------------------------------------------------
-- PRIVATE METHODS
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- LOGIC
-------------------------------------------------------------------------------
-- Register state
do
	uiStateMachine:RegisterGlobalCallback(function()
		UIController.ScreenStateTransition:andThen(function()
			screen.Enabled = UIUtil.isStackHUDPermissive(uiStateMachine:GetStack())
		end)
	end)

	uiStateMachine:Push(UI_STATE)
end

return HUDScreen
