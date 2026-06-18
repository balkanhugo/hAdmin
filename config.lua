Config = Config or {}

-- =================================
-- LOCALIZATION SETTINGS
-- =================================
Config.Locale = 'hr' -- Available: 'en', 'hr'

-- =================================
-- ADMIN GROUP CONFIGURATION
-- =================================

Config.Groups = {
    default = 'user',

    -- Order of groups (lowest to highest)
    order = {
        'user',
        'designer',
        'car_developer',
        'osnivac',
        'scripter'
    },

    labels = {
        user          = 'User',
        designer      = 'Designer',
        car_developer = 'Car Developer',
        osnivac       = 'Osnivac',
        scripter      = 'Scripter'
    },

    index = {
        user          = 1,
        designer      = 2,
        car_developer = 3,
        osnivac       = 4,
        scripter      = 5
    },

    -- Who can set which groups
    permissions = {
        scripter = {
            'user', 'designer', 'car_developer', 'osnivac'
        },

        osnivac = {
            'user', 'designer', 'car_developer'
        }
    }
}

-- Helper function to check if a group is an admin
Config.IsAdminGroup = function(group)
    return group ~= 'user'
end

-- =================================
-- ADMIN TAG CONFIGURATION
-- =================================

Config.AdminTags = {
    SeeOwnLabel = true,
    SeeDistance = 20,
    TextSize = 0.8,
    ZOffset = 1.0,
    NearCheckWait = 500,
    TagByPermission = false,

    -- Colors for admin group
    Colors = {
        scripter      = { r = 5, g = 228, b = 64, a = 1.0 },
        osnivac       = { r = 255, g = 140, b = 0, a = 1.0 },
        car_developer = { r = 0, g = 140, b = 255, a = 1.0 },
        designer      = { r = 160, g = 32, b = 240, a = 1.0 }
    },

    DefaultColor = { r = 255, g = 255, b = 255, a = 1.0 }
}

Config.PermissionLabels = {
    [1] = "USER",
    [2] = "DESIGNER",
    [3] = "CAR DEVELOPER",
    [4] = "OSNIVAC",
    [5] = "SKRIPTER"
}

-- =================================
-- PERMISSIONS CONFIGURATION
-- =================================
Config.Permissions = {
    noclip = {
        'scripter', 'car_developer', 'designer', 'osnivac'
    },

    invisible = {
        'scripter', 'car_developer', 'designer', 'osnivac'
    },

    heal = {
        'scripter', 'car_developer', 'designer', 'osnivac'
    },

    revive = {
        'scripter', 'car_developer', 'designer', 'osnivac'
    },

    setJob = {
        'scripter', 'car_developer', 'designer', 'osnivac'
    },

    setGroup = {},

    giveItem = {
        'scripter', 'car_developer', 'designer', 'osnivac'
    },

    giveVehicle = {
        'scripter', 'car_developer', 'designer', 'osnivac'
    },

    givecar = {
        'scripter', 'car_developer', 'designer', 'osnivac'
    },

    removecar = {
        'scripter', 'car_developer', 'designer', 'osnivac'
    },

    fixVehicle = {
        'scripter', 'car_developer', 'designer', 'osnivac'
    },

    markeri = {
        'scripter', 'car_developer', 'designer', 'osnivac'
    },

    gotoplayer = {
        'scripter', 'car_developer', 'designer', 'osnivac'
    },

    bringplayer = {
        'scripter', 'car_developer', 'designer', 'osnivac'
    },

    teleportwaypoint = {
        'scripter', 'car_developer', 'designer', 'osnivac'
    }
}

-- =================================
-- NOCLIP CONFIGURATION
-- =================================

