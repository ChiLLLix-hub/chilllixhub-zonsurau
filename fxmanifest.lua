fx_version 'cerulean'
game 'gta5'

author 'ChiLLLix-hub'
description 'No-Shoes Zone Script for Surau MLO using QBCore and PolyZone'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'qb-core',
    'PolyZone'
}
