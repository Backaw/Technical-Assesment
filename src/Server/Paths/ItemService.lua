local ItemService = {}

local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local Remotes = require(Paths.Shared.Remotes)
local Signal = require(Paths.Shared.Signal)
local PlayerDataService = require(Paths.Services.Data.PlayerDataService)
local ItemUtil = require(Paths.Shared.Items.ItemUtil)
local ItemConstants = require(Paths.Shared.Items.ItemConstants)
local ProductConstants = require(Paths.Shared.Products.ProductConstants)
local ProductService = require(Paths.Services.Products.ProductService)
local TableUtil = require(Paths.Shared.Utils.TableUtil)
local QuestService = require(Paths.Services.QuestService)
local QuestConstants = require(Paths.Shared.Quests.QuestConstants)
local PlayersService = require(Paths.Services.PlayersService)
local CurrencyConstants = require(Paths.Shared.Currency.CurrencyConstants)
local GameAnalyticsService = require(Paths.Services.GameAnalyticsService)

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
ItemService.EquippedChanged = Signal.new() -- (player : Player, itemType : String, itemName : string)
ItemService.ItemAcquired = Signal.new() -- (player : Player, itemType : String, itemName : string)

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

	ItemService.ItemAcquired:Fire(player, itemType, itemName)
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

	ItemService.EquippedChanged:Fire(player, itemType, itemName)
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
ProductService.ProductPurchased:Connect(function(player: Player, product: ProductConstants.Product)
	local itemType = product.Type
	if ItemConstants.Types[itemType] then
		ItemService.giveItem(player, itemType, product.Name)
	end
end)

QuestService.QuestCompleted:Connect(function(player: Player, quest: QuestConstants.Quest)
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
