-- LevelServiceClient
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.Packages.Networker)
local LevelServiceUtils = require(script.Parent.LevelServiceUtils)
local Data = require(ReplicatedStorage.Shared.Data).client
local Player = Players.LocalPlayer

local LevelServiceClient = {}

function LevelServiceClient.LevelUpdated(self: LevelServiceClient, player)
	if player == Player then
		return
	end

	LevelServiceUtils.PlayLevelUp_Vfx(player.Character)
	LevelServiceUtils.PlayLevelUp_Sound(player.Character)
end

function LevelServiceClient.init(self: LevelServiceClient)
	self.Tags = {
		MainScreen = "LevelScreen",
		ShowLevel_Label = "LevelLabel",
		ShowXP_MaxBar = "XP_MaxBar",
		ShowXP_CurrBar = "XP_CurrBar",
		ShowXP_Label = "XPLabel",
		ShowLevelNotice_Label = "LevelNoticeLabel",
	}
	self._LevelNoticeToken = 0

	self.Networker = Networker.client.new("LevelService", self)

	local PlayerGui: PlayerGui = Player:WaitForChild("PlayerGui")
	local LevelScreen: ScreenGui = LevelServiceUtils.GetInstanceWithTag(PlayerGui, self.Tags.MainScreen)
	if not LevelScreen then
		warn("[LevelServiceClient] LevelScreen not found.")
		return
	end

	self.LevelLabel = LevelServiceUtils.GetInstanceWithTag(LevelScreen, self.Tags.ShowLevel_Label)
	self.LevelNoticeLabel = LevelServiceUtils.GetInstanceWithTag(LevelScreen, self.Tags.ShowLevelNotice_Label)
	self.XPMaxBar = LevelServiceUtils.GetInstanceWithTag(LevelScreen, self.Tags.ShowXP_MaxBar)
	self.XPCurrBar = LevelServiceUtils.GetInstanceWithTag(LevelScreen, self.Tags.ShowXP_CurrBar)
	self.XPLabel = LevelServiceUtils.GetInstanceWithTag(LevelScreen, self.Tags.ShowXP_Label)

	if self.LevelNoticeLabel then
		self.LevelNoticeLabel.Visible = false
	end

	self:RefreshUI()

	Data.Level.Changed(function(lvl)
		LevelServiceUtils.PlayLevelUp_Vfx(Player.Character)
		LevelServiceUtils.PlayLevelUp_Sound(Player.Character)

		if self.LevelNoticeLabel then
			self._LevelNoticeToken += 1
			local token = self._LevelNoticeToken
			self.LevelNoticeLabel.Visible = true
			self.LevelNoticeLabel.Text = "YOU LEVELED UP! NEW LEVEL: " .. tostring(lvl)
			task.delay(1, function()
				if self.LevelNoticeLabel and self._LevelNoticeToken == token then
					self.LevelNoticeLabel.Visible = false
				end
			end)
		end

		self:RefreshUI()
	end)

	Data.XP.Changed(function()
		self:RefreshUI()
	end)
end

function LevelServiceClient.RefreshUI(self: LevelServiceClient)
	if not self.LevelLabel or not self.XPMaxBar or not self.XPCurrBar then
		return
	end

	local level = Data.Level()
	local currentXP = Data.XP()
	local requiredXP = LevelServiceUtils:CalculateXP(level) or 0

	self.LevelLabel.Text = "Level " .. tostring(level)
	LevelServiceUtils:UpdateXP_UI(self.XPMaxBar, self.XPCurrBar, self.XPLabel, currentXP, requiredXP)
end

type LevelServiceClient = typeof(LevelServiceClient) & {
	Tags: {
		MainScreen: string,
		ShowLevel_Label: string,
		ShowXP_MaxBar: string,
		ShowXP_CurrBar: string,
		ShowXP_Label: string,
		ShowLevelNotice_Label: string,
	},
	LevelLabel: TextLabel?,
	LevelNoticeLabel: TextLabel?,
	XPMaxBar: GuiObject?,
	XPCurrBar: GuiObject?,
	XPLabel: TextLabel?,
	_LevelNoticeToken: number,
	Networker: Networker.Client,
}

return LevelServiceClient :: LevelServiceClient
