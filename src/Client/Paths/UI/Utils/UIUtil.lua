local UIUtil = {}

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local UIConstants = require(Paths.controllers.UI.UIConstants)
local Button = require(Paths.controllers.UI.Components.Button)
local Maid = require(Paths.shared.Maid)
local KeybindSprites = require(Paths.controllers.UI.KeybindSprites)
local DeviceUtil = require(Paths.controllers.Utils.DeviceUtil)

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

function UIUtil.isCrosshairState(state: string)
	return state == UIConstants.States.HUD
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
	displayMobileIcon: boolean,
	keyboardInput: Enum.KeyCode | Enum.UserInputType | nil,
	gamepadInput: Enum.KeyCode | Enum.UserInputType | nil?
)
	if UserInputService.GamepadEnabled then
		KeybindSprites.Gamepad:ApplySprite(gamepadInput, imageLabel)
	elseif DeviceUtil.isDesktop() then
		KeybindSprites.Keyboard:ApplySprite(keyboardInput, imageLabel)
	else
		if displayMobileIcon then
			KeybindSprites.Gestures:ApplySprite("Tap", imageLabel)
		else
			KeybindSprites.Gamepad:ApplySprite(nil, imageLabel)
		end
	end
end

function UIUtil.bindInputToButton(
	button: Button.Button,
	displayMobileIcon: boolean,
	keyboardInput: Enum.KeyCode | Enum.UserInputType | nil,
	gamepadInput: Enum.KeyCode | Enum.UserInputType | nil?,
	callback: () -> () | nil
)
	local maid = Maid.new()

	local icon = button:GetGuiObject():FindFirstChild("Input")
	maid:Add(function()
		icon.Image = ""
	end)

	if icon then
		maid:Add(DeviceUtil.onInputTypeChanged(function()
			UIUtil.applyKeybindIcon(icon, displayMobileIcon, keyboardInput, gamepadInput)
		end))
	end

	maid:Add(UserInputService.InputBegan:Connect(function(input, sunk)
		if sunk then
			return
		end

		local keycode = input.KeyCode
		local inputType = input.UserInputType
		if keycode == keyboardInput or inputType == keyboardInput or keycode == gamepadInput or inputType == gamepadInput then
			if callback then
				callback()
			else
				button.pressed:Fire()
			end
		end
	end))

	maid:Add(UserInputService.InputEnded:Connect(function(input, sunk)
		if sunk then
			return
		end

		local keycode = input.KeyCode
		local inputType = input.UserInputType
		if keycode == keyboardInput or inputType == keyboardInput or keycode == gamepadInput or inputType == gamepadInput then
			if not callback then
				button.released:Fire()
			end
		end
	end))

	return maid
end

return UIUtil
