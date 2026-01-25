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
        'probniadmin',
        'admin',
        'roleplayadmin',
        'eventadmin',
        'headstaff',
        'vodjalidera',
        'vodjastaffa',
        'manager',
        'osnivac',
        'jaankeza',
        'developer'
    },

    labels = {
        user          = 'User',
        probniadmin   = 'Probni Admin',
        admin         = 'Admin',
        roleplayadmin = 'Roleplay Admin',
        eventadmin    = 'Event Admin',
        headstaff     = 'Head Staff',
        vodjalidera   = 'Vodja Lidera',
        vodjastaffa   = 'Vodja Staffa',
        manager       = 'Manager',
        osnivac       = 'Osnivac',
        jaankeza      = 'Jaankeza',
        developer     = 'Developer'
    },

    index = {
        user          = 1,
        probniadmin   = 2,
        admin         = 3,
        roleplayadmin = 4,
        eventadmin    = 5,
        headstaff     = 6,
        vodjalidera   = 7,
        vodjastaffa   = 8,
        manager       = 9,
        osnivac       = 10,
        jaankeza      = 11,
        developer     = 12
    },

    -- Who can set which groups
    permissions = {
        developer = {
            'user','probniadmin','admin','roleplayadmin','eventadmin',
            'headstaff','vodjalidera','vodjastaffa','manager','osnivac','jaankeza'
        },

        jaankeza = {
            'user','probniadmin','admin','roleplayadmin','eventadmin',
            'headstaff','vodjalidera','vodjastaffa','manager','osnivac'
        },

        osnivac = {
            'user','probniadmin','admin','roleplayadmin','eventadmin',
            'headstaff','vodjalidera','vodjastaffa','manager'
        },

        manager = {
            'user','probniadmin','admin','roleplayadmin','eventadmin'
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
    developer     = { r = 5, g = 228, b = 64, a = 1.0 },
    jaankeza      = { r = 255, g = 0, b = 0, a = 1.0 },
    osnivac       = { r = 255, g = 140, b = 0, a = 1.0 },
    manager       = { r = 0, g = 140, b = 255, a = 1.0 },
    vodjastaffa   = { r = 160, g = 32, b = 240, a = 1.0 },
    vodjalidera   = { r = 138, g = 43, b = 226, a = 1.0 },
    headstaff     = { r = 255, g = 215, b = 0, a = 1.0 },
    eventadmin    = { r = 0, g = 255, b = 255, a = 1.0 },
    roleplayadmin = { r = 50, g = 205, b = 50, a = 1.0 },
    admin         = { r = 255, g = 255, b = 255, a = 1.0 },
    probniadmin   = { r = 180, g = 180, b = 180, a = 1.0 }
    }

    DefaultColor = { r = 255, g = 255, b = 255, a = 1.0 }
}

-- Legacy support (kept for compatibility)
Config.SeeOwnLabel = Config.AdminTags.SeeOwnLabel
Config.SeeDistance = Config.AdminTags.SeeDistance
Config.TextSize = Config.AdminTags.TextSize
Config.ZOffset = Config.AdminTags.ZOffset
Config.NearCheckWait = Config.AdminTags.NearCheckWait
Config.TagByPermission = Config.AdminTags.TagByPermission

Config.GroupLabels = Config.Groups.labels

Config.PermissionLabels = {
    [1] = "USER",
    [2] = "~g~ADMIN"
}

-- =================================
-- PERMISSIONS CONFIGURATION
-- =================================
noclip = {
    'developer', 'jaankeza',
    'osnivac', 'manager', 'vodjastaffa', 'vodjalidera',
    'headstaff', 'eventadmin', 'roleplayadmin', 'admin', 'probniadmin'
},

invisible = {
    'developer', 'jaankeza',
    'osnivac', 'manager', 'vodjastaffa',
    'headstaff', 'eventadmin'
},

heal = {
    'developer', 'jaankeza',
    'osnivac', 'manager', 'vodjastaffa',
    'headstaff', 'eventadmin', 'roleplayadmin'
},

revive = {
    'developer', 'jaankeza',
    'osnivac', 'manager', 'vodjastaffa',
    'headstaff', 'eventadmin', 'roleplayadmin', 'admin', 'probniadmin'
},

setJob = {
    'developer', 'jaankeza',
    'osnivac', 'manager', 'vodjastaffa', 'vodjalidera',
    'headstaff'
},

setGroup = {
    'developer', 'jaankeza',
    'osnivac', 'manager', 'vodjastaffa'
},

giveItem = {
    'developer', 'jaankeza',
    'osnivac', 'manager', 'vodjastaffa',
    'headstaff'
},

giveVehicle = {
    'developer', 'jaankeza',
    'osnivac', 'manager', 'vodjastaffa',
    'headstaff', 'eventadmin', 'roleplayadmin', 'admin', 'probniadmin'
},

fixVehicle = {
    'developer', 'jaankeza',
    'osnivac', 'manager', 'vodjastaffa',
    'headstaff', 'eventadmin', 'roleplayadmin', 'admin', 'probniadmin'
},

markeri = {
    'developer', 'jaankeza',
    'osnivac', 'manager', 'vodjastaffa',
    'headstaff', 'eventadmin', 'roleplayadmin', 'admin', 'probniadmin'
},

gotoplayer = {
    'developer', 'jaankeza',
    'osnivac', 'manager', 'vodjastaffa',
    'headstaff', 'eventadmin', 'roleplayadmin', 'admin', 'probniadmin'
},

bringplayer = {
    'developer', 'jaankeza',
    'osnivac', 'manager', 'vodjastaffa',
    'headstaff', 'eventadmin', 'roleplayadmin', 'admin', 'probniadmin'
},

teleportwaypoint = {
    'developer', 'jaankeza',
    'osnivac', 'manager', 'vodjastaffa',
    'headstaff', 'eventadmin', 'roleplayadmin', 'admin'
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

-- =================================
-- REPORT SYSTEM CONFIGURATION
-- =================================

Config.Reports = {
    Lock = {
        Enable             = true,
        OnlyTakerCanAction = true,
        OnlyTakerCanDelete = true
    },

    Command = {
        Name  = 'report',
        Name2 = 'communityservice'
    }
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
    }
}

