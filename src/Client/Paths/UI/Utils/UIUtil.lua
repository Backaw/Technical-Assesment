local UIUtil = {}

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local UIConstants = require(Paths.Controllers.UI.UIConstants)
local Button: typeof(require(Paths.Controllers.UI.Components.Button))
local Maid = require(Paths.Shared.Maid)
local KeybindSprites = require(Paths.Controllers.UI.KeybindSprites)
local DeviceUtil = require(Paths.Controllers.Utils.DeviceUtil)

local GUI_INSET_Y = GuiService:GetGuiInset().Y

function UIUtil.isStateInteractionPermissive(state: string)
	return table.find(UIConstants.InteractionPermissiveStates, state) ~= nil
end

function UIUtil.isStateHUDPermissive(state: string)
	return UIUtil.isState(state, UIConstants.States.HUD) or table.find(UIConstants.HUDPermissiveStates, state) ~= nil
end

-- Checks if a state is the state itself or a psuedoState
function UIUtil.isState(potentially: string, thisState: string)
	return potentially == thisState
		or (UIConstants.PsuedoStates[thisState] and table.find(UIConstants.PsuedoStates[thisState], potentially))
end

function UIUtil.isStackHUDPermissive(stack: { string })
	-- Every state between HUD and new state should permit HUD inorder to show HUD
	for i = #stack, table.find(stack, UIConstants.States.HUD), -1 do
		if not UIUtil.isStateHUDPermissive(stack[i]) then
			return false
		end
	end

	return true
end

function UIUtil.closeGamepadSelect()
	GuiService.SelectedObject = nil :: Instance
end

function UIUtil.gamepadSelect(guiObject: GuiObject)
	if DeviceUtil.isGamepadInput() then
		GuiService.SelectedObject = guiObject
	end
end

function UIUtil.applyKeybindIcon(
	imageLabel: ImageLabel,
	keyboardInput: Enum.KeyCode | Enum.UserInputType | nil,
	gamepadInput: Enum.KeyCode | Enum.UserInputType | nil?
)
	return DeviceUtil.onInputTypeChanged(function()
		if UserInputService.GamepadEnabled then
			KeybindSprites.Gamepad:ApplySprite(gamepadInput, imageLabel)
		elseif DeviceUtil.isDesktop() then
			KeybindSprites.Keyboard:ApplySprite(keyboardInput, imageLabel)
		else
			KeybindSprites.Gamepad:ApplySprite(nil, imageLabel)
		end
	end)
end

function UIUtil.bindInputToButton(
	button: Button.Button,
	keycodeIcon: ImageLabel,
	keyboardInput: Enum.KeyCode | Enum.UserInputType | nil,
	gamepadInput: Enum.KeyCode | Enum.UserInputType | nil?
)
	local maid = Maid.new()

	maid:Add(function()
		keycodeIcon.Image = ""
	end)

	if keycodeIcon then
		maid:Add(UIUtil.applyKeybindIcon(keycodeIcon, keyboardInput, gamepadInput))
	end

	local lastInput: InputObject
	maid:Add(UserInputService.InputBegan:Connect(function(input, sunk)
		if sunk then
			return
		end

		local keycode = input.KeyCode
		local inputType = input.UserInputType
		if keycode == keyboardInput or inputType == keyboardInput or keycode == gamepadInput or inputType == gamepadInput then
			lastInput = input
			button.Pressed:Fire()
		end
	end))

	maid:Add(UserInputService.InputEnded:Connect(function(input, sunk)
		if sunk then
			return
		end

		local keycode = input.KeyCode
		local inputType = input.UserInputType

		if
			input == lastInput
			and (keycode == keyboardInput or inputType == keyboardInput or keycode == gamepadInput or inputType == gamepadInput)
		then
			button.Released:Fire(true)
		end
	end))

	return maid
end

function UIUtil.isMouseWithinObjectBounds(guiObject: GuiObject, size: Vector2?)
	local buttonPosition = guiObject.AbsolutePosition
	local buttonSize = size or guiObject.AbsoluteSize
	local mouseLocation = UserInputService:GetMouseLocation() + Vector2.new(0, -GUI_INSET_Y)

	return mouseLocation.X > buttonPosition.X
		and mouseLocation.X < buttonPosition.X + buttonSize.X
		and mouseLocation.Y > buttonPosition.Y
		and mouseLocation.Y < buttonPosition.Y + buttonSize.Y
end

function UIUtil.mountZIndex(guiObject: GuiObject, ignoreGuiObject: boolean?)
	local baseZIndex = guiObject.Parent.ZIndex

	if not ignoreGuiObject then
		guiObject.ZIndex += baseZIndex
	end

	for _, child in pairs(guiObject:GetChildren()) do
		if child:IsA("GuiObject") then
			child.ZIndex += baseZIndex
		end
	end
end

function UIUtil.init()
	Button = require(Paths.Controllers.UI.Components.Button)
end

return UIUtil
