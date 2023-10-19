local CoreGuiController = {}

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player.PlayerGui

-- Lock screen orientation
playerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

return CoreGuiController
