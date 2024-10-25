local UIConstants = {}

UIConstants.InitialState = "Nothing"
UIConstants.States = {
	HUD = "HUD",
}

UIConstants.HUDPermissiveStates = {}

UIConstants.PsuedoStates = {}

UIConstants.InteractionPermissiveStates = {
	UIConstants.States.HUD,
}

return UIConstants
