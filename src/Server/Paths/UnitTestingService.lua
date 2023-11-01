local UnitTestingService = {}

local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local UnitTester = require(Paths.Shared.UnitTester)

UnitTester.run(Paths.Shared)
UnitTester.run(Paths.Services)

return UnitTestingService
