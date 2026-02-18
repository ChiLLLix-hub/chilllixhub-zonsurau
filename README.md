# chilllixhub-zonsurau

FiveM script with QBCore framework for creating a no-shoes zone around Surau MLO using PolyZone integration.

## Description

This script creates a designated no-shoes zone where players must remove their shoes when entering. The script features:

- Automatic shoe removal when entering the zone with animation
- Automatic shoe restoration when exiting the zone
- Manual `/shoes` command to toggle shoes
- Full player synchronization across all clients
- Support for multiple zone types (Box, Circle, Poly)
- Configurable zone coordinates and animation settings
- QBCore framework integration
- PolyZone integration for accurate zone detection
- **Stress management system** - Automatically decreases player stress while in the zone

## Features

- 🔄 **Automatic Shoe Management**: Shoes are removed when entering and put back when exiting the zone
- 🎭 **Realistic Animations**: Plays character animations when removing/putting on shoes
- 👥 **Player Synchronization**: All players see shoe state changes in real-time
- ⌨️ **Manual Control**: Use `/shoes` command to toggle shoes manually
- 📍 **Flexible Zone Types**: Choose between Box, Circle, or Polygon zones
- ⚙️ **Fully Configurable**: Easy configuration through `config.lua`
- 🔔 **Notifications**: Optional notifications for zone entry/exit
- 🧘 **Stress Management**: Gradual stress reduction while in the peaceful zone

## Dependencies

This script requires the following resources:

- [qb-core](https://github.com/qbcore-framework/qb-core) - QBCore Framework
- [PolyZone](https://github.com/mkafrin/PolyZone) - Zone creation and detection

## Installation

1. Clone or download this repository to your FiveM server's `resources` folder:
   ```bash
   cd resources
   git clone https://github.com/ChiLLLix-hub/chilllixhub-zonsurau.git
   ```

2. Ensure you have the required dependencies installed:
   - `qb-core`
   - `PolyZone`

3. Add the resource to your `server.cfg`:
   ```cfg
   ensure qb-core
   ensure PolyZone
   ensure chilllixhub-zonsurau
   ```

4. Configure the zone coordinates in `config.lua` to match your Surau MLO location

5. Restart your server or start the resource:
   ```
   restart chilllixhub-zonsurau
   ```

## Configuration

Edit the `config.lua` file to customize the script:

### Zone Configuration

Choose your zone type by setting `Config.ZoneType`:
- `"box"` - Rectangular zone
- `"circle"` - Circular zone  
- `"poly"` - Custom polygon zone

### Example: Box Zone
```lua
Config.BoxZone = {
    center = vector3(-260.0, -982.0, 31.0),
    length = 20.0,
    width = 20.0,
    options = {
        name = "no_shoes_zone",
        heading = 0,
        debugPoly = false, -- Set to true to see zone boundaries
        minZ = 30.0,
        maxZ = 35.0
    }
}
```

### Animation Settings
```lua
Config.Animation = {
    dict = "random@domestic",
    name = "pickup_low",
    duration = 2000 -- milliseconds
}
```

### Messages
```lua
Config.Messages = {
    enterZone = "Please remove your shoes in this area",
    exitZone = "You can put your shoes back on",
    shoesRemoved = "Shoes removed",
    shoesPutOn = "Shoes put back on"
}
```

### Stress Management
```lua
Config.StressManagement = {
    enabled = true, -- Enable/disable stress management feature
    decreaseRate = 10, -- Amount of stress to decrease per minute
    checkInterval = 60000, -- Check interval in milliseconds (60000 = 1 minute)
    messages = {
        stressZero = "Your stress level is 0",
        stressAlreadyZero = "Your stress level is already 0",
        stressDecreasing = "You feel relaxed in this peaceful area, your stress is decreasing"
    }
}
```

**How Stress Management Works:**
- When a player enters the zone, the script checks their current stress level
- If stress is greater than 0, it automatically decreases by the configured rate per minute
- Players receive a notification when their stress reaches 0
- If a player enters with 0 stress, they are simply informed their stress is already at 0
- Stress reduction stops when the player leaves the zone

## Usage

### For Players

1. **Entering the Zone**: Walk into the no-shoes zone, and your shoes will automatically be removed with an animation
2. **Exiting the Zone**: Walk out of the zone, and your shoes will automatically be put back on
3. **Manual Toggle**: Type `/shoes` in chat to manually remove or put on shoes
4. **Stress Relief**: Stay in the zone to gradually reduce your stress level. You'll receive notifications about your stress status

### For Server Administrators

1. **Finding Coordinates**: Use in-game coordinates tools or developer mode to find the exact location of your Surau MLO
2. **Testing Zones**: Set `debugPoly = true` in the zone configuration to visualize zone boundaries
3. **Adjusting Zone Size**: Modify the length/width (box), radius (circle), or points (poly) to fit your Surau perfectly

## Debug Mode

To visualize the zone boundaries and help with setup:

1. Open `config.lua`
2. Set `debugPoly = true` in your zone options
3. Restart the resource
4. The zone boundaries will be visible in-game

## Troubleshooting

### Shoes not being removed
- Verify PolyZone is installed and started before this resource
- Check that zone coordinates match your Surau location
- Enable debug mode to verify zone boundaries
- Check F8 console for any errors

### Command not working
- Ensure QBCore is properly installed and running
- Check server console for any errors
- Verify the command name in config matches what you're typing

### Players not syncing
- Verify server-side script is running
- Check network connectivity between clients and server
- Review server console for synchronization errors

## Support

For issues, questions, or contributions:
- Create an issue on GitHub
- Contact: ChiLLLix-hub

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

- **Author**: ChiLLLix-hub
- **Framework**: [QBCore Framework](https://github.com/qbcore-framework/qb-core)
- **Zone System**: [PolyZone](https://github.com/mkafrin/PolyZone)

## Changelog

### Version 1.1.0
- Added stress management system
- Gradual stress reduction when in zone (configurable rate per minute)
- Smart stress detection (checks on entry, informs if already at 0)
- Automatic notification when stress reaches 0
- Stress reduction stops when player exits zone
- Fully configurable stress management settings

### Version 1.0.0
- Initial release
- Automatic shoe removal/restoration in zone
- Manual `/shoes` command
- Player synchronization
- Support for Box, Circle, and Poly zones
- Configurable animations and messages
