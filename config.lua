Config = Config or {}

-- =================================
-- LOCALIZATION SETTINGS
-- =================================
Config.Locale = 'hr' -- Available: 'en', 'hr'

-- =================================
-- ADMIN GROUP CONFIGURATION
-- =================================

Config.Groups = {
    -- Default group for non-admins
    default = 'user',

    -- Order of groups (lowest to highest)
    order = {
        'user',
        'helper',
        'admin',
        'spadmin',
        'headadmin',
        'direktor',
        'developer',
        'owner'
    },

    -- Display labels for each group
    labels = {
        user       = 'User',
        helper     = 'Helper',
        admin      = 'Admin',
        spadmin    = 'Super Admin',
        headadmin  = 'Head Admin',
        direktor   = 'Direktor',
        developer  = 'Developer',
        owner      = 'Owner'
    },

    -- Numerical index for comparison (higher = more permissions)
    index = {
        user       = 1,
        helper     = 2,
        admin      = 3,
        spadmin    = 4,
        headadmin  = 5,
        direktor   = 6,
        developer  = 7,
        owner      = 8
    },

    -- Which groups can set which other groups
    permissions = {
        spadmin   = { 'user', 'helper', 'admin' },
        headadmin = { 'user', 'helper', 'admin', 'spadmin' },
        direktor  = { 'user', 'helper', 'admin', 'spadmin', 'headadmin' },
        developer = { 'user', 'helper', 'admin', 'spadmin', 'headadmin', 'direktor' },
        owner     = { 'user', 'helper', 'admin', 'spadmin', 'headadmin', 'direktor', 'developer' }
    }
}

-- Helper function to check if a group is an admin
Config.IsAdminGroup = function(group)
    return Config.Groups.index[group] and Config.Groups.index[group] > 1
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

    -- Colors for each admin group
    Colors = {
        helper      = { r = 5,   g = 228, b = 64,  a = 1.0 },
        admin       = { r = 5,   g = 228, b = 64,  a = 1.0 },
        headadmin   = { r = 5,   g = 146, b = 228, a = 6.0 },
        spadmin     = { r = 228, g = 109, b = 5,   a = 6.0 },
        direktor    = { r = 5,   g = 146, b = 228, a = 6.0 },
        developer   = { r = 238, g = 22,  b = 22,  a = 6.0 },
        owner       = { r = 238, g = 22,  b = 22,  a = 6.0 }
    },

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
    [1] = "HELPER",
    [2] = "~g~MODERATOR",
    [3] = "~b~ADMINISTRATOR",
    [4] = "~r~GOD",
    [5] = "~r~GOD",
}

-- =================================
-- PERMISSIONS CONFIGURATION
-- =================================

Config.Permissions = {
    noclip           = { 'admin', 'spadmin', 'headadmin', 'direktor', 'owner', 'developer' },
    invisible        = { 'spadmin', 'headadmin', 'direktor', 'owner', 'developer' },
    heal             = { 'admin', 'spadmin', 'headadmin', 'direktor', 'owner', 'developer' },
    revive           = { 'admin', 'spadmin', 'headadmin', 'direktor', 'owner', 'developer' },
    setJob           = { 'spadmin', 'headadmin', 'direktor', 'owner', 'developer' },
    setGroup         = { 'headadmin', 'direktor', 'owner', 'developer' },
    giveItem         = { 'headadmin', 'direktor', 'owner', 'developer' },
    giveVehicle      = { 'admin', 'spadmin', 'headadmin', 'direktor', 'owner', 'developer' },
    fixVehicle       = { 'admin', 'spadmin', 'headadmin', 'direktor', 'owner', 'developer' },
    markeri          = { 'admin', 'spadmin', 'headadmin', 'direktor', 'owner', 'developer' },
    gotoplayer       = { 'helper', 'admin', 'spadmin', 'headadmin', 'direktor', 'owner', 'developer' },
    bringplayer      = { 'helper', 'admin', 'spadmin', 'headadmin', 'direktor', 'owner', 'developer' },
    teleportwaypoint = { 'helper', 'admin', 'spadmin', 'headadmin', 'direktor', 'owner', 'developer' }
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
    -- Report locking settings
    Lock = {
        Enable              = true,  -- Lock reports when taken
        OnlyTakerCanAction  = true,  -- Only the admin who took it can act
        OnlyTakerCanDelete  = true   -- Only the admin who took it can delete
    },

    -- Report command configuration
    Command = {
        Name  = 'report',
        Name2 = 'communityservice', -- Community service command (for "Daj markere")
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
