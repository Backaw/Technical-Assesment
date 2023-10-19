local DeviceUtil = {}

local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local Maid = require(Paths.shared.Maid)

DeviceUtil.DEVICES = {
	Console = "Console",
	Mobile = "Mobile",
	Desktop = "Desktop",
}

function DeviceUtil.getDeviceType(): string
	if GuiService:IsTenFootInterface() then
		return DeviceUtil.DEVICES.Console
	elseif UserInputService.TouchEnabled and UserInputService:GetLastInputType() == Enum.UserInputType.Touch then
		return DeviceUtil.DEVICES.Mobile
	else
		return DeviceUtil.DEVICES.Desktop
	end
end

function DeviceUtil.isMobile()
	return DeviceUtil.getDeviceType() == DeviceUtil.DEVICES.Mobile
end

function DeviceUtil.isConsole()
	return DeviceUtil.getDeviceType() == DeviceUtil.DEVICES.Console
end

function DeviceUtil.isDesktop()
	return DeviceUtil.getDeviceType() == DeviceUtil.DEVICES.Desktop
end

function DeviceUtil.isGamepadInput()
	return UserInputService:GetLastInputType().Name:find("Gamepad") ~= nil
end

function DeviceUtil.onInputTypeChanged(handler: () -> ())
	local maid = Maid.new()

	handler()
	maid:Add(UserInputService.GamepadConnected:Connect(handler))
	maid:Add(UserInputService.GamepadDisconnected:Connect(handler))

	return maid
end

return DeviceUtil
