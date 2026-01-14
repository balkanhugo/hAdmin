Config = {}

-- TAG --

Config.SeeOwnLabel = true
Config.SeeDistance = 20
Config.TextSize = 0.8
Config.ZOffset = 1.0
Config.NearCheckWait = 500
Config.TagByPermission = false

Config.GroupLabels = {
    helper = "helper",
    admin = "admin",
    superadmin = "super admin",
    headadmin = "head admin",
	direktor = "direktor",
    developer = "developer",
    owner = "owner",
}

Config.PermissionLabels = {
    [1] = "HELPER",
    [2] = "~g~MODERATOR",
    [3] = "~b~ADMINISTRATOR",
    [4] = "~r~GOD",
    [5] = "~r~GOD",
}

Config.AdminTags = {
    Colors = {
        helper      = { r = 5,   g = 228, b = 64,  a = 1.0 },
        admin       = { r = 5,   g = 228, b = 64,  a = 1.0 },
        headadmin   = { r = 5,   g = 146, b = 228, a = 6.0 },
        superadmin  = { r = 228, g = 109, b = 5,   a = 6.0 },
        direktor    = { r = 5,   g = 146, b = 228, a = 6.0 },
        developer   = { r = 238, g = 22,  b = 22,  a = 6.0 },
        owner       = { r = 238, g = 22,  b = 22,  a = 6.0 }
    },

    DefaultColor = { r = 255, g = 255, b = 255, a = 1.0 }
}

