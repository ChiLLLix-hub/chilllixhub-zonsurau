Config = {}

-- Zone Configuration
Config.ZoneType = "box" -- Options: "box", "circle", "poly"

-- Box Zone Configuration (if using box)
Config.BoxZone = {
    center = vector3(-260.0, -982.0, 31.0), -- Example coordinates for a Surau location
    length = 20.0,
    width = 20.0,
    options = {
        name = "no_shoes_zone",
        heading = 0,
        debugPoly = false, -- Set to true to visualize the zone
        minZ = 30.0,
        maxZ = 35.0
    }
}

-- Circle Zone Configuration (if using circle)
Config.CircleZone = {
    center = vector3(-260.0, -982.0, 31.0),
    radius = 15.0,
    options = {
        name = "no_shoes_zone",
        debugPoly = false,
        useZ = true
    }
}

-- Poly Zone Configuration (if using poly)
Config.PolyZone = {
    points = {
        vector2(-270.0, -992.0),
        vector2(-250.0, -992.0),
        vector2(-250.0, -972.0),
        vector2(-270.0, -972.0)
    },
    options = {
        name = "no_shoes_zone",
        minZ = 30.0,
        maxZ = 35.0,
        debugPoly = false
    }
}

-- Animation Configuration
Config.Animation = {
    dict = "random@domestic",
    name = "pickup_low",
    duration = 2000 -- milliseconds
}

-- Shoe Configuration
Config.ShoeComponents = {
    componentId = 6, -- Shoe component ID in GTA V
    drawableId = -1, -- -1 means no shoes
    textureId = 0
}

-- Messages Configuration
Config.Messages = {
    enterZone = "Please remove your shoes in this area",
    exitZone = "You can put your shoes back on",
    shoesRemoved = "Shoes removed",
    shoesPutOn = "Shoes put back on"
}

-- Display zone notification
Config.ShowNotifications = true

-- Command to manually toggle shoes
Config.Command = "shoes"
