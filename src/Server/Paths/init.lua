local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Paths = {}

Paths.Services = script
Paths.Shared = ReplicatedStorage.Modules

Paths.Initialized = require(Paths.Shared.DeferredPromise).new()
Paths.Assets = ReplicatedStorage.Assets

task.delay(0, function()
	local ping = os.clock()

	local initializing = {
		require(Paths.Shared.Utils.ParticleUtil),

		-- Services
		require(Paths.Services.SoftShutdownService),
		require(Paths.Services.UnitTestingService),
		require(Paths.Services.CollisionService),
		require(Paths.Services.PlayersService),
		require(Paths.Services.CurrencyService),
		require(Paths.Services.Products.ProductService),
		require(Paths.Services.SettingsService),
		require(Paths.Services.Cmdr.CmdrService),
		require(Paths.Services.GameAnalyticsService),
		require(Paths.Services.PromoCodeService),
		require(Paths.Services.ItemService),
		-- require(Paths.Services.Data.LeaderboardService),
		require(Paths.Services.RewardService),
		require(Paths.Services.FriendsService),
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

	Paths.Initialized.resolve()

	print("Welcome to NEW GAME")
	print(string.format("✅ Server loaded in %.6f seconds", os.clock() - ping))
end)

return Paths
