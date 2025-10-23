# Roblox Dropper Tycoon Game

A simple dropper tycoon game where up to 4 players can each own a plot with:
- Brick spawner that drops bricks onto a conveyor belt
- Conveyor belt that transports bricks to a sell area
- Sell area that converts bricks to money
- Upgrades for spawn frequency and brick value
- Multiplier gates that increase brick value

## Setup Instructions

1. Open Roblox Studio
2. Create a new Baseplate game
3. Copy the scripts from the `src` folder into your game:
   - Scripts in `ServerScriptService/` go into ServerScriptService
   - Scripts in `ReplicatedStorage/` go into ReplicatedStorage
   - Scripts in `StarterGui/` go into StarterGui
4. Run the game - plots will be created automatically
5. The game supports 4 players, each getting their own tycoon plot

## Game Features

- **4 Player Plots**: Each player gets their own tycoon when they join
- **Spawner**: Drops bricks at configurable intervals
- **Conveyor Belt**: Transports bricks to the sell area
- **Sell Area**: Automatically sells bricks for money
- **Upgrades**:
  - Faster Spawner: Reduces spawn interval (5 levels)
  - Value Multiplier Gate: Multiplies brick value (3 levels: 2x, 3x, 5x)

## File Structure

```
src/
├── ServerScriptService/
│   ├── GameManager.lua          # Main game initialization
│   ├── PlotManager.lua          # Manages player plots
│   ├── SpawnerSystem.lua        # Brick spawning logic
│   ├── ConveyorSystem.lua       # Conveyor belt physics
│   ├── SellSystem.lua           # Sell area logic
│   └── UpgradeSystem.lua        # Upgrade handling
├── ReplicatedStorage/
│   ├── GameConfig.lua           # Game configuration
│   ├── RemoteEvents.lua         # Client-server communication
│   └── PlayerData.lua           # Player data management
└── StarterGui/
    └── TycoonUI.lua             # Player UI for money and upgrades
```

## How to Play

1. Join the game to claim a plot
2. Watch as your spawner drops bricks onto the conveyor belt
3. Bricks travel down the belt and get sold for money
4. Use your money to purchase upgrades:
   - Spawn Rate upgrades to drop bricks faster
   - Multiplier Gates to increase brick value
5. Earn more money to unlock all upgrades!
