-- Player Data Management
local PlayerData = {}
PlayerData.__index = PlayerData

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local playerDataStore = {}

function PlayerData.new(player)
	local self = setmetatable({}, PlayerData)

	self.Player = player
	self.Money = 0
	self.PlotId = nil
	self.SpawnRateLevel = 0
	self.MultiplierLevels = {} -- Track which multiplier gates are purchased

	playerDataStore[player.UserId] = self
	return self
end

function PlayerData.Get(player)
	return playerDataStore[player.UserId]
end

function PlayerData:AddMoney(amount)
	self.Money = self.Money + amount
	RemoteEvents.UpdateMoney:FireClient(self.Player, self.Money)
end

function PlayerData:RemoveMoney(amount)
	if self.Money >= amount then
		self.Money = self.Money - amount
		RemoteEvents.UpdateMoney:FireClient(self.Player, self.Money)
		return true
	end
	return false
end

function PlayerData:GetCurrentSpawnInterval()
	if self.SpawnRateLevel == 0 then
		return GameConfig.BaseSpawnInterval
	else
		return GameConfig.Upgrades.SpawnRate[self.SpawnRateLevel].Interval
	end
end

function PlayerData:CanAffordUpgrade(upgradeType, level)
	local upgrade
	if upgradeType == "SpawnRate" then
		upgrade = GameConfig.Upgrades.SpawnRate[level]
	elseif upgradeType == "Multiplier" then
		upgrade = GameConfig.Upgrades.Multipliers[level]
	end

	if upgrade then
		return self.Money >= upgrade.Cost
	end
	return false
end

function PlayerData:PurchaseSpawnRateUpgrade(level)
	local upgrade = GameConfig.Upgrades.SpawnRate[level]
	if upgrade and self:CanAffordUpgrade("SpawnRate", level) and level == self.SpawnRateLevel + 1 then
		if self:RemoveMoney(upgrade.Cost) then
			self.SpawnRateLevel = level
			return true
		end
	end
	return false
end

function PlayerData:PurchaseMultiplierUpgrade(level)
	local upgrade = GameConfig.Upgrades.Multipliers[level]
	if upgrade and self:CanAffordUpgrade("Multiplier", level) and not self.MultiplierLevels[level] then
		if self:RemoveMoney(upgrade.Cost) then
			self.MultiplierLevels[level] = true
			return true
		end
	end
	return false
end

function PlayerData:GetMultiplierAtPosition(position)
	-- Returns the total multiplier that should apply to a brick at given position
	-- This will be calculated based on which multiplier gates the brick has passed through
	return 1
end

function PlayerData:Destroy()
	playerDataStore[self.Player.UserId] = nil
end

return PlayerData
