local WipeTransition = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)

local screen: ScreenGui = Paths.UI.Transitions
local frame: Frame = screen.Wipe

local ADDITIONAL_OFFSET = 0.02
local TWEEN_INFO_IN = TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local TWEEN_INFO_OUT = TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local tween

function WipeTransition.open()
	if tween then
		tween:Cancel()
	end

	frame.Position = UDim2.fromScale(-(1 + ADDITIONAL_OFFSET), 0)
	frame.Visible = true

	tween = TweenService:Create(frame, TWEEN_INFO_IN, { Position = UDim2.fromScale(0, 0) })
	tween.Completed:Connect(function()
		tween = nil
	end)

	tween:Play()
	tween.Completed:Wait()
end

function WipeTransition.close()
	if tween then
		tween:Cancel()
	end

	tween = TweenService:Create(frame, TWEEN_INFO_OUT, { Position = UDim2.fromScale(2 + ADDITIONAL_OFFSET, 0) })
	tween.Completed:Connect(function()
		frame.Visible = false
		tween = nil
	end)

	tween:Play()
	tween.Completed:Wait()
end

screen.Enabled = true
frame.Visible = false

return WipeTransition
