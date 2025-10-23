-- Spawner System - Manages brick spawning for each plot
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local PlayerData = require(ReplicatedStorage:WaitForChild("PlayerData"))

local SpawnerSystem = {}
SpawnerSystem.ActiveSpawners = {}

function SpawnerSystem:StartSpawner(player, plot)
	-- Stop existing spawner if any
	if self.ActiveSpawners[player.UserId] then
		self:StopSpawner(player)
	end

	local spawnerData = {
		Player = player,
		Plot = plot,
		Running = true
	}

	self.ActiveSpawners[player.UserId] = spawnerData

	-- Spawn loop
	task.spawn(function()
		while spawnerData.Running and player.Parent do
			local playerData = PlayerData.Get(player)
			if not playerData then break end

			-- Get current spawn interval based on upgrades
			local interval = playerData:GetCurrentSpawnInterval()

			-- Create brick
			self:SpawnBrick(plot, player)

			-- Wait for next spawn
			task.wait(interval)
		end
	end)
end

function SpawnerSystem:SpawnBrick(plot, player)
	local brick = Instance.new("Part")
	brick.Name = "DropperBrick"
	brick.Size = GameConfig.BrickSize
	brick.Position = plot.SpawnerPosition
	brick.Anchored = false  -- Allow brick to fall and move
	brick.BrickColor = BrickColor.new("Bright red")
	brick.Material = Enum.Material.SmoothPlastic
	brick.Parent = workspace

	-- Add ownership tag
	local ownerValue = Instance.new("ObjectValue")
	ownerValue.Name = "Owner"
	ownerValue.Value = player
	ownerValue.Parent = brick

	-- Add value tag (starts at base value)
	local valueTag = Instance.new("NumberValue")
	valueTag.Name = "BrickValue"
	valueTag.Value = GameConfig.BrickBasicValue
	valueTag.Parent = brick

	-- Add multiplier tracking
	local multiplierTag = Instance.new("NumberValue")
	multiplierTag.Name = "Multiplier"
	multiplierTag.Value = 1
	multiplierTag.Parent = brick

	-- Add plot ID tag
	local plotTag = Instance.new("IntValue")
	plotTag.Name = "PlotId"
	plotTag.Value = plot.Id
	plotTag.Parent = brick

	-- Clean up old bricks after some time
	task.delay(30, function()
		if brick.Parent then
			brick:Destroy()
		end
	end)

	return brick
end

function SpawnerSystem:StopSpawner(player)
	if self.ActiveSpawners[player.UserId] then
		self.ActiveSpawners[player.UserId].Running = false
		self.ActiveSpawners[player.UserId] = nil
	end
end

return SpawnerSystem
