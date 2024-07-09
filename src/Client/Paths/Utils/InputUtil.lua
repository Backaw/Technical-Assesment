local InputUtil = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local Maid = require(Paths.Shared.Maid)

export type Input = Enum.UserInputType | Enum.KeyCode | nil

function InputUtil.bindPress(
	handler: (Enum.UserInputState) -> (),
	keyboardMouseInput: Input,
	gamepadInput: Input,
	overrideGameInput: boolean?
)
	local maid = Maid.new()

	local lastInput: InputObject
	maid:Add(UserInputService.InputBegan:Connect(function(input, sunk)
		if sunk and not overrideGameInput then
			return
		end

		local keycode = input.KeyCode
		local inputType = input.UserInputType
		if keycode == keyboardMouseInput or inputType == keyboardMouseInput or keycode == gamepadInput or inputType == gamepadInput then
			lastInput = input
			handler(Enum.UserInputState.Begin)
		end
	end))

	maid:Add(UserInputService.InputEnded:Connect(function(input, sunk)
		if sunk and not overrideGameInput then
			return
		end

		local keycode = input.KeyCode
		local inputType = input.UserInputType

		if
			input == lastInput
			and (keycode == keyboardMouseInput or inputType == keyboardMouseInput or keycode == gamepadInput or inputType == gamepadInput)
		then
			handler(Enum.UserInputState.End)
		end
	end))

	return maid
end

return InputUtil
