local RewardConstants = {}

export type Reward = {
	Type: "Coin",
	Currency: string,
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
