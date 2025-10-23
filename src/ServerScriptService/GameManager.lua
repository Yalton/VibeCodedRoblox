-- Game Manager - Main server script that initializes all systems
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for all modules to load
local PlayerData = require(ReplicatedStorage:WaitForChild("PlayerData"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local PlotManager = require(script.Parent:WaitForChild("PlotManager"))
local SpawnerSystem = require(script.Parent:WaitForChild("SpawnerSystem"))
local ConveyorSystem = require(script.Parent:WaitForChild("ConveyorSystem"))
local SellSystem = require(script.Parent:WaitForChild("SellSystem"))
local UpgradeSystem = require(script.Parent:WaitForChild("UpgradeSystem"))

print("Initializing Dropper Tycoon Game...")

-- Initialize all systems
PlotManager:Initialize()
print("Plot Manager initialized - Created 4 plots")

ConveyorSystem:Initialize(PlotManager)
print("Conveyor System initialized")

SellSystem:Initialize(PlotManager)
print("Sell System initialized")

UpgradeSystem:Initialize(PlotManager)
print("Upgrade System initialized")

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
	print(player.Name .. " joined the game")

	-- Create player data
	local data = PlayerData.new(player)

	-- Wait for player to claim a plot (via touch detection in PlotManager)
	-- Check periodically if player has claimed a plot
	task.spawn(function()
		local maxWaitTime = 60 -- Wait up to 60 seconds for player to claim
		local waitedTime = 0

		while waitedTime < maxWaitTime and player.Parent do
			task.wait(1)
			waitedTime = waitedTime + 1

			if data.PlotId then
				-- Player has claimed a plot, start their spawner
				local plot = PlotManager:GetPlot(data.PlotId)
				if plot then
					SpawnerSystem:StartSpawner(player, plot)
					print(player.Name .. " claimed plot " .. data.PlotId .. " - Spawner started")
					break
				end
			end
		end
	end)
end)

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
	print(player.Name .. " left the game")

	-- Stop spawner
	SpawnerSystem:StopSpawner(player)

	-- Remove player data
	local data = PlayerData.Get(player)
	if data then
		-- Release plot
		local plot = PlotManager:GetPlot(data.PlotId)
		if plot then
			plot.Owner = nil
			print("Released plot " .. data.PlotId)
		end

		data:Destroy()
	end
end)

-- Setup GetPlayerData remote function
RemoteEvents.GetPlayerData.OnServerInvoke = function(player)
	local data = PlayerData.Get(player)
	if data then
		return {
			Money = data.Money,
			SpawnRateLevel = data.SpawnRateLevel,
			MultiplierLevels = data.MultiplierLevels,
			PlotId = data.PlotId
		}
	end
	return nil
end

print("Game Manager initialized - Game ready!")
