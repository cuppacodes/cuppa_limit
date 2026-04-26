SpeedLimit = {}

-- Speed limit configuration (set both MPH and KPH for failver)
SpeedLimit.MaxSpeedMPH = 160.0 -- Maximum allowed speed in miles per hour
SpeedLimit.MaxSpeedKPH = 257.49 -- Maximum allowed speed in kilometers per hour (converted from MPH)
SpeedLimit.EnableSpeedLimit = true -- Enable or disable the speed limit system
SpeedLimit.ShowWarning = false -- Show warning message when approaching speed limit
SpeedLimit.WarningThreshold = 0.8 -- Show warning when reaching this percentage of max speed (0.9 = 90%)
SpeedLimit.ApplyBrakingForce = true -- Apply braking force when exceeding speed limit
SpeedLimit.BrakingForceMultiplier = 0.5 -- How strong the braking force should be (0.1 to 1.0)

-- Debug settings
SpeedLimit.DebugMode = false -- Enable debug logging
SpeedLimit.ShowSpeedNotifications = false -- Show current speed notifications for debugging
