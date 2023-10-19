local ToolItems = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyConstants = require(ReplicatedStorage.Modules.Currency.CurrencyConstants)

export type Ride = {
	Name: string?,
	Icon: string,
	Requirement: CurrencyConstants.Price | nil,
}

local items: { [string]: Ride } = {}

ToolItems.Items = items

for name, item in pairs(items) do
	item.Name = name
end

return ToolItems
