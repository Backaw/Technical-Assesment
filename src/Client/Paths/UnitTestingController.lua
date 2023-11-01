local UnitTestingController = {}

local Players = game:GetService("Players")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local UnitTester = require(Paths.Shared.UnitTester)

UnitTester.run(Paths.Controllers)

return UnitTestingController
