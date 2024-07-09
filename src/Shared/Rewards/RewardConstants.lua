local RewardConstants = {}
export type Reward = {
	Type: "Currency",
	Currency: string,
	Amount: number,
} | {
	Type: "Boost",
	Name: string,
	LengthInMinutes: number,
} | {
	Type: "Item",
	ItemType: string,
	ItemName: string,
	Loan: boolean?,
}
RewardConstants.Types = {
	Item = "Item",
	Currency = "Currency",
	Boost = "Boost",
}

return RewardConstants
