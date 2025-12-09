-- Optimized Vehicle Speed Limit System
-- Prevents vehicles from exceeding the configured speed limit

-- Use the global SpeedLimit table defined in config.lua,
-- but ensure it exists so we don't crash if config.lua failed.
SpeedLimit = SpeedLimit or {}

-- Performance optimizations
local pedCheckInterval = 5000 -- Cache player ped for 5 seconds
local cachedPed = nil
local lastPedCheck = 0

local speedCheckInterval = 150 -- Check speed every 100-200ms

-- Notification cooldown timers
local lastToggleNotification = 0
local toggleNotificationCooldown = 2000
local lastSpeedNotification = 0
local speedNotificationCooldown = 3000

-- Cached constants to avoid repeated calculations
local MPH_CONVERT = 2.23694  -- m/s to mph
local KPH_CONVERT = 3.6      -- m/s to kph
local MPH_TO_KPH = 1.60934
local KPH_TO_MPH = 1.0 / MPH_TO_KPH

-- Helper functions for speed
local function getSpeedInMPH(vehicle)
    return GetEntitySpeed(vehicle) * MPH_CONVERT
end

local function getSpeedInKPH(vehicle)
    return GetEntitySpeed(vehicle) * KPH_CONVERT
end

-- Load / validate configuration from global SpeedLimit
local function loadConfig()
    -- These values are expected to be set in config.lua,
    -- but we still provide safe defaults in case something is missing.

    SpeedLimit.MaxSpeedMPH           = SpeedLimit.MaxSpeedMPH or 160.0
    SpeedLimit.MaxSpeedKPH           = SpeedLimit.MaxSpeedKPH or (SpeedLimit.MaxSpeedMPH * MPH_TO_KPH)
    SpeedLimit.EnableSpeedLimit      = SpeedLimit.EnableSpeedLimit ~= false
    SpeedLimit.ShowWarning           = SpeedLimit.ShowWarning or false
    SpeedLimit.WarningThreshold      = SpeedLimit.WarningThreshold or 0.8
    SpeedLimit.ApplyBrakingForce     = SpeedLimit.ApplyBrakingForce ~= false
    SpeedLimit.BrakingForceMultiplier= SpeedLimit.BrakingForceMultiplier or 0.5
    SpeedLimit.DebugMode             = SpeedLimit.DebugMode or false
    SpeedLimit.ShowSpeedNotifications= SpeedLimit.ShowSpeedNotifications or false

    -- Safety: avoid division by zero / broken values
    if SpeedLimit.MaxSpeedMPH <= 0 then
        SpeedLimit.MaxSpeedMPH = 1.0
    end

    if SpeedLimit.MaxSpeedKPH <= 0 then
        SpeedLimit.MaxSpeedKPH = SpeedLimit.MaxSpeedMPH * MPH_TO_KPH
    end

    if SpeedLimit.BrakingForceMultiplier < 0.0 then
        SpeedLimit.BrakingForceMultiplier = 0.0
    elseif SpeedLimit.BrakingForceMultiplier > 1.0 then
        SpeedLimit.BrakingForceMultiplier = 1.0
    end

    if SpeedLimit.DebugMode then
        print(("[SpeedLimit] Config Loaded - Max: %.1f MPH / %.1f KPH")
            :format(SpeedLimit.MaxSpeedMPH, SpeedLimit.MaxSpeedKPH))
    end
end

