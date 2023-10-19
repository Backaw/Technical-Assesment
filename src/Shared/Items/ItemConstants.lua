local ItemConstants = {}

ItemConstants.Types = {
	Tool = "Tool",
}

ItemConstants.Items = {}
for itemType in pairs(ItemConstants.Types) do
	local items = require(script.Parent[itemType .. "Items"]).Items
	ItemConstants.Items[itemType] = items

	for key, item in pairs(items) do
		item.Name = key
	end
end

return ItemConstants
