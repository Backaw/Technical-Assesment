local Button = {}

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local Signal = require(Paths.shared.Signal)
local Component = require(Paths.controllers.UI.Components.Component)
local ClickIndicator = require(Paths.controllers.UI.Components.ClickIndicator)
local Sounds = require(Paths.shared.Sounds)
local DeviceUtil = require(Paths.controllers.Utils.DeviceUtil)

local CLICK_COOLDOWN = 0.05

local GUI_INSET_Y = GuiService:GetGuiInset().Y

export type Button = typeof(Button.new())
local playerGui = Players.LocalPlayer.PlayerGui

function Button.new(guiObject: GuiButton, mute: boolean?)
	local button = Component.new()

	-------------------------------------------------------------------------------
	-- PRIVATE MEMBERS
	-------------------------------------------------------------------------------
	local clickIndicatorEnabled = false

	local hovering: boolean = false
	local clickDebounce = false

	-------------------------------------------------------------------------------
	-- PUBLIC MEMBERS
	-------------------------------------------------------------------------------
	button.pressed = Signal.new()
	button.released = Signal.new()
	button.hoverStarted = Signal.new()
	button.hoverEnded = Signal.new()
	button.clicked = Signal.new()

	-------------------------------------------------------------------------------
	-- PUBLIC METHODS
	-------------------------------------------------------------------------------
	function button:Mount(parent: Instance?, hideBackground: boolean?)
		if hideBackground then
			parent.BackgroundTransparency = 1
		end

		guiObject.Parent = parent

		-- TODO: This should disconnect previous connections if you're mounting else where
		local ancestor = guiObject
		while ancestor ~= playerGui do
			if ancestor:IsA("GuiObject") then
				local instance = ancestor
				instance:GetPropertyChangedSignal("Visible"):Connect(function()
					if instance.Visible == false and hovering then
						hovering = false
						button.hoverEnded:Fire()
					end
				end)
			end

			ancestor = ancestor.Parent
		end
	end

	function button:GetGuiObject()
		return guiObject
	end

	function button:IsHovering()
		return hovering
	end

	function button:EnableClickIndicator()
		clickIndicatorEnabled = true
	end

	function button:ToggleColor(toggle: boolean)
		if toggle then
			guiObject.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			guiObject:FindFirstChildOfClass("UIGradient").Enabled = true
		else
			guiObject.BackgroundColor3 = Color3.fromRGB(162, 162, 162)
			guiObject:FindFirstChildOfClass("UIGradient").Enabled = false
		end
	end

	-------------------------------------------------------------------------------
	-- Event handlers
	-------------------------------------------------------------------------------
	guiObject.MouseButton1Down:Connect(function()
		if not clickDebounce then
			clickDebounce = true

			if clickIndicatorEnabled then
				ClickIndicator.play()
			end

			button.pressed:Fire()

			if not mute then
				Sounds.play("ButtonClick")
			end

			local connection: RBXScriptConnection
			connection = UserInputService.InputEnded:Connect(function(input)
				local userInputType = input.UserInputType
				if
					userInputType == Enum.UserInputType.MouseButton1
					or userInputType == Enum.UserInputType.Touch
					or userInputType == Enum.UserInputType.Gamepad1
				then
					button.released:Fire()
					connection:Disconnect()
				end
			end)

			task.wait(CLICK_COOLDOWN)
			clickDebounce = false
		end
	end)

	guiObject.MouseEnter:Connect(function()
		if not hovering then
			hovering = true
			button.hoverStarted:Fire()
		end
	end)

	guiObject.MouseLeave:Connect(function()
		if hovering then
			hovering = false
			button.hoverEnded:Fire()
		end
	end)

	button.released:Connect(function()
		if not DeviceUtil.isGamepadInput() then
			local mouseLocation = UserInputService:GetMouseLocation() + Vector2.new(0, -GUI_INSET_Y)
			local buttonPosition = guiObject.AbsolutePosition
			local buttonSize = guiObject.AbsoluteSize

			if
				mouseLocation.X < buttonPosition.X
				or mouseLocation.X > buttonPosition.X + buttonSize.X
				or mouseLocation.Y < buttonPosition.Y
				or mouseLocation.Y > buttonPosition.Y + buttonSize.Y
			then
				return
			end
		end

		button.clicked:Fire()
	end)

	button:GetMaid():Add(GuiService.Changed:Connect(function(changed)
		if changed ~= "SelectedObject" then
			return
		end

		local selected = GuiService.SelectedObject == guiObject
		if selected and not hovering then
			hovering = true
			button.hoverStarted:Fire()
		elseif not selected and hovering then
			hovering = false
			button.hoverEnded:Fire()
		end
	end))

	-------------------------------------------------------------------------------
	-- Initialization
	-------------------------------------------------------------------------------
	guiObject.Active = true
	guiObject.Selectable = true
	guiObject.AutoButtonColor = false

	button:GetMaid():Add(guiObject)

	return button
end

return Button
