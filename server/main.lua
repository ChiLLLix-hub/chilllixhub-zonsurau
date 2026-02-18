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
            -- Trigger qb-hud to update stress display
            TriggerClientEvent('hud:client:UpdateNeeds', src, Player.PlayerData.job.name, Player.PlayerData.metadata)
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
