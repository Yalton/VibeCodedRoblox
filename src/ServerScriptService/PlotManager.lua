-- Plot Manager - Creates and assigns plots to players
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local PlotManager = {}
PlotManager.Plots = {}

-- Create a folder for plots in workspace
local PlotsFolder = Workspace:FindFirstChild("Plots")
if not PlotsFolder then
	PlotsFolder = Instance.new("Folder")
	PlotsFolder.Name = "Plots"
	PlotsFolder.Parent = Workspace
end

function PlotManager:CreatePlot(plotId)
	local plotData = {
		Id = plotId,
		Owner = nil,
		Model = Instance.new("Model"),
		SpawnerPosition = nil,
		ConveyorStart = nil,
		ConveyorEnd = nil,
		SellArea = nil,
		MultiplierGates = {}
	}

	plotData.Model.Name = "Plot" .. plotId
	plotData.Model.Parent = PlotsFolder

	-- Calculate plot position (arrange in a 2x2 grid)
	local row = math.floor((plotId - 1) / 2)
	local col = (plotId - 1) % 2
	local plotPosition = Vector3.new(
		col * (GameConfig.PlotSize.X + GameConfig.PlotSpacing),
		0,
		row * (GameConfig.PlotSize.Z + GameConfig.PlotSpacing)
	)

	-- Create base platform
	local basePart = Instance.new("Part")
	basePart.Name = "Base"
	basePart.Size = GameConfig.PlotSize
	basePart.Position = plotPosition + Vector3.new(GameConfig.PlotSize.X / 2, -0.5, GameConfig.PlotSize.Z / 2)
	basePart.Anchored = true
	basePart.BrickColor = BrickColor.new("Dark green")
	basePart.Material = Enum.Material.Grass
	basePart.Parent = plotData.Model

	-- Create claim button
	local claimButton = Instance.new("Part")
	claimButton.Name = "ClaimButton"
	claimButton.Size = Vector3.new(8, 2, 8)
	claimButton.Position = basePart.Position + Vector3.new(0, 3.5, 0)
	claimButton.Anchored = true
	claimButton.BrickColor = BrickColor.new("Bright blue")
	claimButton.Material = Enum.Material.Neon
	claimButton.Parent = plotData.Model

	-- Use BillboardGui instead of SurfaceGui to avoid Z-fighting
	local claimText = Instance.new("BillboardGui")
	claimText.Size = UDim2.new(0, 200, 0, 50)
	claimText.StudsOffset = Vector3.new(0, 2, 0)
	claimText.Parent = claimButton
	claimText.Adornee = claimButton

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "CLAIM PLOT"
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = claimText

	-- Create spawner platform
	local spawner = Instance.new("Part")
	spawner.Name = "Spawner"
	spawner.Size = Vector3.new(10, 1, 10)
	spawner.Position = basePart.Position + Vector3.new(0, 15, -GameConfig.PlotSize.Z / 2 + 8)
	spawner.Anchored = true
	spawner.CanCollide = false  -- Allow bricks to fall through
	spawner.BrickColor = BrickColor.new("Bright yellow")
	spawner.Material = Enum.Material.SmoothPlastic
	spawner.Transparency = 0.3
	spawner.Parent = plotData.Model

	plotData.SpawnerPosition = spawner.Position + Vector3.new(0, 5, 0)

	-- Create conveyor belt - start directly below spawner, extend forward
	-- Position conveyor to catch falling bricks
	local conveyorStart = spawner.Position + Vector3.new(0, -10, -5)  -- Start 5 studs before spawner center
	local conveyorEnd = conveyorStart + Vector3.new(0, 0, GameConfig.ConveyorLength + 10)  -- Extend 10 studs longer

	plotData.ConveyorStart = conveyorStart
	plotData.ConveyorEnd = conveyorEnd

	-- Create conveyor belt parts
	local numSegments = 12
	local segmentLength = GameConfig.ConveyorLength / numSegments

	for i = 1, numSegments do
		local segment = Instance.new("Part")
		segment.Name = "ConveyorSegment" .. i
		segment.Size = Vector3.new(GameConfig.ConveyorWidth, 1, segmentLength)
		segment.Position = conveyorStart + Vector3.new(0, 0, (i - 0.5) * segmentLength)
		segment.Anchored = true
		segment.BrickColor = BrickColor.new("Dark stone grey")
		segment.Material = Enum.Material.Metal
		segment.Parent = plotData.Model

		-- Add surface for conveyor effect
		segment.TopSurface = Enum.SurfaceType.Smooth
	end

	-- Create sell area
	local sellArea = Instance.new("Part")
	sellArea.Name = "SellArea"
	sellArea.Size = Vector3.new(GameConfig.ConveyorWidth, 8, 8)
	sellArea.Position = conveyorEnd + Vector3.new(0, 4, 4)
	sellArea.Anchored = true
	sellArea.BrickColor = BrickColor.new("Lime green")
	sellArea.Material = Enum.Material.Neon
	sellArea.Transparency = 0.5
	sellArea.CanCollide = false
	sellArea.Parent = plotData.Model

	plotData.SellArea = sellArea

	-- Add sell area label
	local sellGui = Instance.new("BillboardGui")
	sellGui.Size = UDim2.new(0, 100, 0, 50)
	sellGui.Adornee = sellArea
	sellGui.Parent = sellArea

	local sellLabel = Instance.new("TextLabel")
	sellLabel.Size = UDim2.new(1, 0, 1, 0)
	sellLabel.BackgroundTransparency = 1
	sellLabel.Text = "SELL"
	sellLabel.TextScaled = true
	sellLabel.TextColor3 = Color3.new(1, 1, 1)
	sellLabel.Font = Enum.Font.GothamBold
	sellLabel.Parent = sellGui

	self.Plots[plotId] = plotData
	return plotData
