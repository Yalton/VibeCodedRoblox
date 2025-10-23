# Game Mechanics Overview

## Core Game Loop

```
Player Claims Plot → Spawner Drops Bricks → Bricks Move on Conveyor →
Bricks Pass Through Multiplier Gates → Bricks Reach Sell Area →
Player Earns Money → Player Buys Upgrades → Earn More Money Faster
```

## Brick Lifecycle

1. **Spawn**: Brick is created at the spawner position (15 studs above plot)
2. **Drop**: Brick falls onto the conveyor belt
3. **Transport**: ConveyorSystem detects brick and moves it forward at 10 studs/second
4. **Multiply**: As brick passes through multiplier gates, its value increases
5. **Sell**: When brick touches the sell area, it's destroyed and money is added
6. **Cleanup**: Any bricks that don't sell are auto-deleted after 30 seconds

## Money Calculation

### Base Value
Each brick starts with a base value of **$10**

### Multiplier Gates
As a brick passes through gates, its value is multiplied:
- Pass through 2x gate: $10 × 2 = $20
- Pass through 3x gate: $20 × 3 = $60
- Pass through 5x gate: $60 × 5 = $300

### Maximum Earnings Per Brick
With all three multiplier gates: $10 × 2 × 3 × 5 = **$300 per brick**

## Upgrade Economics

### Return on Investment (ROI)

#### 2x Multiplier Gate ($500)
- Increases brick value from $10 to $20
- Extra $10 per brick
- Breaks even after 50 bricks
- With level 1 spawner (2.5s): ~2 minutes to ROI

#### 3x Multiplier Gate ($5,000)
- Requires 2x gate first
- Increases brick value from $20 to $60
- Extra $40 per brick
- Breaks even after 125 bricks
- With level 2 spawner (2.0s): ~4 minutes to ROI

#### 5x Multiplier Gate ($25,000)
- Requires 2x and 3x gates first
- Increases brick value from $60 to $300
- Extra $240 per brick
- Breaks even after 104 bricks
- With level 3 spawner (1.5s): ~2.6 minutes to ROI

### Optimal Upgrade Path

1. **Start**: Earn $100 with base spawner
2. **First Upgrade**: Buy Spawn Rate 1 ($100)
   - Increases income rate by 20%
3. **Second Upgrade**: Buy 2x Multiplier ($500)
   - Doubles brick value
4. **Third Upgrade**: Buy Spawn Rate 2 ($500)
   - Increases income rate by another 25%
5. **Fourth Upgrade**: Buy Spawn Rate 3 ($2,000)
   - Faster spawning
6. **Fifth Upgrade**: Buy 3x Multiplier ($5,000)
   - Triples brick value (on top of 2x)
7. **Sixth Upgrade**: Buy Spawn Rate 4 ($10,000)
   - Even faster spawning
8. **Seventh Upgrade**: Buy 5x Multiplier ($25,000)
   - Maximum brick value
9. **Final Upgrade**: Buy Spawn Rate 5 ($50,000)
   - Maximum spawn speed

## Income Rates

### Base Configuration
- Spawn interval: 3 seconds
- Brick value: $10
- **Income rate**: $3.33/second or $200/minute

### With All Spawn Upgrades (0.5s interval)
- Spawn interval: 0.5 seconds
- Brick value: $10 (no multipliers)
- **Income rate**: $20/second or $1,200/minute

### With All Multiplier Gates (no spawn upgrades)
- Spawn interval: 3 seconds
- Brick value: $300 (with all multipliers)
- **Income rate**: $100/second or $6,000/minute

### With ALL Upgrades
- Spawn interval: 0.5 seconds
- Brick value: $300
- **Income rate**: $600/second or $36,000/minute

## Plot Layout

```
                    [Spawner Platform]
                           |
                     (Bricks drop)
                           ↓
    ┌────────────────────────────────────────────┐
    │                                            │
    │  ╔═══════════════════════════════════╗    │
    │  ║ 2x Gate (25%)                     ║    │
    │  ╚═══════════════════════════════════╝    │
    │               Conveyor Belt                │
    │  ╔═══════════════════════════════════╗    │
    │  ║ 3x Gate (50%)                     ║    │
    │  ╚═══════════════════════════════════╝    │
    │               Conveyor Belt                │
    │  ╔═══════════════════════════════════╗    │
    │  ║ 5x Gate (75%)                     ║    │
    │  ╚═══════════════════════════════════╝    │
    │               Conveyor Belt                │
    │           ┌──────────────┐                 │
    │           │  SELL AREA   │                 │
    │           │   (Green)    │                 │
    │           └──────────────┘                 │
    └────────────────────────────────────────────┘
```

## Technical Details

### Physics
- Bricks use AssemblyLinearVelocity for smooth movement
- Gravity: Standard Roblox gravity (196.2 studs/s²)
- Conveyor speed: 10 studs/second forward (Z-axis)

### Collision Detection
- Sell area uses .Touched event
- Multiplier gates use position-based detection
- Each brick is tracked individually

### Data Persistence
**Note**: Current version does NOT save data between sessions
To add data persistence, you would need to:
1. Set up DataStoreService
2. Save player data on PlayerRemoving
3. Load player data on PlayerAdded

### Performance Optimization
- Bricks auto-delete after 30 seconds
- Only bricks on conveyor are tracked
- Updates use RunService.Heartbeat for smooth physics

## Player Count & Scaling

### 4 Player Maximum
- Each player gets their own plot
- Plots arranged in 2×2 grid
- Plot spacing: 10 studs between plots
- Each plot is completely independent

### Multi-Player Considerations
- No interference between players
- Each plot has its own:
  - Spawner
  - Conveyor
  - Sell area
  - Upgrade state
- Server tracks all players simultaneously

## Future Enhancement Ideas

### Gameplay
- Rebirth system (reset for permanent bonuses)
- Different brick types (gold bricks worth more)
- Prestige system
- VIP game passes
- Special events/limited-time multipliers

### Technical
- DataStore integration for save data
- Leaderboards
- Trading between players
- Plot customization
- Sound effects and music

### Visual
- Particle effects on spawner
- Better visual feedback for multipliers
- Custom brick colors based on value
- Plot themes and decorations