Config.Noclip = {
    controls = {
        openKey = 288,
        goUp = 52,
        goDown = 20,
        turnLeft = 34,
        turnRight = 35,
        goForward = 32,
        goBackward = 33,
        changeSpeed = 21,
    },

    speeds = {
        { label = "Veoma Sporo", speed = 0 },
        { label = "Sporo", speed = 0.5 },
        { label = "Normalno", speed = 2 },
        { label = "Brzo", speed = 4 },
        { label = "Veoma Brzo", speed = 6 },
        { label = "Jos Brze", speed = 10 },
        { label = "Jos Brze v2", speed = 20 },
        { label = "zummmm", speed = 25 }
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

-- ADMIN MENU --

Config.OpenMenuCommand = 'openadmin'
Config.OpenMenuKey = 'F4'
Config.OpenMenuLabel = 'Otvori Admin Menu'

-- PERMISSIONS FOR COMMAND IN ADMIN MENU --

Config.Groups = {
    user = 1,
    helper = 2,
    admin = 3,
    spadmin = 4,
    headadmin = 5,
    direktor = 6,
    developer = 7,
    owner = 8
}

Config.Permissions = {
    noclip = { 'admin', 'spadmin', 'headadmin', 'direktor', 'owner', 'developer' },
    invisible = { 'spadmin', 'headadmin', 'direktor', 'owner', 'developer' },
    heal = { 'admin', 'spadmin', 'headadmin', 'direktor', 'owner', 'developer' },
    revive = { 'admin', 'spadmin', 'headadmin', 'direktor', 'owner', 'developer' },
    setJob = { 'spadmin', 'headadmin', 'direktor', 'owner', 'developer' },
    setGroup = { 'headadmin', 'direktor', 'owner', 'developer' },
    giveItem = { 'headadmin', 'direktor', 'owner', 'developer' },
    giveVehicle = { 'admin', 'spadmin', 'headadmin', 'direktor', 'owner', 'developer' },
    fixVehicle = { 'admin', 'spadmin', 'headadmin', 'direktor', 'owner', 'developer' },
    markeri = { 'admin', 'spadmin', 'headadmin', 'direktor', 'owner', 'developer' },
    gotoplayer = { 'helper', 'admin', 'spadmin', 'headadmin', 'direktor', 'owner', 'developer' },
    bringplayer = { 'helper', 'admin', 'spadmin', 'headadmin', 'direktor', 'owner', 'developer' },
    teleportwaypoint = { 'helper', 'admin', 'spadmin', 'headadmin', 'direktor', 'owner', 'developer' }
}

-- SETJOB FUNCTION --

Config.Groups = {
    default = 'user',

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

    permissions = {
        spadmin   = { 'user', 'helper', 'admin' },
        headadmin = { 'user', 'helper', 'admin', 'spadmin' },
        direktor  = { 'user', 'helper', 'admin', 'spadmin', 'headadmin' },
        developer = { 'user', 'helper', 'admin', 'spadmin', 'headadmin', 'direktor' },
        owner     = { 'user', 'helper', 'admin', 'spadmin', 'headadmin', 'direktor', 'developer' }
    },

    messages = {
        selfSet      = '❌ Ne mozete menjati sebi',
        higherGroup  = '❌ Ne mozete setovati vecu grupu',
        sameGroup    = '❌ Ne mozete setovati istu grupu kao vase'
    }
}

-- REPORT --

Config.Reports = {

    StatusText = {
        active = '🟢 Aktivno',
        taken = '🟡 U obradi',
        completed = '✅ Zavrseno',
        deleted = '❌ Obrisano'
    },

    StatusActionText = {
        active = '🟢 Aktivan',
        taken = '🟡 U obradi'
    },

    Categories = {
        player = 'Prijava igraca',
        bug = 'Prijava baga',
        cheater = 'Cheating',
        cheating = 'Cheating',
        admin = 'Prijava admina'
    },

    Lock = {
        Enable = true,            -- da li se report zakljucava
        OnlyTakerCanAction = true,-- samo onaj koji je uzeo moze akcije
        OnlyTakerCanDelete = true -- samo onaj koji je uzeo moze obrisati
    },

    Text = {
        Free = 'Slobodno',
        TakenBy = 'Preuzeo: ',
        Take = 'Preuzmi Report',
        Release = 'Oslobodi Report',
        TakeDesc = 'Preuzmi report da ga radis'
    }
}

Config.Reports.Command = {

    Name = 'report',

    Name2 = 'communityservice', -- communityservice command put the same command here (best script for community service: https://youtu.be/4ZW8LyM1bSo?si=Iq2hU2w9vmlUz39V - brat trowe

    Dialog = {
        Title = 'Report',
        SubmitText = 'Posalji',
    },

    Fields = {
        Title = {
            label = 'Naslov',
            placeholder = 'Kratak naslov',
            required = true
        },

        Category = {
            label = 'Tip',
            required = true
        },

        Details = {
            label = 'Detalji',
            placeholder = 'Objasni problem',
            required = true
        }
    },

    Categories = {
        { label = 'Cheating', value = 'cheater' },
        { label = 'Bug', value = 'bug' },
        { label = 'Prijava igraca', value = 'player' },
        { label = 'Prijava staffa', value = 'admin' }
    },

    Notify = {
        Success = 'Tvoj report je poslat adminima!',
        Cancel = 'Report otkazan'
    }
}

-- LOGS --

Config.AdminLogs = {
    revive = {
        enabled = true,
        webhook = "https://discord.com/api/webhooks/1460971512868638722/B9kplhcq6m_HY_m5f0Inr84r1yI0Vb1SrPIPSyHtxLpzrOMFmZrvLRNW0Cqr5ycz-2LS"
    },
    heal = {
        enabled = true,
        webhook = "https://discord.com/api/webhooks/1460971512868638722/B9kplhcq6m_HY_m5f0Inr84r1yI0Vb1SrPIPSyHtxLpzrOMFmZrvLRNW0Cqr5ycz-2LS"
    },
    setjob = {
        enabled = true,
        webhook = "https://discord.com/api/webhooks/1460971512868638722/B9kplhcq6m_HY_m5f0Inr84r1yI0Vb1SrPIPSyHtxLpzrOMFmZrvLRNW0Cqr5ycz-2LS"
    },
    setgroup = {
        enabled = true,
        webhook = "https://discord.com/api/webhooks/1460971512868638722/B9kplhcq6m_HY_m5f0Inr84r1yI0Vb1SrPIPSyHtxLpzrOMFmZrvLRNW0Cqr5ycz-2LS"
    },
    giveitem = {
        enabled = true,
        webhook = "https://discord.com/api/webhooks/1460971512868638722/B9kplhcq6m_HY_m5f0Inr84r1yI0Vb1SrPIPSyHtxLpzrOMFmZrvLRNW0Cqr5ycz-2LS"
    },
    givevehicle = {
        enabled = true,
        webhook = "https://discord.com/api/webhooks/1460971512868638722/B9kplhcq6m_HY_m5f0Inr84r1yI0Vb1SrPIPSyHtxLpzrOMFmZrvLRNW0Cqr5ycz-2LS"
    },
    gotoplayer = {
        enabled = true,
        webhook = "https://discord.com/api/webhooks/1460971512868638722/B9kplhcq6m_HY_m5f0Inr84r1yI0Vb1SrPIPSyHtxLpzrOMFmZrvLRNW0Cqr5ycz-2LS"
    },
    bringplayer = {
        enabled = true,
        webhook = "https://discord.com/api/webhooks/1460971512868638722/B9kplhcq6m_HY_m5f0Inr84r1yI0Vb1SrPIPSyHtxLpzrOMFmZrvLRNW0Cqr5ycz-2LS"
    },
    duty = {
        enabled = true,
        webhook = "https://discord.com/api/webhooks/1460971512868638722/B9kplhcq6m_HY_m5f0Inr84r1yI0Vb1SrPIPSyHtxLpzrOMFmZrvLRNW0Cqr5ycz-2LS"
    }
}