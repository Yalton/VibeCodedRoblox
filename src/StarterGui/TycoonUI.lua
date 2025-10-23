-- Tycoon UI - Client-side UI for money display and upgrades
-- This is a LocalScript that should be placed in StarterGui

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for modules to load
local GameConfig = ReplicatedStorage:WaitForChild("GameConfig")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local config = require(GameConfig)
local remotes = require(RemoteEvents)

-- Player data
local playerMoney = 0
local spawnRateLevel = 0
local multiplierLevels = {}

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TycoonUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Money Display
local moneyFrame = Instance.new("Frame")
moneyFrame.Size = UDim2.new(0, 250, 0, 80)
moneyFrame.Position = UDim2.new(0, 20, 0, 20)
moneyFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
moneyFrame.BorderSizePixel = 0
moneyFrame.Parent = screenGui

local moneyCorner = Instance.new("UICorner")
moneyCorner.CornerRadius = UDim.new(0, 10)
moneyCorner.Parent = moneyFrame

local moneyLabel = Instance.new("TextLabel")
moneyLabel.Size = UDim2.new(1, -20, 0, 30)
moneyLabel.Position = UDim2.new(0, 10, 0, 10)
moneyLabel.BackgroundTransparency = 1
moneyLabel.Text = "Money"
moneyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
moneyLabel.Font = Enum.Font.GothamBold
moneyLabel.TextSize = 18
moneyLabel.TextXAlignment = Enum.TextXAlignment.Left
moneyLabel.Parent = moneyFrame

local moneyValue = Instance.new("TextLabel")
moneyValue.Size = UDim2.new(1, -20, 0, 35)
moneyValue.Position = UDim2.new(0, 10, 0, 35)
moneyValue.BackgroundTransparency = 1
moneyValue.Text = "$0"
moneyValue.TextColor3 = Color3.fromRGB(85, 255, 127)
moneyValue.Font = Enum.Font.GothamBold
moneyValue.TextSize = 28
moneyValue.TextXAlignment = Enum.TextXAlignment.Left
moneyValue.Parent = moneyFrame

-- Upgrades Frame
local upgradesFrame = Instance.new("Frame")
upgradesFrame.Size = UDim2.new(0, 300, 0, 400)
upgradesFrame.Position = UDim2.new(1, -320, 0, 20)
upgradesFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
upgradesFrame.BorderSizePixel = 0
upgradesFrame.Parent = screenGui

local upgradesCorner = Instance.new("UICorner")
upgradesCorner.CornerRadius = UDim.new(0, 10)
upgradesCorner.Parent = upgradesFrame

local upgradesTitle = Instance.new("TextLabel")
upgradesTitle.Size = UDim2.new(1, -20, 0, 40)
upgradesTitle.Position = UDim2.new(0, 10, 0, 10)
upgradesTitle.BackgroundTransparency = 1
upgradesTitle.Text = "UPGRADES"
upgradesTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
upgradesTitle.Font = Enum.Font.GothamBold
upgradesTitle.TextSize = 24
upgradesTitle.Parent = upgradesFrame

-- Scrolling frame for upgrades
local upgradesScroll = Instance.new("ScrollingFrame")
upgradesScroll.Size = UDim2.new(1, -20, 1, -60)
upgradesScroll.Position = UDim2.new(0, 10, 0, 50)
upgradesScroll.BackgroundTransparency = 1
upgradesScroll.BorderSizePixel = 0
upgradesScroll.ScrollBarThickness = 6
upgradesScroll.Parent = upgradesFrame

local upgradesLayout = Instance.new("UIListLayout")
upgradesLayout.Padding = UDim.new(0, 10)
upgradesLayout.Parent = upgradesScroll

