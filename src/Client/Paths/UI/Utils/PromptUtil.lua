local PromptUtil = {}

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local Toggle = require(Paths.Shared.Toggle)
local TweenUtil = require(Paths.Shared.Utils.TweenUtil)
local Binder = require(Paths.Shared.Binder)

local ANIMATION_LENGTH = 0.3
local PROMPT_ANIMATION_LENGTH = ANIMATION_LENGTH / 2

local BINDING_KEY = "PromptToggle"
-- local OPEN_BLUR_SIZE = 20
local DEFAULT_BACKGROUND_TRANSPARENCY = 0.6

local blurEffect = Instance.new("BlurEffect")
blurEffect.Size = 0
blurEffect.Enabled = true
blurEffect.Parent = Lighting

local backgroundScreen: ScreenGui = Paths.UI.Background
local backgroundFrame: Frame = backgroundScreen.Frame

local cosmeticsEnabled = Toggle.new(false)

-------------------------------------------------------------------------------
-- PUBLIC MEMBERS
-------------------------------------------------------------------------------
PromptUtil.Direction = {
	Up = UDim2.fromScale(0, 1),
	Down = UDim2.fromScale(0, -1),
	Left = UDim2.fromScale(1, 0),
	Right = UDim2.fromScale(-1, 0),
}

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

function PromptUtil.open(prompt: GuiObject, cosmetics: boolean?)
	if cosmetics then
		cosmeticsEnabled:Set(prompt, true)
	end

	prompt.Visible = true
end

function PromptUtil.scaleOpen(prompt: GuiObject, cosmetics: boolean?, direction: string?)
	direction = direction or PromptUtil.Direction.Down

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
			TweenInfo.new(PROMPT_ANIMATION_LENGTH, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Size = initialSize }
		)
	)
end

function PromptUtil.slideOpen(prompt: GuiObject, cosmetics: boolean?, direction: UDim2?)
	direction = direction or PromptUtil.Direction.Up

	if cosmetics then
		cosmeticsEnabled:Set(prompt, true)
	end

	local initialPosition = Binder.bindFirst(prompt, "InitialPosition", prompt.Position)
	prompt.Position = initialPosition + direction

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

function PromptUtil.slideClose(prompt: GuiObject, cosmetics: boolean?, direction: UDim2?)
	direction = direction or PromptUtil.Direction.Down

	if cosmetics then
		cosmeticsEnabled:Set(prompt, false)
	end

	local initialPosition = Binder.bindFirst(prompt, "InitialPosition", prompt.Position)

	prompt.Visible = true
	TweenUtil.bind(
		prompt,
		BINDING_KEY,
		TweenService:Create(
			prompt,
			TweenInfo.new(PROMPT_ANIMATION_LENGTH, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Position = prompt.Position - direction }
		),
		function()
			prompt.Visible = false
			prompt.Position = initialPosition
		end
	)
end

function PromptUtil.close(prompt: GuiObject, cosmetics: boolean?)
	if cosmetics then
		cosmeticsEnabled:Set(prompt, false)
	end
	prompt.Visible = false
end

-------------------------------------------------------------------------------
-- INITIALIZATION
-------------------------------------------------------------------------------
backgroundScreen.Enabled = false
backgroundScreen.Frame.BackgroundTransparency = DEFAULT_BACKGROUND_TRANSPARENCY

cosmeticsEnabled.Changed:Connect(function(toggle)
	if toggle then
		--[[ TweenUtil.bind(
			blurEffect,
			BINDING_KEY,
			TweenService:Create(
				blurEffect,
				TweenInfo.new(ANIMATION_LENGTH, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{ Size = OPEN_BLUR_SIZE }
			)
		) *]]

		PromptUtil.openBackground()
	else
		--[[ TweenUtil.bind(
			blurEffect,
			BINDING_KEY,
			TweenService:Create(
				blurEffect,
				TweenInfo.new(ANIMATION_LENGTH, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{ Size = 0 }
			)
		)
 *]]

		backgroundScreen.Enabled = false
	end
end)

return PromptUtil
