local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Paths = {}

Paths.services = script
Paths.shared = ReplicatedStorage.Modules

Paths.initialized = require(Paths.shared.DeferredPromise).new()
Paths.assets = ReplicatedStorage.Assets

task.delay(0, function()
	local ping = os.clock()

	local initializing = {
		require(Paths.shared.Utils.ParticleUtil),

		-- Services
		require(Paths.services.SoftShutdownService),
		require(Paths.services.UnitTestingService),
		require(Paths.services.CollisionService),
		require(Paths.services.PlayersService),
		require(Paths.services.CoinService),
		require(Paths.services.Products.ProductService),
		require(Paths.services.SettingsService),
		require(Paths.services.Cmdr.CmdrService),
		require(Paths.services.GameAnalyticsService),
		require(Paths.services.PromoCodeService),
		require(Paths.services.ItemService),
		-- require(Paths.services.Data.LeaderboardService),
		require(Paths.services.RewardService),
		require(Paths.services.FriendsService),
	}

	for _, module in ipairs(initializing) do
		local method = module.init
		if method then
			method()
		end
	end

	for _, module in pairs(initializing) do
		task.spawn(function()
			local method = module.start
			if method then
				method()
			end
		end)
	end

	Paths.initialized.resolve()

	print("Welcome to NEW GAME")
	print(string.format("✅ Server loaded in %.6f seconds", os.clock() - ping))
end)

return Paths