Config.Noclip = {
    controls = {
        openKey      = 288,  -- F1
        goUp         = 52,   -- Q
        goDown       = 20,   -- Z
        turnLeft     = 34,   -- A
        turnRight    = 35,   -- D
        goForward    = 32,   -- W
        goBackward   = 33,   -- S
        changeSpeed  = 21,   -- LSHIFT
    },

    speeds = {
        { label_key = "speed_very_slow", speed = 0 },
        { label_key = "speed_slow", speed = 0.5 },
        { label_key = "speed_normal", speed = 2 },
        { label_key = "speed_fast", speed = 4 },
        { label_key = "speed_very_fast", speed = 6 },
        { label_key = "speed_faster", speed = 10 },
        { label_key = "speed_faster_v2", speed = 20 },
        { label_key = "speed_zoom", speed = 25 }
    },

    offsets = {
        y = 0.5,
        z = 0.5,
        h = 5,
    },

    background = {
        r = 0,
        g = 0,
        b = 0,
        a = 50
    }
}

-- =================================
-- ADMIN MENU CONFIGURATION
-- =================================

Config.OpenMenuCommand = 'openadmin'
Config.OpenMenuKey = 'F4'
Config.OpenMenuLabel = 'Otvori Admin Menu'

Config.GiveCarCommand = 'givecar'
Config.RemoveCarCommand = 'removecar'

-- =================================
-- REPORT SYSTEM CONFIGURATION
-- =================================

Config.Reports = {
    Lock = {
        Enable             = true,
        OnlyTakerCanAction = true,
        OnlyTakerCanDelete = true
    },

    Command = 'pomoc' -- command to open report menu
}

-- =================================
-- COMMUNITY SERVICE CONFIGURATION
-- =================================

Config.CommunityService = {
    -- Enable/Disable community service system
    Enabled = true,

    -- Command to open community service menu
    Command = 'communityservice',

    -- Groups that can access community service commands
    AuthorizedGroups = {
        ["osnivac"] = true,
        ["scripter"] = true,
        ["car_developer"] = true,
        ["designer"] = true
    },

    -- Jobs that can use community service (via ox_target)
    JobRolesAccess = {
        ["police"] = true,
        ["sheriff"] = true,
    },

    -- Location where players will clean trash
    ServiceLocation = vector3(3054.2637, -4694.6846, 14.2614),

    -- Coordinates where to teleport player when finished
    EndServiceLocation = vector3(427.2343, -979.8491, 30.7100),

    -- Maximum distance player can move from service location
    MaxDistance = 30.0,

    -- Maximum distance to target nearby players
    MaxTargetDistance = 10.0,

    -- How many props will spawn at once
    MaxProps = 5,

    -- Prop models for cleaning
    Props = {
        'prop_rub_binbag_sd_01',
        'prop_rub_binbag_01',
        'prop_cs_rub_binbag_01',
    },

    -- Time between automatic healing (in minutes)
    HealInterval = 5,

    -- Progress bar settings
    ProgressBar = {
        Duration = 5000, -- milliseconds
        Label = 'cleaning_trash',
        Position = 'bottom',
        Animation = {
            Dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
            Clip = 'machinic_loop_mechandplayer'
        }
    },

    -- Remove items/weapons from player when sent to community service
    RemoveInventory = true,
    RemoveWeapons = true,
    RemoveMoney = true,

    -- Disable actions while in community service
    DisableCombat = true,
    DisableVehicles = true,
    DisableJobActions = true,
}

-- =================================
-- DISCORD LOGGING CONFIGURATION
-- =================================

Config.AdminLogs = {
    revive = {
        enabled = true,
        webhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE"
    },
    heal = {
        enabled = true,
        webhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE"
    },
    setjob = {
        enabled = true,
        webhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE"
    },
    setgroup = {
        enabled = true,
        webhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE"
    },
    giveitem = {
        enabled = true,
        webhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE"
    },
    givevehicle = {
        enabled = true,
        webhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE"
    },
    givecar = {
        enabled = true,
        webhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE"
    },
    removecar = {
        enabled = true,
        webhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE"
    },
    gotoplayer = {
        enabled = true,
        webhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE"
    },
    bringplayer = {
        enabled = true,
        webhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE"
    },
    duty = {
        enabled = true,
        webhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE"
    },
    communityservice = {
        enabled = true,
        webhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE"
    },
    boostvehicle = {
        enabled = true,
        webhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE"
    }
}