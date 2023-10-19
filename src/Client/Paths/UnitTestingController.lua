local UnitTestingController = {}

local Players = game:GetService("Players")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local UnitTester = require(Paths.shared.UnitTester)

UnitTester.run(Paths.controllers)

return UnitTestingController
