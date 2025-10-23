-- Game Configuration
local GameConfig = {}

-- Plot Settings
GameConfig.MaxPlots = 4
GameConfig.PlotSize = Vector3.new(50, 1, 80)
GameConfig.PlotSpacing = 10

-- Spawner Settings
GameConfig.BaseSpawnInterval = 3 -- seconds between brick drops
GameConfig.BrickSize = Vector3.new(4, 4, 4)
GameConfig.BrickBasicValue = 10 -- base money per brick

-- Conveyor Settings
GameConfig.ConveyorSpeed = 10 -- studs per second
GameConfig.ConveyorWidth = 10
GameConfig.ConveyorLength = 60

-- Upgrade Costs and Effects
GameConfig.Upgrades = {
	SpawnRate = {
		{Cost = 100, Interval = 2.5, Name = "Spawn Rate 1"},
		{Cost = 500, Interval = 2.0, Name = "Spawn Rate 2"},
		{Cost = 2000, Interval = 1.5, Name = "Spawn Rate 3"},
		{Cost = 10000, Interval = 1.0, Name = "Spawn Rate 4"},
		{Cost = 50000, Interval = 0.5, Name = "Spawn Rate 5"},
	},
	Multipliers = {
		{Cost = 500, Multiplier = 2, Name = "2x Multiplier Gate"},
		{Cost = 5000, Multiplier = 3, Name = "3x Multiplier Gate"},
		{Cost = 25000, Multiplier = 5, Name = "5x Multiplier Gate"},
	}
}

-- Colors
GameConfig.PlotColors = {
	Color3.fromRGB(255, 100, 100), -- Red
	Color3.fromRGB(100, 150, 255), -- Blue
	Color3.fromRGB(100, 255, 100), -- Green
	Color3.fromRGB(255, 255, 100), -- Yellow
}

return GameConfig
