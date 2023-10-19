local GameUtil = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConstants = require(ReplicatedStorage.Modules.Game.GameConstants)

local placeId = game.PlaceId

function GameUtil.isLive()
	return placeId == GameConstants.Places.Live
end

function GameUtil.isQA()
	return placeId == GameConstants.Places.QA
end

function GameUtil.isDev()
	return not (GameUtil.isLive() or GameUtil.isQA())
end

return GameUtil
