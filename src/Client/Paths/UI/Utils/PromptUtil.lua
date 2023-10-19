local PromptUtil = {}

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local Toggle = require(Paths.shared.Toggle)
local TweenUtil = require(Paths.shared.Utils.TweenUtil)
local Binder = require(Paths.shared.Binder)
local CameraController = require(Paths.controllers.CameraController)

local ANIMATION_LENGTH = 0.3
local PROMPT_ANIMATION_LENGTH = ANIMATION_LENGTH / 2

local BINDING_KEY = "PromptToggle"
local OPEN_BLUR_SIZE = 24
local OPEN_FOV = 60

local blurEffect = Instance.new("BlurEffect")
blurEffect.Size = 0
blurEffect.Enabled = true
blurEffect.Parent = Lighting

local backgroundScreen: ScreenGui = Paths.ui.Background
local backgroundFrame: Frame = backgroundScreen.Frame

local cosmeticsEnabled = Toggle.new(false, function(toggle)
	if toggle then
		TweenUtil.bind(
			blurEffect,
			BINDING_KEY,
			TweenService:Create(
				blurEffect,
				TweenInfo.new(ANIMATION_LENGTH, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{ Size = OPEN_BLUR_SIZE }
			)
		)

		PromptUtil.openBackground()

		CameraController.setFov(OPEN_FOV, ANIMATION_LENGTH)
	else
		TweenUtil.bind(
			blurEffect,
			BINDING_KEY,
			TweenService:Create(
				blurEffect,
				TweenInfo.new(ANIMATION_LENGTH, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{ Size = 0 }
			)
		)

		backgroundScreen.Enabled = false
		CameraController.resetFov(ANIMATION_LENGTH)
	end
end)

-------------------------------------------------------------------------------
-- PUBLIC METHODS
-------------------------------------------------------------------------------
function PromptUtil.openBackground(frame: Frame?)
	frame = frame or backgroundFrame
	local screen: ScreenGui = frame.Parent

	local initialTransparency = Binder.bindFirst(frame, "InitialTransparency", frame.BackgroundTransparency)
	frame.BackgroundTransparency = 1
	frame.Visible = true
	screen.Enabled = true

	TweenUtil.bind(
		frame,
		BINDING_KEY,
		TweenService:Create(
			frame,
			TweenInfo.new(PROMPT_ANIMATION_LENGTH, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{ BackgroundTransparency = initialTransparency }
		)
	)
end

function PromptUtil.open(prompt: Frame, cosmetics: boolean?)
	if cosmetics then
		cosmeticsEnabled:Set(prompt, true)
	end

	local initialPosition = Binder.bindFirst(prompt, "InitialPosition", prompt.Position)
	prompt.Position = initialPosition + UDim2.fromScale(0, 1)

	prompt.Visible = true
	TweenUtil.bind(
		prompt,
		BINDING_KEY,
		TweenService:Create(
			prompt,
			TweenInfo.new(PROMPT_ANIMATION_LENGTH, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Position = initialPosition }
		)
	)
end

function PromptUtil.popIn(prompt: Frame, cosmetics: boolean?)
	if cosmetics then
		cosmeticsEnabled:Set(prompt, true)
	end

	local initialSize = Binder.bindFirst(prompt, "InitialSize", prompt.Size)
	prompt.Size = UDim2.fromScale(0, 0)

	prompt.Visible = true
	TweenUtil.bind(
		prompt,
		BINDING_KEY,
		TweenService:Create(
			prompt,
			TweenInfo.new(PROMPT_ANIMATION_LENGTH, Enum.EasingStyle.Back, Enum.EasingDirection.In),
			{ Size = initialSize }
		)
	)
end

function PromptUtil.close(prompt: Frame, cosmetics: boolean?)
	if cosmetics then
		cosmeticsEnabled:Set(prompt, false)
	end
	prompt.Visible = false
end

-------------------------------------------------------------------------------
-- INITIALIZATION
-------------------------------------------------------------------------------
backgroundScreen.Enabled = false

return PromptUtil
