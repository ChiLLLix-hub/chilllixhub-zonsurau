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

-- Clean up disconnected players
AddEventHandler('playerDropped', function()
    local src = source
    if playerShoeStates[src] then
        playerShoeStates[src] = nil
    end
end)