-- Optimized speed checking and enforcement
local function processVehicleSpeed()
    if not SpeedLimit.EnableSpeedLimit then return end

    local currentTime = GetGameTimer()

    -- Cache player ped (updated every 5 seconds)
    if currentTime - lastPedCheck > pedCheckInterval then
        cachedPed = PlayerPedId()
        lastPedCheck = currentTime
    end

    if not cachedPed then return end

    local vehicle = GetVehiclePedIsIn(cachedPed, false)
    if not DoesEntityExist(vehicle) or GetPedInVehicleSeat(vehicle, -1) ~= cachedPed then return end

    -- Get vehicle speed (single call)
    local rawSpeed = GetEntitySpeed(vehicle)
    if rawSpeed <= 0.0 then return end

    local speedMPH = rawSpeed * MPH_CONVERT
    local speedKPH = rawSpeed * KPH_CONVERT

    -- If exceeding limit in either MPH or KPH
    if speedMPH > SpeedLimit.MaxSpeedMPH or speedKPH > SpeedLimit.MaxSpeedKPH then
        if SpeedLimit.ApplyBrakingForce then
            -- Use MPH as base for "how much over" scaling
            local exceedAmount = speedMPH - SpeedLimit.MaxSpeedMPH

            -- If weird config where MPH is lower but KPH is higher, fallback
            if exceedAmount < 0 then
                exceedAmount = speedKPH - SpeedLimit.MaxSpeedKPH
            end

            if exceedAmount > 0 then
                local brakeMultiplier = SpeedLimit.BrakingForceMultiplier * (exceedAmount / SpeedLimit.MaxSpeedMPH)

                -- Clamp brake multiplier to 0–1
                if brakeMultiplier < 0.0 then brakeMultiplier = 0.0 end
                if brakeMultiplier > 1.0 then brakeMultiplier = 1.0 end

                local velocity = GetEntityVelocity(vehicle)
                ApplyForceToEntity(
                    vehicle,
                    3,
                    -velocity.x * brakeMultiplier,
                    -velocity.y * brakeMultiplier,
                    -velocity.z * brakeMultiplier,
                    0.0, 0.0, 0.0,
                    true, false, true, true, false, true
                )
            end
        end
    elseif SpeedLimit.ShowWarning and SpeedLimit.WarningThreshold > 0 then
        -- Optional: warning when approaching speed limit
        local percentOfMax = speedMPH / SpeedLimit.MaxSpeedMPH
        if percentOfMax >= SpeedLimit.WarningThreshold then
            -- You can replace this with your own notification system
            if SpeedLimit.DebugMode then
                print(("[SpeedLimit] Warning: %.1f%% of max speed reached"):format(percentOfMax * 100.0))
            end
        end
    end
end

-- Main thread for speed monitoring
Citizen.CreateThread(function()
    loadConfig()

    while true do
        processVehicleSpeed()
        Citizen.Wait(speedCheckInterval)
    end
end)

-- Event handler for resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    loadConfig()
    print(("[SpeedLimit] Vehicle Speed Limit system started. Max: %.1f MPH / %.1f KPH")
        :format(SpeedLimit.MaxSpeedMPH, SpeedLimit.MaxSpeedKPH))
end)

-- Command to toggle speed limit (for testing)
RegisterCommand('togglespeedlimit', function()
    local currentTime = GetGameTimer()
    if currentTime - lastToggleNotification < toggleNotificationCooldown then return end
    lastToggleNotification = currentTime

    SpeedLimit.EnableSpeedLimit = not SpeedLimit.EnableSpeedLimit
    local status = SpeedLimit.EnableSpeedLimit and "enabled" or "disabled"
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        args = {"Speed Limit", "Speed limit system " .. status}
    })
end, false)

-- Command to show current speed (for debugging)
RegisterCommand('showspeed', function()
    local currentTime = GetGameTimer()
    if currentTime - lastSpeedNotification < speedNotificationCooldown then return end
    lastSpeedNotification = currentTime

    local playerPed = PlayerPedId()
    local currentVehicle = GetVehiclePedIsIn(playerPed, false)

    if DoesEntityExist(currentVehicle) then
        local speedMPH = getSpeedInMPH(currentVehicle)
        local speedKPH = getSpeedInKPH(currentVehicle)

        -- You could gate this behind SpeedLimit.ShowSpeedNotifications if you want
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            args = {
                "Speed Limit",
                ("Current speed: %.1f MPH / %.1f KPH"):format(speedMPH, speedKPH)
            }
        })
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {"Speed Limit", "You are not in a vehicle"}
        })
    end
end, false)


