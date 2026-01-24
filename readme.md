# hAdmin

A comprehensive admin system for FiveM ESX servers with reports, admin tags, and noclip functionality.

## Features

- **Admin Menu** - Full-featured admin panel with player management
- **Report System** - Player reporting with admin response
- **Admin Tags** - Visible tags above admin heads when on duty
- **Noclip** - Smooth noclip with multiple speed levels
- **Player ID Display** - Toggle player IDs on/off
- **Teleportation** - Go to player, bring player, teleport to waypoint
- **Player Management** - Heal, revive, set job, set group, give items/vehicles
- **Discord Logging** - All admin actions logged to Discord webhooks

## Installation

### Step 1: Database
No database changes required - the script uses ESX's built-in functions.

### Step 2: ESX Modifications

You need to add two functions to your ESX core to track admin duty status.

**File:** `es_extended/server/classes/player.lua`

Find this line (use Ctrl+F):
```lua
self.metadata = metadata
```

Add this code **below** it:
```lua
self.adminDuznost = false
```

Then find this function:
```lua
function self.triggerEvent(eventName, ...)
    assert(type(eventName) == "string", "eventName should be string!")
    TriggerClientEvent(eventName, self.source, ...)
end
```

Add this code **below** the entire function:
```lua
self.staviDuznost = function(bool)
    self.adminDuznost = bool
end

self.proveriDuznost = function()
    return self.adminDuznost
end
```

**Visual Guide:** See the example screenshots:
- https://imgur.com/a/v5dX94S
- https://drive.google.com/file/d/1bS3gX0OIMH4YZAcuSS7QGBn23vdVQtSk/view?usp=sharing

### Step 3: Community Service (Optional)

For the "Daj markere" (community service) feature to work, install:
https://github.com/tjscriptss/tj_communityservice

Update `config.lua` with your community service command:
```lua
Config.Reports.Command.Name2 = 'communityservice'
```

### Step 4: Configuration

1. Edit `config.lua` to configure:
   - Admin group names and hierarchy
   - Permissions for each admin level
   - Discord webhook URLs for logging
   - Command keys and controls
   - Report system settings

2. Set your Discord webhooks in `Config.AdminLogs`

3. Adjust permissions in `Config.Permissions` to match your admin structure

## Usage

### Admin Commands
- **F4** (default) - Open admin menu
- `/openadmin` - Alternative way to open menu
- `/id` - Toggle player IDs (must be on duty)
- `/report` - Submit a report to admins

### Admin Menu Features
When on duty, admins can access:
- View and manage reports
- View online players
- Teleport functions
- Player management (heal, revive, etc.)
- Job and group management
- Vehicle and item giving
- Noclip and invisibility

## Configuration

All settings are in `config.lua`:

- **Admin Groups** - Define your server's admin hierarchy
- **Permissions** - Set which groups can use which features
- **Colors** - Customize admin tag colors
- **Controls** - Change keybinds
- **Discord Logs** - Configure webhook URLs for each action type

## Support

For issues or questions:
- Discord: lazicdev

## Credits

**Author:** lazicdev & chiaroscuric 
**Version:** 1.0.2

## License

This is a free resource for the FiveM community.
