local QBCore = exports['qb-core']:GetCoreObject()
local inNoShoesZone = false
local hasShoes = true
local shoesData = {}

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
            end
        else
            -- Player left the zone
            if inNoShoesZone then
                inNoShoesZone = false
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
end)

-- Handle resource restart
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        StoreShoeData()
        hasShoes = true
        inNoShoesZone = false
    end
end)
