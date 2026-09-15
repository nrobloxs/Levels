local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local LevelServiceUtils = require(ReplicatedStorage.Shared.Services.LevelService.LevelServiceUtils)
local LevelServiceServer = require(script.Services.LevelService.LevelServiceServer)

LevelServiceUtils:init()
LevelServiceServer:init()

Players.PlayerAdded:Connect(function(player: Player)
	Data.Service:waitForData(player)
	warn("[SERVER] DATA LOADED FOR PLAYER: ", player.Name)
end)
