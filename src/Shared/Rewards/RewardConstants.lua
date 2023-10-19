local RewardConstants = {}

export type Reward = {
	Type: "Coin",
	Amount: number,
} | {
	Type: "Item",
	ItemType: string,
	ItemName: string,
	Loan: boolean,
}

RewardConstants.Types = {
	Item = "Item",
	Coin = "Coin",
}

return RewardConstants
