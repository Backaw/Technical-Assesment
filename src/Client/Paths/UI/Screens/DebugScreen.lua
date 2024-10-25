local DebugScreen = {}

local Players = game:GetService("Players")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local TemplateUtil = require(Paths.Shared.Utils.TemplateUtil)

local HUD: ScreenGui = Paths.UI.HUD
local screen: ScreenGui = Paths.UI.Debug
local labels: Frame = screen.States
local itemConstructor = TemplateUtil.constructor(labels.TEMP_STATE)

local DISABLED = false

-------------------------------------------------------------------------------
-- PUBLIC MEMBERS
-------------------------------------------------------------------------------
function DebugScreen.write(label: string, value: any, highlight: Color3?)
	if DISABLED then
		return
	end

	local textLabel: TextLabel = labels:FindFirstChild(label)
	if not textLabel then
		textLabel = itemConstructor() :: TextLabel
		textLabel.Name = label
		if highlight then
			textLabel.TextColor3 = highlight
			textLabel.UIStroke.Color = Color3.new()
		end
	end

	textLabel.Text = ("%s: %s"):format(label, tostring(value))
end

function DebugScreen.writeNumber(label: string, value: number, highlight: Color3?)
	DebugScreen.write(label, ("%.3f"):format(value), highlight)
end

function DebugScreen.writeVector(label: string, value: Vector3, highlight: Color3?)
	DebugScreen.write(label, ("(%.3f, %.3f, %.3f)"):format(value.X, value.Y, value.Z), highlight)
end

-------------------------------------------------------------------------------
-- LOGIC
-------------------------------------------------------------------------------

-- Register state
do
	if not DISABLED then
		screen.Enabled = HUD.Enabled
		HUD:GetPropertyChangedSignal("Enabled"):Connect(function()
			screen.Enabled = HUD.Enabled
		end)
	else
		screen.Enabled = false
	end
end

return DebugScreen
