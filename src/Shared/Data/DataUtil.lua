--[[
    A utility for interfacing with a table(Datastores) via addresss
    A address is just a sequence of keys seperated by a delimiter that point you to a value in a dictionary (Ex: "Home/Left/Right" or "Home.Left.Right")
    Any non-alphanumeric characters are valid delimiters except for underscores
]]

local DataUtil = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TableUtil = require(ReplicatedStorage.Modules.Utils.TableUtil)
local ArrayUtil = require(ReplicatedStorage.Modules.Utils.ArrayUtil)
local DataConstants = require(ReplicatedStorage.Modules.Data.DataConstants)
local GameUtil = require(ReplicatedStorage.Modules.Game.GameUtil)
export type Data = string | number | boolean | Store
export type Store = { [string]: Data }

-------------------------------------------------------------------------------
-- PRIVATE METHODS
-------------------------------------------------------------------------------
local function setFromKeys(store: Store, keys: { string }, newValue: any)
	if #keys == 1 then -- Base case
		newValue = if typeof(newValue) == "table" then TableUtil.deepClone(newValue) else newValue
		store[keys[1]] = newValue

		return newValue
	else -- Recursive case
		local key = table.remove(keys, 1)
		return setFromKeys(store[key], keys, newValue)
	end
end

--[[
    Generates an array of table keys(directions) from a string formatted like a address
]]
local function getKeysFromAddress(address: string): { string }
	local keys = {}

	for word in string.gmatch(address, "[%w(_)]+") do
		table.insert(keys, word)
	end

	return keys
end

-------------------------------------------------------------------------------
-- PUBLIC METHODS
-------------------------------------------------------------------------------
--[[
    Retrieves a value stored in an array
]]
function DataUtil.getFromAddress(store: Store, address: string): Data
	local keys = getKeysFromAddress(address)
	for i = 1, #keys do
		store = store[keys[i]]
	end

	return store
end

--[[
    Set a value in table using an array of keys point to it's new location in the table
]]
function DataUtil.setFromAddress(store: Store, address: string, newValue: any): Data
	return setFromKeys(store, getKeysFromAddress(address), newValue)
end

function DataUtil.getDataKey()
	local prefix = if GameUtil.isLive() then "Live" else (if GameUtil.isQA() then "QA" else "Dev")
	return prefix .. DataConstants.Version[prefix]
end

return DataUtil
