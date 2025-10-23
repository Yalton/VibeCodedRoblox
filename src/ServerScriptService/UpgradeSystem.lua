-- Upgrade System - Handles purchase and application of upgrades
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerData = require(ReplicatedStorage:WaitForChild("PlayerData"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local UpgradeSystem = {}

function UpgradeSystem:Initialize(plotManager)
	self.PlotManager = plotManager

	-- Listen for upgrade purchases
	RemoteEvents.PurchaseUpgrade.OnServerEvent:Connect(function(player, upgradeType, level)
		self:PurchaseUpgrade(player, upgradeType, level)
	end)
end

function UpgradeSystem:PurchaseUpgrade(player, upgradeType, level)
	local playerData = PlayerData.Get(player)
	if not playerData then return end

	if upgradeType == "SpawnRate" then
		-- Purchase spawn rate upgrade
		if playerData:PurchaseSpawnRateUpgrade(level) then
			-- Notify client of successful purchase
			RemoteEvents.UpgradePurchased:FireClient(player, "SpawnRate", level)
			print(player.Name .. " purchased Spawn Rate upgrade level " .. level)
		else
			print(player.Name .. " failed to purchase Spawn Rate upgrade level " .. level)
		end

	elseif upgradeType == "Multiplier" then
		-- Purchase multiplier gate upgrade
		if playerData:PurchaseMultiplierUpgrade(level) then
			-- Create the physical gate in the world
			local plot = self.PlotManager:GetPlot(playerData.PlotId)
			if plot then
				local upgrade = GameConfig.Upgrades.Multipliers[level]
				self.PlotManager:CreateMultiplierGate(plot.Id, level, upgrade.Multiplier)
			end

			-- Notify client of successful purchase
			RemoteEvents.UpgradePurchased:FireClient(player, "Multiplier", level)
			print(player.Name .. " purchased Multiplier Gate level " .. level)
		else
			print(player.Name .. " failed to purchase Multiplier Gate level " .. level)
		end
	end
end

function UpgradeSystem:GetPlayerUpgradeStatus(player)
	local playerData = PlayerData.Get(player)
	if not playerData then return nil end

	return {
		SpawnRateLevel = playerData.SpawnRateLevel,
		MultiplierLevels = playerData.MultiplierLevels,
		Money = playerData.Money
	}
end

return UpgradeSystem
