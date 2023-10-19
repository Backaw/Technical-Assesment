local Tooltip = {}

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local Button = require(Paths.controllers.UI.Components.Button)
local Maid = require(Paths.shared.Maid)
local DeviceUtil = require(Paths.controllers.Utils.DeviceUtil)
local UIController = require(Paths.controllers.UI.UIController)
local UIConstants = require(Paths.controllers.UI.UIConstants)

local uiStateMachine = UIController.getStateMachine()

local OFFSET = 20
local GUI_INSET_Y = GuiService:GetGuiInset().Y

-------------------------------------------------------------------------------
-- PRIVATE MEMBERS
-------------------------------------------------------------------------------
local screen: ScreenGui = Paths.ui.Tooltips

local maid = Maid.new()
local opened: Button.Button?

-------------------------------------------------------------------------------
-- PUBLIC METHODS
-------------------------------------------------------------------------------
function Tooltip.bindToButton(tooltip: GuiObject, button: Button.Button, onRendered: () -> (), uiStateDependent: true?)
	local function close()
		-- RETURN: New tooltip has opened
		if opened ~= button then
			return
		end

		maid:Cleanup()
		tooltip.Visible = false

		opened = nil
	end

	-- TODO: Add some sort of limiter
	button.hoverStarted:Connect(function()
		maid:Cleanup()
		opened = button

		onRendered()
		tooltip.Visible = true

		if DeviceUtil.isGamepadInput() then
			local guiObject = button:GetGuiObject()
			task.defer(function()
				local selectionLocation = guiObject.AbsolutePosition + guiObject.AbsoluteSize / 2
				tooltip.Position = UDim2.fromOffset(selectionLocation.X, selectionLocation.Y + GUI_INSET_Y)
			end)
		else
			-- 0.02 * screen.AbsoluteSize.Y
			maid:Add(RunService.RenderStepped:Connect(function()
				local mouseLocation = UserInputService:GetMouseLocation()
				tooltip.Position = UDim2.fromOffset(mouseLocation.X + OFFSET, mouseLocation.Y + OFFSET)
			end))
		end

		if uiStateDependent then
			maid:Add(uiStateMachine:RegisterGlobalCallback(close))
		end
	end)

	button.hoverEnded:Connect(function()
		close()
	end)
end

-------------------------------------------------------------------------------
-- LOGIC
-------------------------------------------------------------------------------
screen.Enabled = true
for _, tooltip in pairs(screen:GetChildren()) do
	tooltip.AnchorPoint = Vector2.new(0, 0)
	tooltip.Visible = false
end

return Tooltip
