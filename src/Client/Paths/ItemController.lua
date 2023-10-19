local ItemController = {}
local Players = game:GetService("Players")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local DataController = require(Paths.controllers.DataController)
local ItemUtil = require(Paths.shared.Items.ItemUtil)

function ItemController.hasItem(itemType: string, itemName: string)
	return DataController.get(ItemUtil.getOwnedItemsAddressFromType(itemType))[itemName] ~= nil
end

function ItemController.isItemEquipped(itemType: string, itemName: string)
	return DataController.get(ItemUtil.getEquippedItemAddressFromType(itemType)) == itemName
end

return ItemController
