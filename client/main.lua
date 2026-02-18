local QBCore = exports['qb-core']:GetCoreObject()
local inNoShoesZone = false
local hasShoes = true
local shoesData = {}
local stressDecreaseActive = false
local stressThread = nil

-- Store original shoe data
local function StoreShoeData()
    local ped = PlayerPedId()
    shoesData = {
        drawable = GetPedDrawableVariation(ped, Config.ShoeComponents.componentId),
        texture = GetPedTextureVariation(ped, Config.ShoeComponents.componentId)
    }
end

-- Remove shoes with animation
local function RemoveShoes()
    if not hasShoes then return end
    
    local ped = PlayerPedId()
    
    -- Store current shoes before removing
    StoreShoeData()
    
    -- Play animation
    RequestAnimDict(Config.Animation.dict)
    while not HasAnimDictLoaded(Config.Animation.dict) do
        Wait(100)
    end
    
    TaskPlayAnim(ped, Config.Animation.dict, Config.Animation.name, 8.0, 8.0, Config.Animation.duration, 0, 0, false, false, false)
    
    Wait(Config.Animation.duration)
    
    -- Remove shoes
    SetPedComponentVariation(ped, Config.ShoeComponents.componentId, Config.ShoeComponents.drawableId, Config.ShoeComponents.textureId, 0)
    
    hasShoes = false
    
    if Config.ShowNotifications then
        QBCore.Functions.Notify(Config.Messages.shoesRemoved, 'success')
    end
    
    -- Sync with server
    TriggerServerEvent('chilllixhub-zonsurau:server:updateShoeState', false, shoesData.drawable, shoesData.texture)
end

-- Put shoes back on with animation
local function PutOnShoes()
    if hasShoes then return end
    
    local ped = PlayerPedId()
    
    -- Play animation
    RequestAnimDict(Config.Animation.dict)
    while not HasAnimDictLoaded(Config.Animation.dict) do
        Wait(100)
    end
    
    TaskPlayAnim(ped, Config.Animation.dict, Config.Animation.name, 8.0, 8.0, Config.Animation.duration, 0, 0, false, false, false)
    
    Wait(Config.Animation.duration)
    
    -- Put shoes back on (restore original shoes)
    if shoesData.drawable ~= nil then
        SetPedComponentVariation(ped, Config.ShoeComponents.componentId, shoesData.drawable, shoesData.texture, 0)
    end
    
    hasShoes = true
    
    if Config.ShowNotifications then
        QBCore.Functions.Notify(Config.Messages.shoesPutOn, 'success')
    end
    
    -- Sync with server
    TriggerServerEvent('chilllixhub-zonsurau:server:updateShoeState', true, shoesData.drawable, shoesData.texture)
end

-- Check and manage player stress
local function CheckAndManageStress()
    if not Config.StressManagement.enabled then return end
    
    QBCore.Functions.TriggerCallback('chilllixhub-zonsurau:server:getPlayerStress', function(currentStress)
        if currentStress == 0 then
            -- Player stress is already 0, just inform them
            if Config.ShowNotifications then
                QBCore.Functions.Notify(Config.StressManagement.messages.stressAlreadyZero, 'success')
            end
            return
        end
        
        -- Player has stress, start decreasing it
        if Config.ShowNotifications then
            QBCore.Functions.Notify(Config.StressManagement.messages.stressDecreasing, 'primary')
        end
        
        stressDecreaseActive = true
        
        -- Create a thread to decrease stress over time
        stressThread = CreateThread(function()
            while stressDecreaseActive and inNoShoesZone do
                Wait(Config.StressManagement.checkInterval)
                
                -- Check again if still in zone and active before processing
                if not stressDecreaseActive or not inNoShoesZone then
                    break
                end
                
                QBCore.Functions.TriggerCallback('chilllixhub-zonsurau:server:getPlayerStress', function(stress)
                    -- Final check: only update if still in zone and active
                    if not stressDecreaseActive or not inNoShoesZone then
                        return
                    end
                    
                    if stress > 0 then
                        local newStress = math.max(0, stress - Config.StressManagement.decreaseRate)
                        TriggerServerEvent('chilllixhub-zonsurau:server:updateStress', newStress)
                        
                        if newStress == 0 then
                            -- Stress reached 0, show notification and stop
                            if Config.ShowNotifications then
                                QBCore.Functions.Notify(Config.StressManagement.messages.stressZero, 'success')
                            end
                            stressDecreaseActive = false
                        end
                    else
                        -- Stress is already 0, stop decreasing
                        if Config.ShowNotifications then
                            QBCore.Functions.Notify(Config.StressManagement.messages.stressZero, 'success')
                        end
                        stressDecreaseActive = false
                    end
                end)
            end
        end)
    end)
