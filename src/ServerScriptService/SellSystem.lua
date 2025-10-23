-- Sell System - Handles selling bricks for money
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerData = require(ReplicatedStorage:WaitForChild("PlayerData"))

local SellSystem = {}

function SellSystem:Initialize(plotManager)
	self.PlotManager = plotManager

	-- Monitor all plots for bricks entering sell areas
	for _, plot in pairs(plotManager.Plots) do
		if plot.SellArea then
			plot.SellArea.Touched:Connect(function(hit)
				self:OnBrickTouched(hit, plot)
			end)
		end
	end
end

function SellSystem:OnBrickTouched(part, plot)
	if part.Name == "DropperBrick" then
		-- Verify ownership
		local ownerValue = part:FindFirstChild("Owner")
		local plotIdValue = part:FindFirstChild("PlotId")
		local brickValue = part:FindFirstChild("BrickValue")

		if ownerValue and plotIdValue and brickValue then
			-- Check if brick belongs to this plot
			if plotIdValue.Value == plot.Id then
				local player = ownerValue.Value
				if player and player.Parent then
					-- Get player data
					local playerData = PlayerData.Get(player)
					if playerData then
						-- Add money
						local moneyEarned = brickValue.Value
						playerData:AddMoney(moneyEarned)

						-- Create sell effect
						self:CreateSellEffect(part, moneyEarned)

						-- Destroy brick
						part:Destroy()
					end
				else
					-- Owner left, destroy brick
					part:Destroy()
				end
			end
		end
	end
end

function SellSystem:CreateSellEffect(brick, value)
	-- Create money display
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.new(0, 100, 0, 50)
	billboardGui.StudsOffset = Vector3.new(0, 3, 0)
	billboardGui.Parent = workspace

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "+$" .. math.floor(value)
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = billboardGui

	-- Position at brick location
	billboardGui.Adornee = brick

	-- Animate upward and fade out
	task.spawn(function()
		for i = 1, 20 do
			if billboardGui.Parent then
				billboardGui.StudsOffset = billboardGui.StudsOffset + Vector3.new(0, 0.1, 0)
				textLabel.TextTransparency = i / 20
			end
			task.wait(0.05)
		end
		billboardGui:Destroy()
	end)

	-- Particle effect
	local particle = Instance.new("ParticleEmitter")
	particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particle.Rate = 100
	particle.Lifetime = NumberRange.new(0.3, 0.5)
	particle.Speed = NumberRange.new(10)
	particle.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0))
	particle.Enabled = false
	particle.Parent = brick

	particle:Emit(20)

	task.delay(1, function()
		if particle.Parent then
			particle:Destroy()
		end
	end)
end

return SellSystem
