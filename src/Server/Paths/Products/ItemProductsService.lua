local ItemProductsService = {}

local ServerScriptService = game:GetService("ServerScriptService")
local Paths = require(ServerScriptService.Paths)
local ProductService = require(Paths.Services.Products.ProductService)
local ProductConstants = require(Paths.Shared.Products.ProductConstants)
local ItemUtil = require(Paths.Shared.Items.ItemUtil)
--[[
local ItemConstants = require(Paths.Shared.Items.ItemConstants)
local RotatingProductConstants = require(Paths.Shared.Products.RotatingProductConstants)
local RotatingShopUtil = require(Paths.Shared.Products.RotatingShopUtil)
local RarityUtil = require(Paths.Shared.Rarity.RarityUtil)
local RarityConstants = require(Paths.Shared.Rarity.RarityConstants)
local TableUtil = require(Paths.Shared.Utils.TableUtil)
 *]]

-- Generate items from product
do
	local products: ProductConstants.ProductCategories = {}
	for itemType, items in pairs(ItemUtil.getItems()) do
		if not ProductConstants.Types[itemType] then
			continue
		end

		local productsOfType: ProductConstants.ProductList = {}

		for itemName, item in pairs(items) do
			local source = item.Source
			if source and source.Currency then
				productsOfType[itemName] = {
					Icon = item.Icon,
					Price = source,
				}
			end
		end

		products[itemType] = productsOfType
	end

	-- if products ~= {} then
	ProductService.updateProducts(products)
	-- end
end

--[[
-- Rotating shop products
do
	local lastProducts: ProductConstants.ProductCategories
	local rotatingItems: { [string]: { ItemConstants.Item } } = {}

	for itemType, items in pairs(ItemUtil.getItems()) do
		-- CONTINUE: No rotating items of this type
		if not RotatingShopUtil.isItemTypeSold(itemType) then
			continue
		end

		rotatingItems[itemType] = {}

		for _, item in pairs(items) do
			local source = item.Source
			if source and source.Name and RarityConstants.Rarities[source.Name] then
				table.insert(rotatingItems[itemType], item)
			end
		end
	end

	task.spawn(function()
		while true do
			local newProducts: ProductConstants.ProductCategories = {}

			local timeSinceStart = RotatingShopUtil.getTimeSinceStart()
			local random = Random.new(math.floor(timeSinceStart / RotatingProductConstants.RefreshDelay))

			for itemType, items in pairs(rotatingItems) do
				items = table.clone(items)

				local sellThisMany = math.min(#items, RotatingProductConstants.ItemsPerType[itemType])

				newProducts[itemType] = {}

				for _ = 1, sellThisMany do
					local chosen = RarityUtil.draw(TableUtil.getProperties(items, "Source"), nil, random)
					local item = items[chosen]

					newProducts[itemType][item.Name] = {
						Name = item.Name,
						Type = itemType,
						Icon = item.Icon,
						Price = RotatingProductConstants.Prices[item.Source][itemType],
						LimitedTime = true,
					}

					table.remove(items, chosen)
				end
			end

			ProductService.updateProducts(newProducts, lastProducts)
			lastProducts = newProducts

			local cooldown = RotatingShopUtil.getRotationCooldown()
			task.wait(cooldown)
		end
	end)
end
 *]]

return ItemProductsService
