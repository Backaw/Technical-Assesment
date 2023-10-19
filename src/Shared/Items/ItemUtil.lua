local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemConstants = require(ReplicatedStorage.Modules.Items.ItemConstants)

local ItemUtil = {}

function ItemUtil.getOwnedItemsAddressFromType(itemType: string)
	-- ERROR: Invalid item type
	if not ItemConstants.Types[itemType] then
		error(("%s is an invalid item type"):format(itemType))
	end

	return "OwnedItems." .. itemType
end

function ItemUtil.getEquippedItemAddressFromType(itemType: string)
	-- ERROR: Invalid item type
	if not ItemConstants.Types[itemType] then
		error(("%s is an invalid item type"):format(itemType))
	end

	return "EquippedItems." .. itemType
end

return ItemUtil