end

function PlotManager:AssignPlot(player)
	-- Find an available plot
	for _, plot in pairs(self.Plots) do
		if not plot.Owner then
			plot.Owner = player
			plot.Model.Name = player.Name .. "'s Plot"

			-- Change base color
			local base = plot.Model:FindFirstChild("Base")
			if base then
				base.BrickColor = BrickColor.new(GameConfig.PlotColors[plot.Id])
			end

			-- Remove claim button
			local claimButton = plot.Model:FindFirstChild("ClaimButton")
			if claimButton then
				claimButton:Destroy()
			end

			return plot.Id
		end
	end
	return nil
end

function PlotManager:GetPlot(plotId)
	return self.Plots[plotId]
end

function PlotManager:GetPlayerPlot(player)
	for _, plot in pairs(self.Plots) do
		if plot.Owner == player then
			return plot
		end
	end
	return nil
end

function PlotManager:CreateMultiplierGate(plotId, gateLevel, multiplier)
	local plot = self:GetPlot(plotId)
	if not plot then return nil end

	-- Position gates at different points along the conveyor
	local gatePositions = {
		0.25, -- 25% along conveyor
		0.50, -- 50% along conveyor
		0.75  -- 75% along conveyor
	}

	local gatePosition = plot.ConveyorStart + Vector3.new(
		0,
		3,
		GameConfig.ConveyorLength * gatePositions[gateLevel]
	)

	-- Create gate frame
	local gateModel = Instance.new("Model")
	gateModel.Name = "MultiplierGate" .. gateLevel
	gateModel.Parent = plot.Model

	-- Left post
	local leftPost = Instance.new("Part")
	leftPost.Name = "LeftPost"
	leftPost.Size = Vector3.new(1, 8, 1)
	leftPost.Position = gatePosition + Vector3.new(-GameConfig.ConveyorWidth / 2 - 0.5, 0, 0)
	leftPost.Anchored = true
	leftPost.BrickColor = BrickColor.new("Gold")
	leftPost.Material = Enum.Material.Metal
	leftPost.Parent = gateModel

	-- Right post
	local rightPost = Instance.new("Part")
	rightPost.Name = "RightPost"
	rightPost.Size = Vector3.new(1, 8, 1)
	rightPost.Position = gatePosition + Vector3.new(GameConfig.ConveyorWidth / 2 + 0.5, 0, 0)
	rightPost.Anchored = true
	rightPost.BrickColor = BrickColor.new("Gold")
	rightPost.Material = Enum.Material.Metal
	rightPost.Parent = gateModel

	-- Gate barrier (semi-transparent)
	local barrier = Instance.new("Part")
	barrier.Name = "Barrier"
	barrier.Size = Vector3.new(GameConfig.ConveyorWidth + 2, 6, 0.5)
	barrier.Position = gatePosition + Vector3.new(0, 0, 0)
	barrier.Anchored = true
	barrier.BrickColor = BrickColor.new("Toothpaste")
	barrier.Material = Enum.Material.Glass
	barrier.Transparency = 0.7
	barrier.CanCollide = false
	barrier.Parent = gateModel

	-- Add multiplier label
	local labelGui = Instance.new("BillboardGui")
	labelGui.Size = UDim2.new(0, 100, 0, 50)
	labelGui.Adornee = barrier
	labelGui.Parent = barrier

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = multiplier .. "x"
	label.TextScaled = true
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.Parent = labelGui

	-- Store gate data
	plot.MultiplierGates[gateLevel] = {
		Model = gateModel,
		Position = gatePosition,
		Multiplier = multiplier,
		Barrier = barrier
	}

	return gateModel
end

function PlotManager:Initialize()
	-- Create all plots
	for i = 1, GameConfig.MaxPlots do
		self:CreatePlot(i)
	end

	-- Handle claim button touches
	for _, plot in pairs(self.Plots) do
		local claimButton = plot.Model:FindFirstChild("ClaimButton")
		if claimButton then
			claimButton.Touched:Connect(function(hit)
				if not plot.Owner then
					local player = game.Players:GetPlayerFromCharacter(hit.Parent)
					if player then
						-- Check if player already has a plot
						if not self:GetPlayerPlot(player) then
							self:AssignPlot(player)
							-- Trigger plot assignment event
							local PlayerData = require(ReplicatedStorage:WaitForChild("PlayerData"))
							local data = PlayerData.Get(player)
							if data then
								data.PlotId = plot.Id
							end
						end
					end
				end
			end)
		end
	end
end

return PlotManager
