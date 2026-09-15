-- LevelServiceServer
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.Packages.Networker)
local LevelServiceUtils = require(ReplicatedStorage.Shared.Services.LevelService.LevelServiceUtils)
local Data = require(ReplicatedStorage.Shared.Data).server

local LevelServiceServer = {}

function LevelServiceServer.init(self: LevelServiceServer)
	self.Level_Config = {
		Max_Level = 2500,
	}

	self.Networker = Networker.server.new("LevelService", self, {})

	Players.PlayerAdded:Connect(function(player: Player)
		Data.Service:waitForData(player)
		Data[player].Level.Changed(function(_)
			self.Networker:fireAll("LevelUpdated", player)
		end)
	end)
end

function LevelServiceServer.SetLevel(self: LevelServiceServer, player: Player, Level: number)
	if not player or not Data[player] or typeof(Level) ~= "number" then
		return
	end

	if Level < 1 then
		return
	end

	if LevelServiceUtils.IsGreaterThanMaxLvl(self.Level_Config.Max_Level, Level) then
		return
	end

	Data[player].Level(Level)
end

function LevelServiceServer.IncrementLevel(self: LevelServiceServer, player: Player, Increment: number)
	if not player or not Data[player] or typeof(Increment) ~= "number" then
		return
	end

	if Increment <= 0 then
		return
	end

	local nextLevel = Data[player].Level() + Increment
	if LevelServiceUtils.IsGreaterThanMaxLvl(self.Level_Config.Max_Level, nextLevel) then
		return
	end

	Data[player].Level(function(currentLevel)
		return currentLevel + Increment
	end)
end

function LevelServiceServer.DecrementLevel(self: LevelServiceServer, player: Player, Decrement: number)
	if not player or not Data[player] or typeof(Decrement) ~= "number" then
		return
	end

	if Decrement <= 0 then
		return
	end

	local targetLevel = Data[player].Level() - Decrement
	if targetLevel < 1 then
		return
	end

	Data[player].Level(function(currentLevel)
		return currentLevel - Decrement
	end)
end

function LevelServiceServer.GiveXP(self: LevelServiceServer, player: Player, Amount: number)
	if not player or not Data[player] or typeof(Amount) ~= "number" then
		return
	end

	if Amount <= 0 then
		return
	end

	local startingLevel = Data[player].Level()
	local levelsGained = 0
	local newXP = Data[player].XP() + Amount
	local currentLevel = startingLevel

	while not LevelServiceUtils.IsGreaterThanMaxLvl(self.Level_Config.Max_Level, currentLevel + 1) do
		local requiredXP = LevelServiceUtils:CalculateXP(currentLevel)
		if not requiredXP or newXP < requiredXP then
			break
		end

		newXP -= requiredXP
		currentLevel += 1
		levelsGained += 1
	end

	if LevelServiceUtils.IsGreaterThanMaxLvl(self.Level_Config.Max_Level, currentLevel + 1) then
		local maxLevelXP = LevelServiceUtils:CalculateXP(currentLevel) or 0
		newXP = math.min(newXP, maxLevelXP)
	end

	Data[player].XP(newXP)

	if levelsGained > 0 then
		self:IncrementLevel(player, levelsGained)
	end
end

function LevelServiceServer.RemoveXP(self: LevelServiceServer, player: Player, Amount: number)
	if not player or not Data[player] or typeof(Amount) ~= "number" then
		return
	end

	if Amount <= 0 then
		return
	end

	local currentLevel = Data[player].Level()
	local levelsLost = 0
	local newXP = Data[player].XP() - Amount

	while newXP < 0 and currentLevel > 1 do
		currentLevel -= 1
		levelsLost += 1
		newXP += LevelServiceUtils:CalculateXP(currentLevel) or 0
	end

	Data[player].XP(math.max(0, newXP))

	if levelsLost > 0 then
		self:DecrementLevel(player, levelsLost)
	end
end

type LevelServiceServer = typeof(LevelServiceServer) & {
	Level_Config: {
		Max_Level: number,
	},
	Networker: Networker.Server,
}

return LevelServiceServer :: LevelServiceServer
