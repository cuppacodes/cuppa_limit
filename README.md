# t_limit - Vehicle Speed Limiter

A high-performance vehicle speed limit enforcement system for FiveM servers. This script automatically prevents vehicles from exceeding configured speed limits and applies braking force when limits are surpassed, promoting safer gameplay and server balance.

## Features

- **Dual Speed Measurement**: Supports both MPH and KPH speed limits
- **Automatic Enforcement**: Real-time speed monitoring with configurable braking force
- **Performance Optimized**: Efficient caching and optimized checks for minimal server impact
- **Configurable Warnings**: Optional notifications when approaching speed limits
- **Debug Mode**: Comprehensive debug logging and speed display options
- **Admin Commands**: Easy-to-use commands for toggling the system and checking current speed
- **Safe Configuration**: Built-in validation and safe defaults

## Dependencies

- FiveM server
- No additional resources required (optional integration with notification systems)

## Installation

1. Download or clone this repository
2. Copy the `t_limit` folder to your server's `resources` directory
3. Add `ensure t_limit` to your `server.cfg` file
4. Restart your server or run `refresh` then `ensure t_limit`

## Configuration

Edit `config.lua` to customize the speed limiter:

```lua
SpeedLimit = {}

-- Speed limit configuration
SpeedLimit.MaxSpeedMPH = 160.0  -- Maximum allowed speed in miles per hour
SpeedLimit.MaxSpeedKPH = 257.49 -- Maximum allowed speed in kilometers per hour
SpeedLimit.EnableSpeedLimit = true -- Enable or disable the speed limit system
SpeedLimit.ShowWarning = false -- Show warning messages when approaching limit
SpeedLimit.WarningThreshold = 0.8 -- Warning threshold (% of max speed, 0.8 = 80%)
SpeedLimit.ApplyBrakingForce = true -- Apply braking force when exceeding limit
SpeedLimit.BrakingForceMultiplier = 0.5 -- Braking force strength (0.1 to 1.0)

-- Debug settings
SpeedLimit.DebugMode = false -- Enable debug logging to console
SpeedLimit.ShowSpeedNotifications = false -- Show current speed in chat

