local UIController = {}

local Players = game:GetService("Players")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local StateMachine = require(Paths.Shared.StateMachine)
local UIConstants = require(Paths.Controllers.UI.UIConstants)
local StringUtil = require(Paths.Shared.Utils.StringUtil)
local TableUtil = require(Paths.Shared.Utils.TableUtil)
local UIUtil = require(Paths.Controllers.UI.Utils.UIUtil)

type ScreenStateCallback = ((table?) -> ())?
type ScreenStateCallbacks = {
	Boot: ScreenStateCallback,
	Shutdown: ScreenStateCallback,
	Minimize: ScreenStateCallback,
	Maximize: ScreenStateCallback,
}

local uiStateMachine = StateMachine.new(TableUtil.toArray(UIConstants.States), UIConstants.InitialState)
local lastUiStateStack = uiStateMachine:GetStack()

local screenStateCallbacks: { [string]: ScreenStateCallbacks } = {}
function UIController.getStateMachine()
	return uiStateMachine
end

function UIController.registerScreenStateCallbacks(state: string, callbacks: ScreenStateCallbacks)
	if not UIConstants.States[state] then
		warn(("%s is an invalid screen state"):format(state))
	end
	screenStateCallbacks[state] = callbacks
end

function UIController.init()
	for _, descedant in pairs(Paths.Controllers.UI:GetDescendants()) do
		if descedant:IsA("ModuleScript") and StringUtil.endsWith(descedant.Name, "Screen") then
			require(descedant)
		end
	end
end

function UIController.toggleScreenState(state: string)
	local currentState = uiStateMachine:GetState()

	if currentState == state then
		uiStateMachine:Pop()
	elseif UIUtil.isState(currentState, UIConstants.States.HUD) then
		uiStateMachine:Push(state)
	else
		uiStateMachine:ReplaceUpTill(state, UIConstants.States.HUD)
	end
end

function UIController.openScreenState(state: string)
	if uiStateMachine:GetState() ~= state then
		UIController.toggleScreenState(state)
	end
end

function UIController.resetToHUD(exceptions: { string }?)
	uiStateMachine:PopUpto(UIConstants.States.HUD, exceptions)
end

uiStateMachine:RegisterGlobalCallback(function(fromState, toState, data)
	local stack = uiStateMachine:GetStack()

	-- Seperate loops so that open is garuanteed to run first, helps PromptUtil background transitions not be choppy
	for state, callbacks in pairs(screenStateCallbacks) do
		if state == toState then
			if not table.find(lastUiStateStack, state) and callbacks.Boot then
				local success, err = pcall(callbacks.Boot, data)
				if not success then
					warn(err)
				end
			end

			if callbacks.Maximize then
				local success, err = pcall(callbacks.Maximize, data)
				if not success then
					warn(err)
				end
			end
		end
	end

	for state, callbacks in pairs(screenStateCallbacks) do
		if fromState == state then
			if callbacks.Minimize then
				local success, err = pcall(callbacks.Minimize)
				if not success then
					warn(err)
				end
			end
		end

		if not table.find(stack, state) and table.find(lastUiStateStack, state) then -- Closed or removed
			if callbacks.Shutdown then
				local success, err = pcall(callbacks.Shutdown)
				if not success then
					warn(err)
				end
			end
		end
	end

	lastUiStateStack = stack
end)

return UIController
