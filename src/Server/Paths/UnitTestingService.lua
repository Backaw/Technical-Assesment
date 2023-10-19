local UnitTestingService = {}

local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local UnitTester = require(Paths.shared.UnitTester)

UnitTester.run(Paths.shared)
UnitTester.run(Paths.services)

return UnitTestingService