-- Function to create upgrade button
local function createUpgradeButton(upgradeName, cost, level, upgradeType, currentLevel, isPurchased)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -10, 0, 70)
	button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Parent = upgradesScroll

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 8)
	buttonCorner.Parent = button

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -20, 0, 25)
	nameLabel.Position = UDim2.new(0, 10, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = upgradeName
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 16
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = button

	local costLabel = Instance.new("TextLabel")
	costLabel.Size = UDim2.new(1, -20, 0, 25)
	costLabel.Position = UDim2.new(0, 10, 0, 30)
	costLabel.BackgroundTransparency = 1
	costLabel.Text = "Cost: $" .. cost
	costLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	costLabel.Font = Enum.Font.Gotham
	costLabel.TextSize = 14
	costLabel.TextXAlignment = Enum.TextXAlignment.Left
	costLabel.Parent = button

	-- Update button state
	local function updateButton()
		if isPurchased then
			button.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
			costLabel.Text = "PURCHASED"
			costLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
			button.Active = false
		elseif playerMoney >= cost then
			if upgradeType == "SpawnRate" and level == currentLevel + 1 then
				button.BackgroundColor3 = Color3.fromRGB(80, 80, 255)
			elseif upgradeType == "Multiplier" and not multiplierLevels[level] then
				button.BackgroundColor3 = Color3.fromRGB(80, 80, 255)
			else
				button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			end
		else
			button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		end
	end

	updateButton()

	button.MouseButton1Click:Connect(function()
		if not isPurchased then
			-- Send purchase request
			remotes.PurchaseUpgrade:FireServer(upgradeType, level)
		end
	end)

	return button, updateButton
end

-- Store update functions
local upgradeButtons = {}

-- Function to refresh all upgrades
local function refreshUpgrades()
	-- Clear existing buttons
	for _, child in pairs(upgradesScroll:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	upgradeButtons = {}

	-- Spawn Rate Upgrades
	local spawnHeader = Instance.new("TextLabel")
	spawnHeader.Size = UDim2.new(1, -10, 0, 30)
	spawnHeader.BackgroundTransparency = 1
	spawnHeader.Text = "Spawn Rate Upgrades"
	spawnHeader.TextColor3 = Color3.fromRGB(255, 200, 100)
	spawnHeader.Font = Enum.Font.GothamBold
	spawnHeader.TextSize = 16
	spawnHeader.TextXAlignment = Enum.TextXAlignment.Left
	spawnHeader.Parent = upgradesScroll

	for i, upgrade in ipairs(config.Upgrades.SpawnRate) do
		local isPurchased = spawnRateLevel >= i
		local button, updateFunc = createUpgradeButton(
			upgrade.Name,
			upgrade.Cost,
			i,
			"SpawnRate",
			spawnRateLevel,
			isPurchased
		)
		table.insert(upgradeButtons, updateFunc)
	end

	-- Multiplier Gate Upgrades
	local multHeader = Instance.new("TextLabel")
	multHeader.Size = UDim2.new(1, -10, 0, 30)
	multHeader.BackgroundTransparency = 1
	multHeader.Text = "Multiplier Gates"
	multHeader.TextColor3 = Color3.fromRGB(255, 200, 100)
	multHeader.Font = Enum.Font.GothamBold
	multHeader.TextSize = 16
	multHeader.TextXAlignment = Enum.TextXAlignment.Left
	multHeader.Parent = upgradesScroll

	for i, upgrade in ipairs(config.Upgrades.Multipliers) do
		local isPurchased = multiplierLevels[i] or false
		local button, updateFunc = createUpgradeButton(
			upgrade.Name,
			upgrade.Cost,
			i,
			"Multiplier",
			0,
			isPurchased
		)
		table.insert(upgradeButtons, updateFunc)
	end

	-- Update scroll canvas size
	upgradesScroll.CanvasSize = UDim2.new(0, 0, 0, upgradesLayout.AbsoluteContentSize.Y)
end

-- Update money display
local function updateMoneyDisplay()
	moneyValue.Text = "$" .. math.floor(playerMoney)

	-- Update all upgrade buttons
	for _, updateFunc in pairs(upgradeButtons) do
		updateFunc()
	end
end

-- Listen for money updates
remotes.UpdateMoney.OnClientEvent:Connect(function(newMoney)
	playerMoney = newMoney
	updateMoneyDisplay()
end)

-- Listen for upgrade purchases
remotes.UpgradePurchased.OnClientEvent:Connect(function(upgradeType, level)
	if upgradeType == "SpawnRate" then
		spawnRateLevel = level
	elseif upgradeType == "Multiplier" then
		multiplierLevels[level] = true
	end
	refreshUpgrades()
end)

-- Get initial player data
task.spawn(function()
	task.wait(1) -- Wait for server to initialize
	local data = remotes.GetPlayerData:InvokeServer()
	if data then
		playerMoney = data.Money or 0
		spawnRateLevel = data.SpawnRateLevel or 0
		multiplierLevels = data.MultiplierLevels or {}

		updateMoneyDisplay()
		refreshUpgrades()
	end
end)

-- Initial setup
refreshUpgrades()

print("Tycoon UI initialized")
