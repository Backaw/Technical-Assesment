local UIConstants = {}

UIConstants.InitialState = "Nothing"
UIConstants.States = {
	HUD = "HUD",
	Rides = "Rides",
	PromoCodes = "PromoCodes",
	Settings = "Settings",
	PlaytimeRewards = "PlaytimeRewards",
	RidePlacement = "RidePlacement",
	ProductPurchaseConfirmation = "ProductPurchaseConfirmation",
	RewardWheel = "RewardWheel",
	Reward = "Reward",
	SeasonPass = "SeasonPass",
	Trails = "Trails",
}

UIConstants.HUDPermissiveStates = {
	UIConstants.States.Rides,
	UIConstants.States.PromoCodes,
	UIConstants.States.Settings,
	UIConstants.States.PlaytimeRewards,
	UIConstants.States.SeasonPass,
	UIConstants.States.Trails,
}

UIConstants.PsuedoStates = {}

UIConstants.InteractionPermissiveStates = {
	UIConstants.States.HUD,
}

UIConstants.StrokeThickness = 3

UIConstants.Colors = {
	Buttons = {
		SelectedYellow = Color3.fromRGB(231, 255, 14),
		LightGray = Color3.fromRGB(202, 202, 202),
		DarkGray = Color3.fromRGB(150, 150, 150),
		Blue = Color3.fromRGB(52, 187, 255),
		Pink = Color3.fromRGB(255, 57, 252),
		PremiumYellow = Color3.fromRGB(255, 197, 21),
	},
}

return UIConstants
