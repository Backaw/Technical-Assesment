local PriceLabel = {}

local Players = game:GetService("Players")
local Paths = require(Players.LocalPlayer.PlayerScripts.Paths)
local Component = require(Paths.controllers.UI.Components.Component)
local CurrencyConstants = require(Paths.shared.Currency.CurrencyConstants)
local TemplateUtil = require(Paths.shared.Utils.TemplateUtil)
local UIScaleController = require(Paths.controllers.UI.UIScaleController)
local Images = require(Paths.shared.Images)
local StringUtil = require(Paths.shared.Utils.StringUtil)
local TextLabelUtil = require(Paths.controllers.UI.Utils.TextLabelUtil)

export type PriceLabel = typeof(PriceLabel.new())

function PriceLabel.new()
	local priceLabel = Component.new()

	-------------------------------------------------------------------------------
	-- PRIVATE MEMBERS
	-------------------------------------------------------------------------------
	local components = TemplateUtil.cloneChildren(TemplateUtil.getFromStorage("Components", "Price"))

	local label: TextLabel = components.TextLabel
	local icon: ImageLabel = components.Icon
	local uiListLayout: UIListLayout = components.UIListLayout

	local textSize: number

	-------------------------------------------------------------------------------
	-- PRIVATE METHODS
	-------------------------------------------------------------------------------
	local function setText(text: string)
		label.TextSize = textSize
		TextLabelUtil.setScaleableText(label, text)
	end

	-------------------------------------------------------------------------------
	-- PUBLIC MEMBERS
	-------------------------------------------------------------------------------
	-- Set price before mounting
	function priceLabel:Mount(parent: GuiObject, hideBackground: boolean?)
		label.Parent = parent
		icon.Parent = parent
		uiListLayout.Parent = parent

		textSize = label:FindFirstAncestorWhichIsA("GuiObject").AbsoluteSize.Y / UIScaleController.getScale()
		parent.BackgroundTransparency = if hideBackground then 1 else parent.BackgroundTransparency
	end

	function priceLabel:Align(alignment: Enum.HorizontalAlignment)
		uiListLayout.HorizontalAlignment = alignment
	end

	function priceLabel:EnableOwned()
		setText("Owned")
		label.TextColor3 = Color3.fromRGB(255, 255, 255)

		icon.Visible = false
	end

	function priceLabel:SetPrice(price: CurrencyConstants.Price, count: number?)
		local currency = price.Currency

		if currency == CurrencyConstants.Currencies.Coins then
			setText(StringUtil.getCompactNumber(price.Amount * (count or 1)) .. if count then (" (%s)"):format(count) else "")
			label.TextColor3 = Color3.fromRGB(139, 255, 49)

			icon.Image = Images.Currencies.Coin
			icon.Visible = true
		elseif currency == CurrencyConstants.Currencies.DevProduct or currency == CurrencyConstants.Currencies.GamePass then
			setText(if price.PriceInRobux then StringUtil.commafiedNumber(tostring(price.PriceInRobux)) else "nil")
			label.TextColor3 = Color3.fromRGB(255, 255, 255)

			icon.Visible = true
			icon.Image = Images.Currencies.Robux
		else
			setText("Free")
			label.TextColor3 = Color3.fromRGB(255, 255, 255)

			icon.Visible = false
		end
	end

	-------------------------------------------------------------------------------
	-- LOGIC
	-------------------------------------------------------------------------------
	for _, component in pairs(components) do
		priceLabel:GetMaid():Add(component)
	end

	return priceLabel
end

return PriceLabel
