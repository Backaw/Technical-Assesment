local EyeTransition = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)

local screen: ScreenGui = Paths.ui.Transitions
local frame: ImageLabel = screen.Eye

local TWEEN_INFO = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local CLOSE_SIZE = UDim2.fromScale(2, 2)

local tween

function EyeTransition.open()
	if tween then
		tween:Cancel()
	end

	frame.Size = CLOSE_SIZE
	frame.Visible = true
	tween = TweenService:Create(frame, TWEEN_INFO, { Size = UDim2.fromScale(0, 0) })
	tween.Completed:Connect(function()
		tween = nil
	end)

	tween:Play()
	tween.Completed:Wait()
end

function EyeTransition.close()
	if tween then
		tween:Cancel()
	end

	tween = TweenService:Create(frame, TWEEN_INFO, { Size = CLOSE_SIZE })
	tween.Completed:Connect(function()
		frame.Visible = false
		tween = nil
	end)

	tween:Play()
	tween.Completed:Wait()
end

screen.Enabled = true
frame.Visible = false

return EyeTransition
