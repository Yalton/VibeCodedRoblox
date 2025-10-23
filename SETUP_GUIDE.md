# Dropper Tycoon - Setup Guide

This guide will help you set up the Dropper Tycoon game in Roblox Studio.

## Quick Setup (5 minutes)

### Step 1: Create a New Game
1. Open Roblox Studio
2. Create a new **Baseplate** game
3. Save the game (File > Save to Roblox)

### Step 2: Set Up the Folder Structure

In Roblox Studio, create the following folder structure:

#### In ReplicatedStorage:
1. Right-click **ReplicatedStorage** > Insert Object > **ModuleScript**
2. Name it `GameConfig`
3. Copy the contents from `src/ReplicatedStorage/GameConfig.lua` into this script
4. Repeat for:
   - `RemoteEvents` (ModuleScript)
   - `PlayerData` (ModuleScript)

#### In ServerScriptService:
1. Right-click **ServerScriptService** > Insert Object > **Script**
2. Name it `GameManager`
3. Copy the contents from `src/ServerScriptService/GameManager.lua` into this script
4. Repeat for:
   - `PlotManager` (ModuleScript)
   - `SpawnerSystem` (ModuleScript)
   - `ConveyorSystem` (ModuleScript)
   - `SellSystem` (ModuleScript)
   - `UpgradeSystem` (ModuleScript)

**Important:** GameManager should be a **Script** (not ModuleScript), all others should be **ModuleScripts**.

#### In StarterGui:
1. Right-click **StarterGui** > Insert Object > **LocalScript**
2. Name it `TycoonUI`
3. Copy the contents from `src/StarterGui/TycoonUI.lua` into this script

### Step 3: Run the Game
1. Click the **Play** button (F5)
2. You should see 4 plots appear in the workspace
3. Walk over to a plot's blue "CLAIM PLOT" button to claim it
4. Your spawner will start dropping bricks automatically!

## How It Works

### Game Systems

1. **PlotManager**: Creates 4 plots arranged in a 2x2 grid. Each plot has:
   - Base platform
   - Spawner (elevated platform)
   - Conveyor belt (12 segments)
   - Sell area (green glowing area)

2. **SpawnerSystem**: Drops bricks from the spawner at configurable intervals

3. **ConveyorSystem**: Moves bricks along the conveyor belt using physics

4. **SellSystem**: Detects bricks entering the sell area and converts them to money

5. **UpgradeSystem**: Handles purchasing upgrades with earned money

6. **PlayerData**: Tracks each player's money, upgrades, and plot ownership

### Upgrades Available

#### Spawn Rate Upgrades (5 levels)
- Level 1: 2.5s interval - $100
- Level 2: 2.0s interval - $500
- Level 3: 1.5s interval - $2,000
- Level 4: 1.0s interval - $10,000
- Level 5: 0.5s interval - $50,000

#### Multiplier Gates (3 levels)
- 2x Multiplier - $500 (placed at 25% of conveyor)
- 3x Multiplier - $5,000 (placed at 50% of conveyor)
- 5x Multiplier - $25,000 (placed at 75% of conveyor)

## Customization

### Changing Plot Colors
Edit `GameConfig.lua` in ReplicatedStorage:
```lua
GameConfig.PlotColors = {
    Color3.fromRGB(255, 100, 100), -- Red
    Color3.fromRGB(100, 150, 255), -- Blue
    Color3.fromRGB(100, 255, 100), -- Green
    Color3.fromRGB(255, 255, 100), -- Yellow
}
```

### Adjusting Game Balance
In `GameConfig.lua`, you can modify:
- `BaseSpawnInterval`: Starting spawn rate
- `BrickBasicValue`: Money per brick
- `ConveyorSpeed`: How fast bricks move
- Upgrade costs and effects in `GameConfig.Upgrades`

### Changing Plot Size
```lua
GameConfig.PlotSize = Vector3.new(50, 1, 80)  -- Width, Height, Length
GameConfig.PlotSpacing = 10  -- Space between plots
```

## Troubleshooting

### Plots don't appear
- Make sure `GameManager` is a **Script** (not ModuleScript) in ServerScriptService
- Check the Output window for error messages

### UI doesn't show up
- Make sure `TycoonUI` is a **LocalScript** in StarterGui
- Check that it's not disabled

### Bricks don't spawn
- Make sure you've claimed a plot by touching the blue button
- Check the Output window for errors

### Bricks don't move on conveyor
- The ConveyorSystem uses physics-based movement
- Make sure workspace gravity is enabled

### Money doesn't increase when bricks are sold
- Check that bricks are reaching the green sell area
- Verify PlayerData is properly initialized

## Script Types Reference

| Location | Script Name | Type |
|----------|-------------|------|
| ReplicatedStorage | GameConfig | ModuleScript |
| ReplicatedStorage | RemoteEvents | ModuleScript |
| ReplicatedStorage | PlayerData | ModuleScript |
| ServerScriptService | GameManager | Script |
| ServerScriptService | PlotManager | ModuleScript |
| ServerScriptService | SpawnerSystem | ModuleScript |
| ServerScriptService | ConveyorSystem | ModuleScript |
| ServerScriptService | SellSystem | ModuleScript |
| ServerScriptService | UpgradeSystem | ModuleScript |
| StarterGui | TycoonUI | LocalScript |

## Testing Tips

1. **Test with Multiple Players**:
   - Use "Play Here" in Roblox Studio
   - Set player count to 2-4 to test multiplayer

2. **Give Yourself Money (for testing)**:
   - In GameManager.lua, after creating PlayerData, add:
   ```lua
   data:AddMoney(100000) -- Start with $100,000 for testing
   ```

3. **Adjust Spawn Rate for Testing**:
   - Temporarily change `BaseSpawnInterval` to 0.5 for faster testing

## Next Steps

Once you have the basic game working, you can:
- Add more upgrade types
- Create different brick types with varying values
- Add rebirth system
- Add visual effects and sounds
- Create a leaderboard
- Add game passes for bonuses

Have fun building your tycoon game!
