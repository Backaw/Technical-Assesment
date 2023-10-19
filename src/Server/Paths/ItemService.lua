local ItemService = {}

local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local Remotes = require(Paths.shared.Remotes)
local Signal = require(Paths.shared.Signal)
local PlayerDataService = require(Paths.services.Data.PlayerDataService)
local ItemUtil = require(Paths.shared.Items.ItemUtil)
local ItemConstants = require(Paths.shared.Items.ItemConstants)
local ProductConstants = require(Paths.shared.Products.ProductConstants)
local ProductService = require(Paths.services.Products.ProductService)
local TableUtil = require(Paths.shared.Utils.TableUtil)
local QuestService = require(Paths.services.QuestService)
local QuestConstants = require(Paths.shared.Quests.QuestConstants)
local PlayersService = require(Paths.services.PlayersService)
local CurrencyConstants = require(Paths.shared.Currency.CurrencyConstants)
local GameAnalyticsService = require(Paths.services.GameAnalyticsService)

type Validator = (Player) -> boolean

-------------------------------------------------------------------------------
-- PRIVATE MEMBERS
-------------------------------------------------------------------------------
local freeItems: { [string]: { string } } = {}
local questItems: { [string]: { table } } = {}
local validators: { [table]: Validator } = {}

-------------------------------------------------------------------------------
-- PUBLIC MEMBERS
-------------------------------------------------------------------------------
ItemService.equippedChanged = Signal.new() -- (player : Player, itemType : String, itemName : string)
ItemService.itemAcquired = Signal.new() -- (player : Player, itemType : String, itemName : string)

-------------------------------------------------------------------------------
-- PUBLIC METHODS
-------------------------------------------------------------------------------
function ItemService.registerValidator(item: table, validator: Validator)
	validators[item] = validator
end

function ItemService.hasItem(player: Player, itemType: string, itemName: string)
	return PlayerDataService.get(player, ItemUtil.getOwnedItemsAddressFromType(itemType))[itemName] ~= nil
end

function ItemService.getOwnedItems(player: Player, itemType: string)
	return TableUtil.getKeys(PlayerDataService.get(player, ItemUtil.getOwnedItemsAddressFromType(itemType)))
end

function ItemService.giveItem(player: Player, itemType: string, itemName: string, loaned: boolean?)
	-- RETURN: Item is already owned
	if ItemService.hasItem(player, itemType, itemName) then
		return
	end

	-- RETURN: Item doesn't exist
	local item = ItemConstants.Items[itemType][itemName]
	if not item then
		return
	end

	-- RETURN: Cannot award item at this time
	if validators[item] and not validators[item](player) then
		return
	end

	local address = ItemUtil.getOwnedItemsAddressFromType(itemType)
	PlayerDataService.set(player, address .. "." .. itemName, loaned or false, "ItemAcquired", {
		Type = itemType,
		Name = itemName,
	})

	ItemService.itemAcquired:Fire(player, itemType, itemName)
	if not loaned then
		GameAnalyticsService.addEvent("DesignEvent", player.UserId, {
			eventId = ("%s:%s:%s"):format("ItemUnlocked", itemType, itemName),
		})
	end
end

ItemService.loadPlayer = PlayersService.promisifyLoader(function(player)
	for itemType, items in pairs(freeItems) do
		for _, itemName in pairs(items) do
			if not ItemService.hasItem(player, itemType, itemName) then
				ItemService.giveItem(player, itemType, itemName)
			end
		end
	end

	for itemType, items in pairs(questItems) do
		for _, item in pairs(items) do
			local itemName = item.Name

			if
				not ItemService.hasItem(player, itemType, itemName)
				and PlayerDataService.get(player, ("Quests.Completed.%s"):format(item.Requirement.Name))
			then
				ItemService.giveItem(player, itemType, itemName)
			end
		end
	end
end, "Items")

function ItemService.changeEquippedItem(player: Player, itemType: string, itemName: string)
	-- RETURN: Item is not owned
	if itemName and not ItemService.hasItem(player, itemType, itemName) then
		return false
	end

	ItemService.equippedChanged:Fire(player, itemType, itemName)
	local address = ItemUtil.getEquippedItemAddressFromType(itemType)

	PlayerDataService.set(player, address, itemName, "ItemEquippedChanged", {
		Type = itemType,
		Name = itemName,
		PreviouslyEquipped = PlayerDataService.get(player, address),
	})

	return true
end

-------------------------------------------------------------------------------
-- LOGIC
-------------------------------------------------------------------------------
-- EVENT HANDLERS
ProductService.productPurchased:Connect(function(player: Player, product: ProductConstants.Product)
	local itemType = product.Type
	if ItemConstants.Types[itemType] then
		ItemService.giveItem(player, itemType, product.Name)
	end
end)

QuestService.questCompleted:Connect(function(player: Player, quest: QuestConstants.Quest)
	for itemType, items in pairs(ItemConstants.Items) do
		for _, item in pairs(items) do
			if item.Requirement == quest then
				ItemService.giveItem(player, itemType, item.Name)
			end
		end
	end
end)

Remotes.bindFunctions({
	ChangeEquippedItem = ItemService.changeEquippedItem,
})

-- FREE ITEMS
for itemType, items in pairs(ItemConstants.Items) do
	freeItems[itemType] = {}
	questItems[itemType] = {}

	for _, item in pairs(items) do
		local requirement = item.Requirement
		if requirement then
			if requirement.Currency == CurrencyConstants.Currencies.Free then
				table.insert(freeItems[itemType], item.Name)
			elseif not requirement.Currency then
				table.insert(questItems[itemType], item)
			end
		end
	end
end

-- LOADNED ITEMS
PlayerDataService.registerReconciler(function(data)
	for _, items in pairs(data.OwnedItems) do
		for itemName, loaned in pairs(items) do
			if loaned then
				items[itemName] = nil
			end
		end
	end
end)

return ItemService