end

-- Stop stress decrease
local function StopStressDecrease()
    stressDecreaseActive = false
end

-- Initialize PolyZone
CreateThread(function()
    local zone
    
    if Config.ZoneType == "box" then
        zone = BoxZone:Create(
            Config.BoxZone.center,
            Config.BoxZone.length,
            Config.BoxZone.width,
            Config.BoxZone.options
        )
    elseif Config.ZoneType == "circle" then
        zone = CircleZone:Create(
            Config.CircleZone.center,
            Config.CircleZone.radius,
            Config.CircleZone.options
        )
    elseif Config.ZoneType == "poly" then
        zone = PolyZone:Create(
            Config.PolyZone.points,
            Config.PolyZone.options
        )
    end
    
    -- Handle entering the zone
    zone:onPlayerInOut(function(isPointInside)
        if isPointInside then
            -- Player entered the zone
            if not inNoShoesZone then
                inNoShoesZone = true
                if Config.ShowNotifications then
                    QBCore.Functions.Notify(Config.Messages.enterZone, 'primary', 5000)
                end
                RemoveShoes()
                
                -- Check and manage stress when entering zone
                CheckAndManageStress()
            end
        else
            -- Player left the zone
            if inNoShoesZone then
                inNoShoesZone = false
                
                -- Stop stress decrease when leaving zone
                StopStressDecrease()
                
                if Config.ShowNotifications then
                    QBCore.Functions.Notify(Config.Messages.exitZone, 'primary', 5000)
                end
                PutOnShoes()
            end
        end
    end)
end)

-- Register /shoes command
RegisterCommand(Config.Command, function()
    if inNoShoesZone then
        -- Inside zone, can only remove shoes or they're already removed
        if hasShoes then
            RemoveShoes()
        else
            QBCore.Functions.Notify('Your shoes are already off', 'error')
        end
    else
        -- Outside zone, can toggle shoes
        if hasShoes then
            RemoveShoes()
        else
            PutOnShoes()
        end
    end
end, false)

-- Testing command to add stress
RegisterCommand('stressadd', function(source, args)
    local amount = tonumber(args[1])
    if not amount or amount <= 0 then
        QBCore.Functions.Notify('Usage: /stressadd [amount] (must be positive)', 'error')
        return
    end
    TriggerServerEvent('chilllixhub-zonsurau:server:addStress', amount)
end, false)

-- Testing command to decrease stress
RegisterCommand('stressminus', function(source, args)
    local amount = tonumber(args[1])
    if not amount or amount <= 0 then
        QBCore.Functions.Notify('Usage: /stressminus [amount] (must be positive)', 'error')
        return
    end
    TriggerServerEvent('chilllixhub-zonsurau:server:minusStress', amount)
end, false)

-- Sync shoe state from server to other players
RegisterNetEvent('chilllixhub-zonsurau:client:syncShoeState', function(playerId, hasShoesOn, shoeDrawable, shoeTexture)
    local playerIndex = GetPlayerFromServerId(playerId)
    
    if playerIndex >= 0 then
        local targetPed = GetPlayerPed(playerIndex)
        
        if targetPed and targetPed ~= PlayerPedId() then
            if not hasShoesOn then
                -- Remove shoes from target player
                SetPedComponentVariation(targetPed, Config.ShoeComponents.componentId, Config.ShoeComponents.drawableId, Config.ShoeComponents.textureId, 0)
            else
                -- Put shoes back on target player (if we have their shoe data)
                if shoeDrawable ~= nil and shoeDrawable >= 0 then
                    SetPedComponentVariation(targetPed, Config.ShoeComponents.componentId, shoeDrawable, shoeTexture, 0)
                end
            end
        end
    end
end)

-- Handle player spawning
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    StoreShoeData()
    hasShoes = true
    inNoShoesZone = false
    StopStressDecrease()
end)

-- Handle resource restart
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        StoreShoeData()
        hasShoes = true
        inNoShoesZone = false
        StopStressDecrease()
    end
end)

-- Handle resource stop to clean up stress threads
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        StopStressDecrease()
    end
end)
