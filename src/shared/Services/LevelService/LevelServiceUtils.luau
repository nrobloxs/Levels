local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LevelServiceUtils = {}

function LevelServiceUtils.init(self: LevelServiceUtils)
	self.XP_Config = {
		BASE_XP = 100,
		GROWTH_RATE = 1.15,
		LINEAR_BONUS = 50,
	}

	self.BarTweenInfo = {
		Duration = 0.3,
		EaseStyle = Enum.EasingStyle.Sine,
		EaseDirection = Enum.EasingDirection.InOut,
	}
end

function LevelServiceUtils.CalculateXP(self: LevelServiceUtils, Level: number): number?
	if typeof(Level) ~= "number" or Level < 1 then
		return nil
	end

	local exponential = self.XP_Config.BASE_XP * (self.XP_Config.GROWTH_RATE ^ (Level - 1))
	local linear = self.XP_Config.LINEAR_BONUS * (Level - 1)
	return math.floor(exponential + linear)
end

function LevelServiceUtils.IsGreaterThanMaxLvl(MaxLvl: number, Level: number): boolean
	if typeof(MaxLvl) ~= "number" or typeof(Level) ~= "number" then
		return false
	end

	if MaxLvl <= 0 then
		return false
	end

	return Level > MaxLvl
end

function LevelServiceUtils.GetInstanceWithTag(Container: Instance, tag: string)
	if not Container or typeof(tag) ~= "string" or tag == "" then
		return nil
	end

	if CollectionService:HasTag(Container, tag) then
		return Container
	end

	for _, instance in Container:GetDescendants() do
		if CollectionService:HasTag(instance, tag) then
			return instance
		end
	end

	return nil
end

function LevelServiceUtils.PlayLevelUp_Vfx(Character: Model)
	if not Character or not Character:FindFirstChild("HumanoidRootPart") then
		return
	end

	local AssetsFolder = ReplicatedStorage:FindFirstChild("Assets")
	if not AssetsFolder then
		return
	end

	local VfxFolder = AssetsFolder:FindFirstChild("Vfx")
	if not VfxFolder then
		return
	end

	local LevelFolder = VfxFolder:FindFirstChild("Level")
	if not LevelFolder then
		return
	end

	task.spawn(function()
		for _, vfx in LevelFolder:GetDescendants() do
			if vfx:IsA("ParticleEmitter") then
				local clonedVfx = vfx:Clone()
				clonedVfx.Parent = Character.HumanoidRootPart
				clonedVfx:Emit(clonedVfx:GetAttribute("EmitCount") or 25)
				Debris:AddItem(clonedVfx, 2)
			end
		end
	end)
end

function LevelServiceUtils.PlayLevelUp_Sound(Character: Model)
	if not Character or not Character:FindFirstChild("HumanoidRootPart") then
		return
	end

	local AssetsFolder = ReplicatedStorage:FindFirstChild("Assets")
	if not AssetsFolder then
		return
	end

	local AudioFolder = AssetsFolder:FindFirstChild("Audio")
	if not AudioFolder then
		return
	end

	local LevelFolder = AudioFolder:FindFirstChild("Level")
	if not LevelFolder then
		return
	end

	local LevelUpSound = LevelFolder:FindFirstChild("LevelUp") :: Sound
	if not LevelUpSound then
		return
	end

	local ClonedLevelUpSound = LevelUpSound:Clone()
	ClonedLevelUpSound.Parent = Character.HumanoidRootPart
	ClonedLevelUpSound:Play()
	Debris:AddItem(ClonedLevelUpSound, 3)
end

function LevelServiceUtils.UpdateXP_UI(
	self: LevelServiceUtils,
	MaxBar: GuiObject,
	CurrentBar: GuiObject,
	XPLabel: TextLabel?,
	XP: number,
	MaxXP: number?
)
	if not MaxBar or not CurrentBar then
		return
	end

	local safeMaxXP = MaxXP or 0
	local ratio = (safeMaxXP > 0) and math.clamp(XP / safeMaxXP, 0, 1) or 0
	local tweenInfo = TweenInfo.new(
		self.BarTweenInfo.Duration,
		self.BarTweenInfo.EaseStyle,
		self.BarTweenInfo.EaseDirection,
		0,
		false,
		0
	)

	TweenService:Create(CurrentBar, tweenInfo, {
		Size = UDim2.fromScale(ratio, 1),
	}):Play()

	if XPLabel then
		XPLabel.Text = "XP " .. tostring(XP) .. "/" .. tostring(safeMaxXP)
	end
end

type LevelServiceUtils = typeof(LevelServiceUtils) & {
	XP_Config: {
		BASE_XP: number,
		GROWTH_RATE: number,
		LINEAR_BONUS: number,
	},

	BarTweenInfo: {
		Duration: number,
		EaseStyle: Enum.EasingStyle,
		EaseDirection: Enum.EasingDirection,
	},
}

return LevelServiceUtils :: LevelServiceUtils
