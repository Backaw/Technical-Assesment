local RarityUtil = {}

local random = Random.new()

export type Rarity = { Name: string, Probability: number } & table

local function getProbability(choice: table)
	return if choice.Rarity then choice.Rarity.Probability else choice.Probability
end

function RarityUtil.draw(pool: table, luck: number?)
	local perfectSplit = 100

	luck = luck or 0
	local sum = 0
	for _, choice in pairs(pool) do
		local probability = getProbability(choice)
		sum += probability + (perfectSplit - probability) * luck
	end

	local chosen = random:NextNumber(0, sum)
	for k, choice in pairs(pool) do
		local probability = getProbability(choice)
		probability += (perfectSplit - probability) * luck

		if chosen <= probability then
			return k
		else
			chosen -= probability
		end
	end
end

return RarityUtil
