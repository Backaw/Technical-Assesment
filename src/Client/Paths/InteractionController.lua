local InteractionController = {}

local CollectionService = game:GetService("CollectionService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local UIController = require(Paths.controllers.UI.UIController)
local UIUtil = require(Paths.controllers.UI.Utils.UIUtil)

local MAX_PROMPTS_VISIBLE = 1
local MAX_ACTIVATION_DISTANCE = 20

type ProximityPromptDict = { [ProximityPrompt]: true? }
type InteractionHandler = (instance: PVInstance, proximityPrompt: ProximityPrompt) -> ()

-------------------------------------------------------------------------------
-- PRIVATE MEMBERS
-------------------------------------------------------------------------------
local interactions: { [string]: { Handler: InteractionHandler, ObjectText: string?, ActionText: string? } } = {}

-------------------------------------------------------------------------------
-- PRIVATE METHODS
-------------------------------------------------------------------------------
local function getAttachedInteraction(instance: PVInstance)
	for _, tag in pairs(CollectionService:GetTags(instance)) do
		if interactions[tag] then
			return tag
		end
	end
end

-------------------------------------------------------------------------------
-- PUBLIC METHODS
-------------------------------------------------------------------------------
function InteractionController.bindSelectionBoxToPrompt(
	prompt: ProximityPrompt,
	color: Color3,
	adornee: PVInstance,
	onToggled: (boolean, boolean) -> () | nil
)
	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Visible = false
	selectionBox.Adornee = adornee
	selectionBox.Color3 = color
	selectionBox.Parent = adornee or prompt.Parent

	local shownConnection = prompt.PromptShown:Connect(function()
		selectionBox.Visible = true
		if onToggled then
			onToggled(true, ProximityPromptService.Enabled)
		end
	end)

	local hiddenConnection = prompt.PromptHidden:Connect(function()
		selectionBox.Visible = false
		if onToggled then
			onToggled(false, ProximityPromptService.Enabled)
		end
	end)

	local enabledConnection = ProximityPromptService:GetPropertyChangedSignal("Enabled"):Connect(function()
		local enabled = ProximityPromptService.Enabled

		if onToggled then
			onToggled(selectionBox.Visible, enabled)
		end
	end)

	return function()
		hiddenConnection:Disconnect()
		shownConnection:Disconnect()
		enabledConnection:Disconnect()
	end
end

function InteractionController.createPrompt(potentiallyInitialized: boolean, instance: PVInstance, objectText: string?, actionText: string?)
	local proximityPrompt = instance:FindFirstChildOfClass("ProximityPrompt")

	if proximityPrompt then
		-- ERROR: Already created a prompt, don't want to overide
		if potentiallyInitialized then
			return
		end
	else
		proximityPrompt = Instance.new("ProximityPrompt")
		proximityPrompt.MaxActivationDistance = MAX_ACTIVATION_DISTANCE
		proximityPrompt.RequiresLineOfSight = false
		proximityPrompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
		proximityPrompt.Parent = instance
	end

	proximityPrompt.ActionText = actionText or ""
	proximityPrompt.ObjectText = objectText or ""

	return proximityPrompt
end

function InteractionController.isEnabled(): boolean
	return ProximityPromptService.Enabled
end

function InteractionController.registerInteraction(
	interaction: string,
	handler: InteractionHandler,
	actionText: string?,
	objectText: string?
)
	-- ERROR: Interaction has already been registered
	if interactions[interaction] then
		error(("Interaction %s has already been registered"):format(interaction))
	end

	interactions[interaction] = {
		Handler = handler,
		ObjectText = objectText,
		ActionText = actionText,
	}

	-- Adding
	for _, instance in pairs(CollectionService:GetTagged(interaction)) do
		InteractionController.createPrompt(false, instance, objectText, actionText)
	end
	CollectionService:GetInstanceAddedSignal(interaction):Connect(function(instance)
		InteractionController.createPrompt(true, instance)
	end)

	-- Removing
	CollectionService:GetInstanceRemovedSignal(interaction):Connect(function(instance)
		local proximityPrompt = instance:FindFirstChildOfClass("ProximityPrompt")
		if proximityPrompt then
			proximityPrompt:Destroy()
		end
	end)
end

function InteractionController.attachInteraction(instance: PVInstance, interaction: string, objectText: string?, actionText: string?)
	-- ERROR: Interaction hasn't been registered
	local info = interactions[interaction]
	if not info then
		error(("Attempt to add an unregistered interaction(%s) to an instance"):format(interaction))
	end

	-- ERROR: Can't have two interactions on the same instance
	if getAttachedInteraction(instance) then
		error("Attempt to attach an interaction to an instance that already has one attached")
	end

	InteractionController.createPrompt(false, instance, objectText or info.ObjectText, actionText or info.ActionText)
	CollectionService:AddTag(instance, interaction)
end

function InteractionController.replaceInteraction(instance: PVInstance, interaction: string, objectText: string?, actionText: string?)
	CollectionService:RemoveTag(instance, getAttachedInteraction(instance))
	InteractionController.attachInteraction(instance, interaction, objectText, actionText)
end

function InteractionController.detachInteraction(instance: PVInstance)
	CollectionService:RemoveTag(instance, getAttachedInteraction(instance))

	local proximityPrompt = instance:FindFirstChildOfClass("ProximityPrompt")
	if proximityPrompt then
		proximityPrompt:Destroy()
	end
end

function InteractionController.getAllProximityPromptsOfType(interaction: string)
	-- ERROR: Interaction hasn't been registered
	if not interactions[interaction] then
		error(("Attempt to get proximity prompts of an unregistered interaction"):format(interaction))
	end

	local proximityPrompts = {}

	for _, instance in pairs(CollectionService:GetTagged(interaction)) do
		table.insert(proximityPrompts, instance:FindFirstChildOfClass("ProximityPrompt"))
	end

	return proximityPrompts
end

-------------------------------------------------------------------------------
-- INITIALIZATION
-------------------------------------------------------------------------------
function InteractionController.start()
	-- Disable interactions for certain ui states
	UIController.getStateMachine():RegisterGlobalCallback(function(_, toState)
		if UIUtil.isStateInteractionPermissive(toState) then
			ProximityPromptService.Enabled = true
		else
			ProximityPromptService.Enabled = false
		end
	end)
end

-------------------------------------------------------------------------------
-- LOGIC
-------------------------------------------------------------------------------
ProximityPromptService.MaxPromptsVisible = MAX_PROMPTS_VISIBLE

ProximityPromptService.PromptTriggered:Connect(function(proximityPrompt)
	local instance = proximityPrompt.Parent
	local registration = interactions[getAttachedInteraction(instance)]
	if registration then
		registration.Handler(instance, proximityPrompt)
	end
end)

return InteractionController
