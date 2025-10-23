-- Conveyor System - Moves bricks along conveyor belts
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local ConveyorSystem = {}
ConveyorSystem.TrackedBricks = {}

function ConveyorSystem:Initialize(plotManager)
	self.PlotManager = plotManager

	-- Use Heartbeat for physics updates
	RunService.Heartbeat:Connect(function(deltaTime)
		self:UpdateBricks(deltaTime)
	end)

	-- Detect new bricks entering conveyor
	workspace.ChildAdded:Connect(function(child)
		if child.Name == "DropperBrick" then
			task.wait(0.1) -- Small delay to ensure brick lands on conveyor
			self:TrackBrick(child)
		end
	end)
end

function ConveyorSystem:TrackBrick(brick)
	if not brick:FindFirstChild("Owner") then return end
	if not brick:FindFirstChild("PlotId") then return end

	local plotId = brick.PlotId.Value
	local plot = self.PlotManager:GetPlot(plotId)
	if not plot then return end

	-- Check if brick is on the conveyor
	local brickPos = brick.Position
	local conveyorStart = plot.ConveyorStart
	local conveyorEnd = plot.ConveyorEnd

	-- Check if brick is within conveyor bounds
	if brickPos.Z >= conveyorStart.Z - 5 and brickPos.Z <= conveyorEnd.Z + 5 then
		if math.abs(brickPos.X - conveyorStart.X) <= GameConfig.ConveyorWidth / 2 + 2 then
			self.TrackedBricks[brick] = {
				PlotId = plotId,
				LastMultiplierCheck = 0
			}
		end
	end
end

function ConveyorSystem:UpdateBricks(deltaTime)
	local bricksToRemove = {}

	for brick, data in pairs(self.TrackedBricks) do
		if not brick.Parent then
			table.insert(bricksToRemove, brick)
		else
			local plot = self.PlotManager:GetPlot(data.PlotId)
			if plot then
				-- Move brick forward along Z axis
				local velocity = Vector3.new(0, 0, GameConfig.ConveyorSpeed)
				brick.AssemblyLinearVelocity = velocity

				-- Check for multiplier gates
				self:CheckMultiplierGates(brick, plot, data)
			end
		end
	end

	-- Clean up destroyed bricks
	for _, brick in ipairs(bricksToRemove) do
		self.TrackedBricks[brick] = nil
	end
end

function ConveyorSystem:CheckMultiplierGates(brick, plot, data)
	local brickZ = brick.Position.Z

	for gateLevel, gate in pairs(plot.MultiplierGates) do
		-- Check if brick just passed through this gate
		if brickZ >= gate.Position.Z and brickZ <= gate.Position.Z + 5 then
			-- Only apply multiplier once per gate
			if data.LastMultiplierCheck < gateLevel then
				local multiplierTag = brick:FindFirstChild("Multiplier")
				local valueTag = brick:FindFirstChild("BrickValue")

				if multiplierTag and valueTag then
					-- Apply gate multiplier
					multiplierTag.Value = multiplierTag.Value * gate.Multiplier
					valueTag.Value = GameConfig.BrickBasicValue * multiplierTag.Value

					-- Mark this gate as passed
					data.LastMultiplierCheck = gateLevel

					-- Visual effect
					self:CreateMultiplierEffect(brick, gate.Multiplier)
				end
			end
		end
	end
end

function ConveyorSystem:CreateMultiplierEffect(brick, multiplier)
	-- Create particle effect when brick passes through gate
	local particle = Instance.new("ParticleEmitter")
	particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particle.Rate = 50
	particle.Lifetime = NumberRange.new(0.5, 1)
	particle.Speed = NumberRange.new(5)
	particle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
	particle.Parent = brick

	-- Change brick color temporarily
	local originalColor = brick.BrickColor
	brick.BrickColor = BrickColor.new("Bright yellow")

	task.delay(0.5, function()
		if brick.Parent then
			brick.BrickColor = originalColor
			particle:Destroy()
		end
	end)
end

return ConveyorSystem
