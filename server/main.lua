local QBCore = exports['qb-core']:GetCoreObject()

-- Track player shoe states
local playerShoeStates = {}

-- Handle shoe state updates from clients
RegisterNetEvent('chilllixhub-zonsurau:server:updateShoeState', function(hasShoes, shoeDrawable, shoeTexture)
    local src = source
    playerShoeStates[src] = {
        hasShoes = hasShoes,
        drawable = shoeDrawable,
        texture = shoeTexture
    }
    
    -- Sync to all other players
    TriggerClientEvent('chilllixhub-zonsurau:client:syncShoeState', -1, src, hasShoes, shoeDrawable, shoeTexture)
end)

-- Get player stress level
QBCore.Functions.CreateCallback('chilllixhub-zonsurau:server:getPlayerStress', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        local stress = Player.PlayerData.metadata['stress'] or 0
        cb(stress)
    else
        cb(0)
    end
end)

-- Update player stress level
RegisterNetEvent('chilllixhub-zonsurau:server:updateStress', function(newStress)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        -- Validate stress value to prevent exploits
        if type(newStress) == 'number' and newStress >= 0 and newStress <= 100 then
            Player.Functions.SetMetaData('stress', newStress)
            -- Trigger qb-hud to update stress display with updated metadata
            TriggerClientEvent('hud:client:UpdateNeeds', src, Player.PlayerData.job.name, Player.PlayerData.metadata)
            -- Also trigger specific stress update for stress icon
            TriggerClientEvent('hud:client:UpdateStress', src, newStress)
        end
    end
end)

-- Add stress level (testing command)
RegisterNetEvent('chilllixhub-zonsurau:server:addStress', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        if type(amount) == 'number' and amount > 0 then
            local currentStress = Player.PlayerData.metadata['stress'] or 0
            local newStress = math.min(100, currentStress + amount)
            local actualChange = newStress - currentStress
            Player.Functions.SetMetaData('stress', newStress)
            -- Trigger qb-hud to update stress display with updated metadata
            TriggerClientEvent('hud:client:UpdateNeeds', src, Player.PlayerData.job.name, Player.PlayerData.metadata)
            -- Also trigger specific stress update for stress icon
            TriggerClientEvent('hud:client:UpdateStress', src, newStress)
            TriggerClientEvent('QBCore:Notify', src, 'Stress increased by ' .. actualChange .. ' (Current: ' .. newStress .. ')', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Invalid amount. Must be a positive number.', 'error')
        end
    end
end)

-- Decrease stress level (testing command)
RegisterNetEvent('chilllixhub-zonsurau:server:minusStress', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        if type(amount) == 'number' and amount > 0 then
            local currentStress = Player.PlayerData.metadata['stress'] or 0
            local newStress = math.max(0, currentStress - amount)
            local actualChange = currentStress - newStress
            Player.Functions.SetMetaData('stress', newStress)
            -- Trigger qb-hud to update stress display with updated metadata
            TriggerClientEvent('hud:client:UpdateNeeds', src, Player.PlayerData.job.name, Player.PlayerData.metadata)
            -- Also trigger specific stress update for stress icon
            TriggerClientEvent('hud:client:UpdateStress', src, newStress)
            TriggerClientEvent('QBCore:Notify', src, 'Stress decreased by ' .. actualChange .. ' (Current: ' .. newStress .. ')', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Invalid amount. Must be a positive number.', 'error')
        end
    end
end)

-- Clean up disconnected players
AddEventHandler('playerDropped', function()
    local src = source
    if playerShoeStates[src] then
        playerShoeStates[src] = nil
    end
end)
