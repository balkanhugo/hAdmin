local isOnDuty = false
local entity = nil

RegisterKeyMapping(Config.OpenMenuCommand, Config.OpenMenuLabel, 'keyboard', Config.OpenMenuKey)

RegisterCommand('openadmin', function()
    TriggerServerEvent('adminmenu:checkPermission')
end)

RegisterNetEvent('adminmenu:open', function()
    checkAndOpenMenu()
end)

function checkAndOpenMenu()
    ESX.TriggerServerCallback('admin:checkDuty', function(onDuty)
        isOnDuty = onDuty
        
        if isOnDuty then
            openAdminPanel()
        else
            openDutyMenu()
        end
    end)
end

RegisterNetEvent('admin:onDutyEntered')
AddEventHandler('admin:onDutyEntered', function()
    isOnDuty = true
    Citizen.Wait(300)
    openAdminPanel()
end)

function openDutyMenu()
    lib.registerContext({
        id = 'duty_menu',
        title = 'Admin Meni',
        menu = 'admin_panel',
        options = {
            {
                title = 'Udji na duznost',
                description = 'Pokreni admin duznost',
                icon = 'user-shield',
                onSelect = function()
                    TriggerServerEvent('admin:enterDuty')
                end
            }
        }
    })
    
    lib.showContext('duty_menu')
end

local function HasPermission(allowedGroups)
    local playerGroup = ESX.PlayerData.group

    for _, group in ipairs(allowedGroups) do
        if playerGroup == group then
            return true
        end
    end

    return false
end

function openAdminPanel()
    lib.registerContext({
        id = 'admin_panel',
        title = 'Admin Menu',
        menu = 'duty_menu',
        options = {
            {
                title = 'Reports',
                description = 'Pregledaj aktivne reportove',
                icon = 'clipboard-list',
                onSelect = function()
                    ESX.TriggerServerCallback('reports:getAllReports', function(allReports)
                        local options = {}

                        for id, report in pairs(allReports) do
                            if report.status ~= 'deleted' then
                            local statusText = Config.Reports.StatusText[report.status] or report.status
                            local takenText = report.takenByName
                                and (Config.Reports.Text.TakenBy .. report.takenByName)
                                or Config.Reports.Text.Free

                                local displayTitle = string.format('%s | ID: %d | Naslov: %s', 
                                    report.steamName, 
                                    report.playerId,
                                    report.title, 
                                    report.category
                                )

                                table.insert(options, {
                                    title = displayTitle,
                                    description = report.details,
                                    arrow = true,
                                    onSelect = function()
                                        openReportActions(id, report)
                                    end
                                })
                            end
                        end

                        lib.registerContext({
                            id = 'admin_reports',
                            title = 'Reports',
                            menu = 'admin_panel',
                            options = options
                        })

                        lib.showContext('admin_reports')
                    end)
                end
            },
            {
                title = 'Players',
                description = 'Lista online igraca',
                icon = 'users',
                onSelect = function()
                    openPlayersList()
                end
            },
            {
                title = 'ID',
                description = 'Ukljuci / Iskljuci ID',
                icon = 'id-badge',
                onSelect = function()
                    openPlayerID()
                end
            },
            {
                title = 'Teleport to Waypoint',
                description = 'Teleportuj se na postavljeni marker',
                icon = 'location-dot',
                onSelect = function()
                    if not HasPermission(Config.Permissions.teleportwaypoint) then
                        return lib.notify({
    title = 'Admin Sistem',
    description = 'Nemas dozvolu za ovu opciju.',
    type = 'error',
    duration = 3000
})
                    end
                    local waypoint = GetFirstBlipInfoId(8)
                    local ped = PlayerPedId()

                    if not DoesBlipExist(waypoint) then
                        return lib.notify({
    title = 'Admin Sistem',
    description = 'Nemas postavljen marker.',
    type = 'error',
    duration = 3000
})
                    end

                    local coords = GetBlipInfoIdCoord(waypoint)
                    local safeX, safeY = coords.x, coords.y
                    local tempZ = 200.0

                    local entity = ped
                    local vehicle = GetVehiclePedIsIn(ped, false)

                    if vehicle ~= 0 then
                        entity = vehicle
                    end

                    SetEntityCoords(entity, safeX, safeY, tempZ, false, false, false, false)
                    Wait(300)

                    local foundGround, groundZ = GetGroundZFor_3dCoord(safeX, safeY, 1000.0, false)

                    if foundGround then
                        SetEntityCoords(entity, safeX, safeY, groundZ + 1.0, false, false, false, false)
                    else
                        SetEntityCoords(entity, safeX, safeY, 50.0, false, false, false, false)
                    end

                    if vehicle ~= 0 then
                        SetPedIntoVehicle(ped, vehicle, -1)
                    end

                    ESX.ShowNotification('Teleportovan si do markera.')
                end
            },
            {
                title = 'Bring Player',
                description = 'Teleportuj igraca do sebe',
                icon = 'user-plus',
                onSelect = function()
                    if not HasPermission(Config.Permissions.bringplayer) then
                        return lib.notify({
    title = 'Admin Sistem',
    description = 'Nemas dozvolu za ovu opciju.',
    type = 'error',
    duration = 3000
})
                    end
                    openBringPlayerList()
                end
            },
            {
                title = 'Go To Player',
                description = 'Teleportuj se do igraca',
                icon = 'user-check',
                onSelect = function()
                    if not HasPermission(Config.Permissions.gotoplayer) then
                        return lib.notify({
    title = 'Admin Sistem',
    description = 'Nemas dozvolu za ovu opciju.',
    type = 'error',
    duration = 3000
})
                    end
                    openTeleportToPlayerList()
                end
            },
            {
                title = 'Noclip',
                description = 'Ukljuci / Iskljuci noclip',
                icon = 'plane',
                onSelect = function()
                    if not HasPermission(Config.Permissions.noclip) then
                        return lib.notify({
    title = 'Admin Sistem',
    description = 'Nemas dozvolu za ovu opciju.',
    type = 'error',
    duration = 3000
})
                    end
                    TriggerEvent('lazicAdmin:noclip')
                end
            },
            {
                title = 'Invisible',
                description = 'Ukljuci / Iskljuci invisible',
                icon = 'ghost',
                onSelect = function()
                    if not HasPermission(Config.Permissions.invisible) then
                        return lib.notify({
    title = 'Admin Sistem',
    description = 'Nemas dozvolu za ovu opciju.',
    type = 'error',
    duration = 3000
})
                    end
                    invisiblecommand()
                end
            },
            {
                title = 'Give Vehicle',
                description = 'Daj vozilo igracu',
                icon = 'car',
                onSelect = function()
                    if not HasPermission(Config.Permissions.giveVehicle) then
                        return lib.notify({
    title = 'Admin Sistem',
    description = 'Nemas dozvolu za ovu opciju.',
    type = 'error',
    duration = 3000
})
                    end
                    openGiveVehiclePlayerList()
                end
            },
            {
                title = 'Revive Player',
                description = 'Ozivi odabranog igraca',
                icon = 'syringe',
                onSelect = function()
                    if not HasPermission(Config.Permissions.revive) then
                        return lib.notify({
    title = 'Admin Sistem',
    description = 'Nemas dozvolu za ovu opciju.',
    type = 'error',
    duration = 3000
})
                    end
                    openRevivePlayerList()
                end
            },
            {
                title = 'Heal Player',
                description = 'Izleci odabranog igraca',
                icon = 'heart',
                onSelect = function()
                    if not HasPermission(Config.Permissions.heal) then
                        return lib.notify({
    title = 'Admin Sistem',
    description = 'Nemas dozvolu za ovu opciju.',
    type = 'error',
    duration = 3000
})
                    end
                    openHealPlayerList()
                end
            },
            {
                title = 'Daj markere',
                description = 'Stavi odabranog igraca na markere',
                icon = 'broom',
                onSelect = function()
                    if not HasPermission(Config.Permissions.markeri) then
                        return lib.notify({
    title = 'Admin Sistem',
    description = 'Nemas dozvolu za ovu opciju.',
    type = 'error',
    duration = 3000
})
                    end
                    staviigracanamarkere()
                end
            },
            {
                title = 'Set Job',
                description = 'Promeni posao igracu',
                icon = 'briefcase',
                onSelect = function()
                    if not HasPermission(Config.Permissions.setJob) then
                        return lib.notify({
    title = 'Admin Sistem',
    description = 'Nemas dozvolu za ovu opciju.',
    type = 'error',
    duration = 3000
})
                    end
                    openSetJobPlayerList()
                end
            },
            {
                title = 'Set Group',
                description = 'Promeni grupu igracu',
                icon = 'users',
                onSelect = function()
                    if not HasPermission(Config.Permissions.setGroup) then
                        return lib.notify({
    title = 'Admin Sistem',
    description = 'Nemas dozvolu za ovu opciju.',
    type = 'error',
    duration = 3000
})
                    end
                    openSetGroupPlayerList()
                end
            },
            {
                title = 'Give Item',
                description = 'Daj item igracu',
                icon = 'gift',
                onSelect = function()
                    if not HasPermission(Config.Permissions.giveItem) then
                        return lib.notify({
    title = 'Admin Sistem',
    description = 'Nemas dozvolu za ovu opciju.',
    type = 'error',
    duration = 3000
})
                    end
                    openGiveItemPlayerList()
                end
            },
            {
                title = 'Fix Vehicle',
                description = 'Popravi vozilo',
                icon = 'wrench',
                onSelect = function()
                    if not HasPermission(Config.Permissions.fixVehicle) then
                        return lib.notify({
    title = 'Admin Sistem',
    description = 'Nemas dozvolu za ovu opciju.',
    type = 'error',
    duration = 3000
})
                    end
                    popravijebenovozilo()
                end
            },
            {
                title = 'Delete Vehicle',
                description = 'Obrisi vozilo',
                icon = 'xmark',
                onSelect = function()
                    obrisijebenovozilo()
                end
            },
            {
                title = 'Izadji sa duznosti',
                description = 'Zavrzi admin duznost',
                icon = 'power-off',
                onSelect = function()
                    TriggerEvent('lazicAdmin2:showIDs2')
                    TriggerServerEvent('admin:leaveDuty')
                end
            }
        }
    })
    
    lib.showContext('admin_panel')
end

function openReportActions(reportId, report)
    local reportTime = report.createdAt or "Nepoznato"
    local myServerId = GetPlayerServerId(PlayerId())
    local isTakenByMe = report.takenBy == myServerId
    local isLocked = report.takenBy ~= nil and not isTakenByMe
    
    if type(report.createdAt) == "number" then
        local hours = math.floor((report.createdAt % 86400) / 3600)
        local minutes = math.floor((report.createdAt % 3600) / 60)
        local seconds = math.floor(report.createdAt % 60)
        reportTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    end

    local statusText = Config.Reports.StatusActionText[report.status]
        or Config.Reports.StatusText[report.status]
        or report.status

    local statusData = Config.Reports.StatusText[report.status] 
        or { text = report.status or "Aktivan", color = "white" }

    local categoryText = Config.Reports.Categories[report.category]
        or report.category
        or "Nepoznato"

    local takenStatus = report.takenBy
        and Config.Reports.StatusActionText.taken
        or Config.Reports.StatusActionText.active

    local takenByText = report.takenByName
        and (Config.Reports.Text.TakenBy .. report.takenByName)
        or "Niko nije preuzeo"

    lib.registerContext({
        id = 'report_actions_'..reportId,
        title = "#" .. reportId .. " - " .. (report.title or "Bez naslova"),
        menu = 'admin_reports',
        options = {
            {
                title = "Tip: " .. categoryText,
                description = "Status: " .. takenStatus,
                icon = 'clock',
                readOnly = true
            },
            {
                title = "Pogledaj Detalje",
                description = report.details or "Nema detalja",
                icon = 'file-lines',
                readOnly = true
                -- onSelect = function()
                --     exports['lmod-notify']:sendnotify("Detalji: " .. (report.details or "Nema detalja"), 1, 5000)
                -- end
            },
            {
                title = "Go To Player",
                description = "Teleportuj se do " .. (report.steamName or "igraca"),
                icon = 'location-dot',
                disabled = not isOnDuty or (Config.Reports.Lock.Enable and Config.Reports.Lock.OnlyTakerCanDelete and isLocked),
                onSelect = function()
                    TriggerServerEvent('admin:teleportToPlayer', report.playerId)
                    lib.notify({
                        title = 'Admin Sistem',
                        description = "Teleportovan si do " .. (report.steamName or "igraca"),
                        type = 'success',
                        duration = 3000
                    })
                end
            },
            {
                title = "Bring Player",
                description = "Teleportuj " .. (report.steamName or "igraca") .. " do sebe",
                icon = 'user-plus',
                disabled = not isOnDuty or (Config.Reports.Lock.Enable and Config.Reports.Lock.OnlyTakerCanDelete and isLocked),
                onSelect = function()
                    local ped = PlayerPedId()
                    local coords = GetEntityCoords(ped)
                    TriggerServerEvent('admin:teleportPlayerToMe', report.playerId, coords)
                    lib.notify({
                        title = 'Admin Sistem',
                        description = "Doveo si " .. (report.steamName or "igraca") .. " do sebe",
                        type = 'success',
                        duration = 3000
                    })
                end
            },
            {
                title = "Posalji Poruku",
                description = "Posalji poruku " .. (report.steamName or "igracu"),
                icon = 'message',
                disabled = not isOnDuty or (Config.Reports.Lock.Enable and Config.Reports.Lock.OnlyTakerCanDelete and isLocked),
                onSelect = function()
                    local input = lib.inputDialog(
                        'Posalji poruku ' .. (report.steamName or "igracu"),
                        {
                            {
                                type = 'textarea',
                                label = 'Poruka',
                                placeholder = 'Unesi poruku za igraca',
                                required = true,
                                rows = 4
                            }
                        }
                    )

                    if not input then return end

                    TriggerServerEvent('admin:sendMessageToPlayer', report.playerId, input[1])

                    lib.notify({
                        title = 'Admin sistem',
                        description = 'Poruka poslata ' .. (report.steamName or "igracu"),
                        type = 'success'
                    })
                end
            },
            {
                title = report.takenBy and Config.Reports.Text.Release or Config.Reports.Text.Take,
                description = report.takenBy and takenByText or Config.Reports.Text.TakeDesc,
                icon = report.takenBy and 'lock-open' or 'hand',
                disabled = Config.Reports.Lock.Enable and report.takenBy ~= nil and not isTakenByMe,
                onSelect = function()
                    TriggerServerEvent(
                        'reports:updateReport',
                        reportId,
                        report.takenBy and isTakenByMe and 'release' or 'take'
                    )
                end
            },
            {
                title = "Obrisi Report",
                description = "Ukloni report iz liste",
                icon = 'trash',
                onSelect = function()
                    local confirm = lib.alertDialog({
                        header = 'Obrisi Report',
                        content = 'Da li ste sigurni da zelite da obrisete ovaj report?',
                        centered = true,
                        cancel = true,
                        labels = {
                            confirm = 'Obrisi',
                            cancel = 'Otkazi'
                        }
                    })

                    if confirm then
                        TriggerServerEvent('reports:updateReport', reportId, 'delete')
                        --exports['lmod-notify']:sendnotify("Report obrisan", 1, 3000)
                    end
                end
            }
        }
    })

    lib.showContext('report_actions_'..reportId)
end

function obrisijebenovozilo()
    ExecuteCommand('dv')
end

local invisible = false

function invisiblecommand(state)
    local ped = PlayerPedId()

    if state ~= nil then
        invisible = state
    else
        invisible = not invisible
    end

    SetEntityVisible(ped, not invisible, false)

    SetEntityCollision(ped, true, true)

    if invisible then
        SetEntityAlpha(ped, 0, false)
        lib.notify({
    title = 'Admin Sistem',
    description = 'Postali ste nevidljivi',
    type = 'success',
    duration = 3000
})
    else
        ResetEntityAlpha(ped)
        lib.notify({
    title = 'Admin Sistem',
    description = 'Ponovo ste vidljivi',
    type = 'info',
    duration = 3000
})
    end
end

function popravijebenovozilo()
    local playerPed = PlayerPedId()

    if not IsPedInAnyVehicle(playerPed, false) then
        lib.notify({
    title = 'Admin Sistem',
    description = 'Moras biti u vozilu',
    type = 'error',
    duration = 3000
})
        return
    end

    local vehicle = GetVehiclePedIsIn(playerPed, false)

    SetVehicleFixed(vehicle)
    SetVehicleDeformationFixed(vehicle)
    SetVehicleUndriveable(vehicle, false)
    SetVehicleEngineOn(vehicle, true, true)
    SetVehicleDirtLevel(vehicle, 0.0)

    lib.notify({
    title = 'Admin Sistem',
    description = 'Uspesno si popravio vozilo',
    type = 'success',
    duration = 3000
})
end

function staviigracanamarkere()
    lib.hideContext()
    ExecuteCommand(Config.Reports.Command.Name2)
end

function openPlayerID()
    ExecuteCommand('id')
end

function openPlayersList()
    ESX.TriggerServerCallback('admin:getOnlinePlayers', function(players)
        local options = {}
        
        table.insert(options, {
            title = 'Online igraci: ' .. #players,
            description = 'Trenutno na serveru',
            disabled = true
        })
        
        for _, player in ipairs(players) do
            table.insert(options, {
                title = player.name,
                description = 'ID: ' .. player.id,
                icon = 'user',
                onSelect = function()
                    openPlayerDetails(player.id, player.name)
                end
            })
        end
        
        -- table.insert(options, {
        --     title = 'Nazad',
        --     description = 'Vrati se na admin panel',
        --     icon = 'arrow-left',
        --     menu = 'admin_panel'
        -- })
        
        lib.registerContext({
            id = 'players_list',
            title = 'Players',
            menu = 'admin_panel',
            options = options
        })
        
        lib.showContext('players_list')
    end)
end

function openSetGroupPlayerList()
    ESX.TriggerServerCallback('admin:getOnlinePlayers', function(players)   
        local options = {}
        
        table.insert(options, {
            title = 'Izaberi igraca za promenu grupe',
            description = 'Promeni grupu igracu',
            disabled = true
        })
        
        for _, player in ipairs(players) do
            ESX.TriggerServerCallback('admin:getPlayerCurrentGroup', function(currentGroup)
                local groupLabel = getGroupLabel(currentGroup) or 'Nepoznato'
                
                table.insert(options, {
                    title = player.name,
                    description = 'ID: ' .. player.id .. ' | Grupa: ' .. groupLabel,
                    icon = 'user',
                    metadata = {
                        {label = 'Trenutna grupa', value = groupLabel}
                    },
                    onSelect = function()
                        openGroupSelectionMenu(player.id, player.name, currentGroup)
                    end
                })
            end, player.id)
        end
        
        Citizen.Wait(300)
        
        table.sort(options, function(a, b)
            if a.disabled or b.disabled then return false end
            return a.title < b.title
        end)
        
        lib.registerContext({
            id = 'setgroup_player_list',
            title = 'Set Group',
            menu = 'admin_panel',
            options = options
        })
        
        lib.showContext('setgroup_player_list')
    end)
end

function getGroupLabel(group)
    return Config.Groups.labels[group] or group
end

function getGroupIndex(group)
    return Config.Groups.index[group] or 1
end

function canSetGroup(myGroup, targetGroup)
    local allowed = Config.Groups.permissions[myGroup] or {}
    for _, g in ipairs(allowed) do
        if g == targetGroup then
            return true
        end
    end
    return false
end

function getGroupLabel(group)
    return Config.Groups.labels[group] or group
end

function openGroupSelectionMenu(playerId, playerName, currentGroup)
    ESX.TriggerServerCallback('admin:getMyGroup', function(myGroup)
        local options = {}

        table.insert(options, {
            title = 'Izaberi grupu za ' .. playerName,
            description = 'ID: ' .. playerId,
            disabled = true
        })

        for _, group in ipairs(Config.Groups.order) do
            local canSet = canSetGroup(myGroup, group)
            local reason = ""

            if playerId == GetPlayerServerId(PlayerId()) and group == myGroup then
                canSet = false
                reason = Config.Groups.messages.selfSet
            end

            if getGroupIndex(group) > getGroupIndex(myGroup) then
                canSet = false
                reason = Config.Groups.messages.higherGroup
            end

            if group == myGroup then
                canSet = false
                reason = Config.Groups.messages.sameGroup
            end

            table.insert(options, {
                title = getGroupLabel(group),
                description = canSet
                    and ('Postavi ' .. playerName .. ' kao ' .. getGroupLabel(group))
                    or reason,
                icon = group == currentGroup and 'circle-check' or 'user-group',
                disabled = not canSet,
                metadata = {
                    {
                        label = 'Status',
                        value = group == currentGroup and '✔️ Trenutna grupa'
                            or (canSet and '✅ Dostupno' or '❌ Zablokirano')
                    }
                },
                onSelect = function()
                    if canSet then
                        setPlayerGroup(playerId, playerName, group)
                    end
                end
            })
        end

        table.insert(options, {
            title = 'Resetuj na User',
            description = 'Vrati igraca na obicnog usera',
            icon = 'user-slash',
            metadata = {
                { label = 'Upozorenje', value = '⚠️ Ovo ce skinuti sve privilegije' }
            },
            onSelect = function()
                resetToUser(playerId, playerName)
            end
        })

        lib.registerContext({
            id = 'group_selection_menu',
            title = 'Set Group - ' .. playerName,
            menu = 'setgroup_player_list',
            options = options
        })

        lib.showContext('group_selection_menu')
    end)
end

function setPlayerGroup(playerId, playerName, group)
    local input = lib.inputDialog('Potvrdi promenu grupe za ' .. playerName, {
        {type = 'input', label = 'Razlog (obavezno)', placeholder = 'Unesi razlog za promenu...', required = true}
    })
    
    if not input then return end
    
    local reason = input[1]
    
    ESX.TriggerServerCallback('admin:setPlayerGroup', function(success, message)
        if success then
            lib.notify({
                title = 'Admin Sistem',
                description = "Uspesno ste promenili grupu igracu " .. playerName,
                type = 'success',
                duration = 3000
            })
            openSetGroupPlayerList()
        else
            lib.notify({
                title = 'Admin Sistem',
                description = message or "Greska prilikom promene grupe",
                type = 'error',
                duration = 3000
            })
        end
    end, playerId, group, reason)
end

function resetToUser(playerId, playerName)
    local input = lib.inputDialog('Potvrdi reset grupe za ' .. playerName, {
        {type = 'input', label = 'Razlog (obavezno)', placeholder = 'Unesi razlog za reset...', required = true}
    })
    
    if not input then return end
    
    local reason = input[1]
    
    ESX.TriggerServerCallback('admin:setPlayerGroup', function(success, message)
        if success then
            lib.notify({
                title = 'Admin Sistem',
                description = "✅ Uspesno resetovana grupa igracu " .. playerName,
                type = 'success',
                duration = 3000
            })
            openSetGroupPlayerList()
        else
            lib.notify({
                title = 'Admin Sistem',
                description = message or "Greska prilikom resetovanja",
                type = 'error',
                duration = 3000
            })
        end
    end, playerId, 'user', reason)
end

function openTeleportToPlayerList()
    ESX.TriggerServerCallback('admin:getOnlinePlayers', function(players)
        local options = {}
            
        table.insert(options, {
            title = 'Izaberi igraca za teleport',
            description = 'Teleportuj se do igraca',
            disabled = true
        })
        
        for _, player in ipairs(players) do
            table.insert(options, {
                title = player.name,
                description = 'ID: ' .. player.id,
                icon = 'location-dot',
                onSelect = function()
                    TriggerServerEvent('admin:teleportToPlayer', player.id, grupa)
                    ESX.ShowNotification('Teleportovan si do igraca ' .. player.name .. '!')
                end
            })
        end

        -- table.insert(options, {
        --     title = 'Nazad',
        --     description = 'Vrati se na admin panel',
        --     icon = 'arrow-left',
        --     menu = 'admin_panel'
        -- })
        
        lib.registerContext({
            id = 'teleport_to_player_list',
            title = 'Teleport Do Igraca',
            menu = 'admin_panel',
            options = options
        })
        
        lib.showContext('teleport_to_player_list')
    end)
end

function openSetJobPlayerList()
    ESX.TriggerServerCallback('admin:getOnlinePlayers', function(players)
        local options = {}
        local loaded = 0
        local total = #players

        table.insert(options, {
            title = 'Izaberi igraca za promenu posla',
            description = 'Promeni posao igracu',
            disabled = true
        })

        if total == 0 then
            return
        end

        for _, player in ipairs(players) do
            ESX.TriggerServerCallback('admin:getPlayerCurrentJob', function(currentJob)
                loaded = loaded + 1

                local jobLabel = currentJob and currentJob.label or 'Nepoznato'
                local gradeLabel = currentJob and currentJob.grade_label or 'Nepoznato'

                table.insert(options, {
                    title = player.name,
                    description = 'ID: ' .. player.id .. ' | ' .. jobLabel .. ' - ' .. gradeLabel,
                    icon = 'user',
                    metadata = {
                        {label = 'Trenutni posao', value = jobLabel},
                        {label = 'Rank', value = gradeLabel}
                    },
                    onSelect = function()
                        openJobSelectionMenu(player.id, player.name, currentJob)
                    end
                })

                if loaded == total then
                    table.sort(options, function(a, b)
                        if a.disabled or b.disabled then return false end
                        return a.title < b.title
                    end)

                    lib.registerContext({
                        id = 'setjob_player_list',
                        title = 'Set Job',
                        menu = 'admin_panel',
                        options = options
                    })

                    lib.showContext('setjob_player_list')
                end
            end, player.id)
        end
    end)
end

function openJobSelectionMenu(playerId, playerName, currentJob)
    ESX.TriggerServerCallback('admin:getAllJobs', function(jobs)
        if not jobs then
            ESX.ShowNotification('Greska pri ucitavanju poslova!')
            return
        end
        
        local options = {}
        
        table.insert(options, {
            title = 'Set Job za: ' .. playerName,
            description = 'Trenutni posao: ' .. (currentJob.label or 'Nepoznato') .. ' - ' .. (currentJob.grade_label or 'Nepoznato'),
            disabled = true
        })
        
        local sortedJobs = {}
        for jobName, jobData in pairs(jobs) do
            table.insert(sortedJobs, {
                name = jobName,
                label = jobData.label,
                grades = jobData.grades
            })
        end
        
        table.sort(sortedJobs, function(a, b)
            return a.label < b.label
        end)
        
        for _, job in ipairs(sortedJobs) do
            table.insert(options, {
                title = job.label,
                description = 'Izaberi ' .. job.label,
                icon = 'briefcase',
                arrow = true,
                onSelect = function()
                    openGradeSelectionMenu(playerId, playerName, job.name, job, currentJob)
                end
            })
        end
        
        -- table.insert(options, {
        --     title = 'Nazad',
        --     description = 'Vrati se na listu igraca',
        --     icon = 'arrow-left',
        --     menu = 'setjob_player_list'
        -- })
        
        lib.registerContext({
            id = 'job_selection_menu',
            title = 'Izaberi Posao',
            menu = 'setjob_player_list',
            options = options
        })
        
        lib.showContext('job_selection_menu')
    end)
end

function openGradeSelectionMenu(playerId, playerName, jobName, jobData, currentJob)
    local options = {}
    
    table.insert(options, {
        title = 'Izaberi Rank za: ' .. playerName,
        description = 'Posao: ' .. jobData.label,
        disabled = true
    })
    
    local sortedGrades = {}
    for gradeNum, gradeData in pairs(jobData.grades) do
        local grade = tonumber(gradeNum)
        if grade then
            table.insert(sortedGrades, {
                grade = grade,
                data = gradeData
            })
        end
    end
    
    table.sort(sortedGrades, function(a, b)
        return a.grade < b.grade
    end)
    
    for _, gradeItem in ipairs(sortedGrades) do
        local gradeNum = gradeItem.grade
        local gradeData = gradeItem.data
        
        table.insert(options, {
            title = gradeData.label,
            description = 'Salary: $' .. (gradeData.salary or 0),
            icon = 'user-tie',
            metadata = {
                {label = 'Grade', value = gradeNum},
                {label = 'Salary', value = '$' .. (gradeData.salary or 0)}
            },
            onSelect = function()
                showJobChangeConfirmation(playerId, playerName, jobName, gradeNum, jobData.label, gradeData.label, gradeData.salary)
            end
        })
    end
    
    -- table.insert(options, {
    --     title = 'Nazad',
    --     description = 'Vrati se na izbor posla',
    --     icon = 'arrow-left',
    --     menu = 'job_selection_menu'
    -- })
    
    lib.registerContext({
        id = 'grade_selection_menu',
        title = 'Izaberi Rank',
        menu = 'job_selection_menu',
        options = options
    })
    
    lib.showContext('grade_selection_menu')
end

function showJobChangeConfirmation(playerId, playerName, jobName, gradeNum, jobLabel, gradeLabel, salary)
    lib.registerContext({
        id = 'confirm_job_change',
        title = 'Potvrda Promene Posla',
        menu = 'grade_selection_menu',
        options = {
            {
                title = 'Potvrdi Promenu',
                description = playerName,
                disabled = true
            },
            {
                title = 'Novi Posao:',
                description = jobLabel .. ' - ' .. gradeLabel,
                disabled = true
            },
            {
                title = 'Plata: $' .. (salary or 0),
                description = 'Rank: ' .. gradeNum,
                disabled = true
            },
            {
                title = 'POTVRDI',
                description = 'Promeni posao igracu',
                icon = 'check',
                onSelect = function()
                    TriggerServerEvent('admin:setPlayerJob', playerId, jobName, gradeNum)
                    ESX.ShowNotification('Promenjen posao za ' .. playerName .. ' na ' .. jobLabel .. ' - ' .. gradeLabel)
                    Citizen.Wait(300)
                    openSetJobPlayerList()
                end
            },
            {
                title = 'OTKAZI',
                description = 'Vrati se nazad',
                icon = 'times',
                menu = 'grade_selection_menu'
            }
        }
    })
    
    lib.showContext('confirm_job_change')
end

function openHealPlayerList()
    ESX.TriggerServerCallback('admin:getOnlinePlayers', function(players)  
        local options = {}
        
        table.insert(options, {
            title = 'Izaberi igraca za heal',
            description = 'Izleci odabranog igraca',
            disabled = true
        })
        
        for _, player in ipairs(players) do
            table.insert(options, {
                title = player.name,
                description = 'ID: ' .. player.id,
                icon = 'heart',
                onSelect = function()
                    TriggerServerEvent('admin:healPlayer', player.id, grupa)
                    ESX.ShowNotification('Igrac ' .. player.name .. ' je izlecen!')
                end
            })
        end
        
        -- table.insert(options, {
        --     title = 'Nazad',
        --     description = 'Vrati se na admin panel',
        --     icon = 'arrow-left',
        --     menu = 'admin_panel'
        -- })
        
        lib.registerContext({
            id = 'heal_player_list',
            title = 'Heal Igraca',
            menu = 'admin_panel',
            options = options
        })
        
        lib.showContext('heal_player_list')
    end)
end

function openRevivePlayerList()
    ESX.TriggerServerCallback('admin:getOnlinePlayers', function(players)
        local options = {}
        
        table.insert(options, {
            title = 'Izaberi igraca za revive',
            description = 'Ozivi odabranog igraca',
            disabled = true
        })
        
        for _, player in ipairs(players) do
            table.insert(options, {
                title = player.name,
                description = 'ID: ' .. player.id,
                icon = 'syringe',
                onSelect = function()
                    TriggerServerEvent('admin:revivePlayer', player.id, grupa)
                    ESX.ShowNotification('Igrac ' .. player.name .. ' je ozivljen!')
                end
            })
        end

        -- table.insert(options, {
        --     title = 'Nazad',
        --     description = 'Vrati se na admin panel',
        --     icon = 'arrow-left',
        --     menu = 'admin_panel'
        -- })
        
        lib.registerContext({
            id = 'revive_player_list',
            title = 'Revive Igraca',
            menu = 'admin_panel',
            options = options
        })
        
        lib.showContext('revive_player_list')
    end)
end

function openBringPlayerList()
    ESX.TriggerServerCallback('admin:getOnlinePlayers', function(players)
        local options = {}
        
        table.insert(options, {
            title = 'Izaberi igraca za teleport',
            description = 'Teleportuj igraca do sebe',
            disabled = true
        })
        
        for _, player in ipairs(players) do
            table.insert(options, {
                title = player.name,
                description = 'ID: ' .. player.id,
                icon = 'user-plus',
                onSelect = function()
                    local playerPed = PlayerPedId()
                    local coords = GetEntityCoords(playerPed)
                    
                    TriggerServerEvent('admin:teleportPlayerToMe', player.id, coords)
                    ESX.ShowNotification('Igrac ' .. player.name .. ' je teleportovan do tebe!')
                end
            })
        end

        -- table.insert(options, {
        --     title = 'Nazad',
        --     description = 'Vrati se na admin panel',
        --     icon = 'arrow-left',
        --     menu = 'admin_panel'
        -- })
        
        lib.registerContext({
            id = 'bring_player_list',
            title = 'Bring Player',
            menu = 'admin_panel',
            options = options
        })
        
        lib.showContext('bring_player_list')
    end)
end

RegisterNetEvent('admin:spawnVehicleForPlayer')
AddEventHandler('admin:spawnVehicleForPlayer', function(vehicleModel, spawnInVehicle)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    
    local modelHash = GetHashKey(vehicleModel)

    if not HasPermission(Config.Permissions.giveVehicle) then
        return lib.notify({
            title = 'Admin Sistem',
            description = 'Nemas dozvolu za ovu opciju.',
            type = 'error',
            duration = 3000
        })
    end
    
    if not IsModelInCdimage(modelHash) or not IsModelAVehicle(modelHash) then
        ESX.ShowNotification('Model vozila ne postoji!')
        return
    end
    
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(10)
    end
    
    local found, spawnCoords, spawnHeading = GetClosestVehicleNodeWithHeading(coords.x, coords.y, coords.z, 1, 3.0, 0)
    
    if not found then
        spawnCoords = coords
        spawnHeading = heading
    end
    
    local vehicle = CreateVehicle(modelHash, spawnCoords.x, spawnCoords.y, spawnCoords.z + 1.0, spawnHeading, true, false)
    
    --SetVehicleNumberPlateText(vehicle, "ADMIN")
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleOnGroundProperly(vehicle)
    
    if spawnInVehicle then
        SetPedIntoVehicle(playerPed, vehicle, -1)
    end
    
    ESX.ShowNotification(('Admin vam je dao vozilo %s'):format(vehicleModel))
    
    SetModelAsNoLongerNeeded(modelHash)
    
    if GetResourceState('esx_vehicleshop') == 'started' then
        TriggerServerEvent('esx_vehicleshop:setVehicleOwned', vehicleModel, GetVehicleNumberPlateText(vehicle))
    end
end)

function openPlayerDetails(playerId, playerName)
    ESX.TriggerServerCallback('admin:getPlayerDetails', function(playerData)
        if not playerData then
            lib.notify({
                description = 'Igrac nije pronadjen!',
                type = 'error'
            })
            return
        end
        
        local options = {
            {
                title = 'Steam Ime',
                description = playerData.name,
                --disabled = true
            },
            {
                title = 'ID',
                description = '' .. playerData.id,
                --disabled = true
            },
            {
                title = 'Admin Grupa',
                description = playerData.group or 'N/A',
                --disabled = true
            },
            {
                title = 'Posao',
                description = playerData.job,
                --disabled = true
            },
            {
                title = 'Cash',
                description = '$' .. playerData.cash,
                --disabled = true
            },
            {
                title = 'Banka',
                description = '$' .. playerData.bank,
                --disabled = true
            },
            {
                title = 'Prljav Novac',
                description = '$' .. playerData.black_money,
                --disabled = true
            }
        }
        
        -- Dodaj nazad
        -- table.insert(options, {
        --     title = 'Nazad',
        --     description = 'Vrati se na listu igraca',
        --     icon = 'arrow-left',
        --     onSelect = function()
        --         openPlayersList()
        --     end
        -- })
        
        lib.registerContext({
            id = 'player_details',
            title = playerName,
            menu = 'players_list',
            options = options
        })
        
        lib.showContext('player_details')
    end, playerId)
end

RegisterNetEvent('lmodciz_admin:nemasDozvolu')
AddEventHandler('lmodciz_admin:nemasDozvolu', function()
    lib.hideContext()
    lib.notify({
        description = 'Nemaz dozvolu za admin meni!',
        type = 'error'
    })
end)

RegisterNetEvent('admin:doTeleport')
AddEventHandler('admin:doTeleport', function(coords)

    if not HasPermission(Config.Permissions.gotoplayer) then
        return lib.notify({
            title = 'Admin Sistem',
            description = 'Nemas dozvolu za ovu opciju.',
            type = 'error',
            duration = 3000
        })
    end

    local ped = PlayerPedId()

    local tempZ = 200.0
    SetEntityCoords(ped, coords.x, coords.y, tempZ, false, false, false, true)
    Wait(250)

    local foundGround, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, 1000.0, false)

    if foundGround then
        SetEntityCoords(ped, coords.x, coords.y, groundZ + 1.0, false, false, false, true)
    else
        SetEntityCoords(ped, coords.x, coords.y, 50.0, false, false, false, true)
    end
    -- local ped = PlayerPedId()
    
    -- FreezeEntityPosition(ped, true)
    
    -- local foundGround, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, 1000.0, false)
    
    -- if foundGround then
    --     SetEntityCoords(ped, coords.x, coords.y, groundZ + 1.0, false, false, false, false)
    -- else
    --     SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    -- end
    
    -- SetEntityVelocity(ped, 0.0, 0.0, 0.0)
    
    -- Wait(200)
    -- FreezeEntityPosition(ped, false)
    
    -- print('Teleport uspesan!')
end)

Citizen.CreateThread(function()
    Citizen.Wait(5000)
    ESX.TriggerServerCallback('admin:checkDuty', function(onDuty)
        isOnDuty = onDuty
    end)
end)

RegisterNetEvent('admin:doHeal')
AddEventHandler('admin:doHeal', function()
    local ped = PlayerPedId()
    local maxHealth = GetEntityMaxHealth(ped)
    local health = GetEntityHealth(ped)
    local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 8))

    if not HasPermission(Config.Permissions.heal) then
        return lib.notify({
    title = 'Admin Sistem',
    description = 'Nemas dozvolu za ovu opciju.',
    type = 'error',
    duration = 3000
})
    end

    ClearPedBloodDamage(ped)
    ResetPedVisibleDamage(ped)
    ClearPedLastWeaponDamage(ped)

    TriggerEvent('esx_basicneeds:healPlayer', source)
    
    ESX.ShowNotification('Admin vas je izlecio!')
    
    print('Heal uspesan!')
end)

RegisterNetEvent('admin:notifikacijausaoduznost')
AddEventHandler('admin:notifikacijausaoduznost', function()
    --exports['lmod-notify']:sendnotify("Sada si na admin duznosti!", 1, 3000)
    lib.notify({
        title = 'Admin Sistem',
        description = 'Sada si na admin duznosti!',
        type = 'info',
        duration = 3000
    })
end)

RegisterNetEvent('admin:notifikacijaizasaoduznost')
AddEventHandler('admin:notifikacijaizasaoduznost', function()
    --exports['lmod-notify']:sendnotify("Izasao si sa admin duznosti!", 2, 3000)
    lib.notify({
        title = 'Admin Sistem',
        description = 'Izasao si sa admin duznosti!',
        type = 'error',
        duration = 3000
    })
end)

RegisterNetEvent('admin:doRevive')
AddEventHandler('admin:doRevive', function()
    local ped = PlayerPedId()
    local maxHealth = GetEntityMaxHealth(ped)
    local health = GetEntityHealth(ped)
    local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 8))

    if not HasPermission(Config.Permissions.revive) then
        return lib.notify({
    title = 'Admin Sistem',
    description = 'Nemas dozvolu za ovu opciju.',
    type = 'error',
    duration = 3000
})
    end
    
    if IsPedDeadOrDying(ped) then
        local coords = GetEntityCoords(ped)
        
        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
        
        SetEntityHealth(ped, maxHealth)
        
        ClearPedBloodDamage(ped)
        ResetPedVisibleDamage(ped)
        ClearPedLastWeaponDamage(ped)
        
        local playerServerId = GetPlayerServerId(PlayerId())
        TriggerServerEvent('admin:revivePlayer', playerServerId)
        
        ESX.ShowNotification('Admin vas je ozivio!')
        
        print('Revive uspesan!')
    else
        ESX.ShowNotification('Niste mrtvi!')
    end
end)

-- function startNoclip()
--     noclipActive = true
--     entity = PlayerPedId()
    
--     SetEntityCollision(entity, false, false)

--     FreezeEntityPosition(entity, true)
    
--     updateNoclipUI()
    
--     Citizen.CreateThread(function()
--         local currentSpeed = speedLevels[speedIndex]
        
--         while noclipActive do
--             Citizen.Wait(0)
            
--             local heading = GetEntityHeading(entity)
--             local radians = math.rad(heading)
            
--             local x, y, z = 0.0, 0.0, 0.0
            
--             if IsControlPressed(0, 32) then -- W
--                 x = -currentSpeed * math.sin(radians)
--                 y = currentSpeed * math.cos(radians)
--             end
 
--             if IsControlPressed(0, 33) then -- S
--                 x = currentSpeed * math.sin(radians)
--                 y = -currentSpeed * math.cos(radians)
--             end

--             if IsControlPressed(0, 34) then -- A
--                 local leftAngle = heading + 90
--                 local leftRadians = math.rad(leftAngle)
--                 x = -currentSpeed * math.sin(leftRadians)
--                 y = currentSpeed * math.cos(leftRadians)
--             end

--             if IsControlPressed(0, 35) then -- D
--                 local rightAngle = heading - 90
--                 local rightRadians = math.rad(rightAngle)
--                 x = -currentSpeed * math.sin(rightRadians)
--                 y = currentSpeed * math.cos(rightRadians)
--             end
            
--             if IsControlJustPressed(0, 21) then -- LSHIFT
--                 speedIndex = speedIndex + 1
--                 if speedIndex > #speedLevels then
--                     speedIndex = 1
--                 end
--                 currentSpeed = speedLevels[speedIndex]
--                 updateNoclipUI()
--             end
            
--             if IsControlPressed(0, 44) then -- Q
--                 z = currentSpeed
--             end
--             if IsControlPressed(0, 38) then -- E
--                 z = -currentSpeed
--             end
  
--             if IsControlPressed(0, 63) then -- DESNA STRILICA
--                 heading = heading + 2.0
--                 SetEntityHeading(entity, heading)
--             end
--             if IsControlPressed(0, 64) then -- LEVA STRILICA
--                 heading = heading - 2.0
--                 SetEntityHeading(entity, heading)
--             end
            
--             if x ~= 0.0 or y ~= 0.0 or z ~= 0.0 then
--                 local coords = GetEntityCoords(entity)
--                 local newX = coords.x + x
--                 local newY = coords.y + y
--                 local newZ = coords.z + z
                
--                 SetEntityCoordsNoOffset(entity, newX, newY, newZ, true, true, true)
--             end
            
--             if IsPedRagdoll(entity) then
--                 SetPedCanRagdoll(entity, false)
--             end
--         end
        
--         SetEntityCollision(entity, true, true)
--         SetPedCanRagdoll(entity, true)
--         FreezeEntityPosition(entity, false)
        
--         exports["pa-textui-2"]:hideTextUI()
--     end)
-- end

-- function stopNoclip()
--     noclipActive = false
--     speedIndex = 1
    
--     exports["pa-textui-2"]:hideTextUI()
    
--     ESX.ShowNotification('Noclip iskljucen')
-- end

-- function updateNoclipUI()
--     local speedText = ''
--     local speedColor = ''
    
--     if speedIndex == 1 then
--         speedText = 'SPORO'
--         speedColor = 'green'
--     elseif speedIndex == 2 then
--         speedText = 'BRZO'
--         speedColor = 'yellow'
--     elseif speedIndex == 3 then
--         speedText = 'PREBRZO'
--         speedColor = 'red'
--     end
    
--     exports["pa-textui-2"]:displayTextUI(
--         ('%s (%.1f)'):format(speedText, speedLevels[speedIndex]),
--         'LSHIFT'
--     )
-- end

-- function toggleNoclip()    
--     if not noclipActive then
--         startNoclip()
--         ESX.ShowNotification('Noclip ukljucen')
--     else
--         stopNoclip()
--     end
-- end

-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(0)
        
--         if noclipActive then
--             EnableControlAction(0, 44, true) -- Q
--             EnableControlAction(0, 38, true) -- E
            
--             if IsControlJustPressed(0, 166) then -- F5
--                 stopNoclip()
--             end
            
--             if IsControlJustPressed(0, 22) then -- SPACE
--                 local ped = PlayerPedId()
--                 local coords = GetEntityCoords(ped)
--                 local foundGround, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, 1000.0, false)
                
--                 if foundGround then
--                     SetEntityCoords(ped, coords.x, coords.y, groundZ + 1.0)
--                     ESX.ShowNotification('Resetovana visina na zemlju!')
--                 end
--             end
--         else
--             DisableControlAction(0, 44, true) -- Q
--             DisableControlAction(0, 38, true) -- E
--         end
--     end
-- end)

function openGiveItemPlayerList()
    ESX.TriggerServerCallback('admin:getOnlinePlayers', function(players)
        local options = {}
        
        table.insert(options, {
            title = 'Izaberi igraca za give item',
            description = 'Daj item igracu',
            disabled = true
        })
        
        for _, player in ipairs(players) do
            table.insert(options, {
                title = player.name,
                description = 'ID: ' .. player.id,
                icon = 'user',
                onSelect = function()
                    openGiveItemMenu(player.id, player.name)
                end
            })
        end

        -- table.insert(options, {
        --     title = 'Nazad',
        --     description = 'Vrati se na admin panel',
        --     icon = 'arrow-left',
        --     menu = 'admin_panel'
        -- })
        
        lib.registerContext({
            id = 'give_item_player_list',
            title = 'Give Item',
            menu = 'admin_panel',
            options = options
        })
        
        lib.showContext('give_item_player_list')
    end)
end

function openGiveVehiclePlayerList()
    ESX.TriggerServerCallback('admin:getOnlinePlayers', function(players)
        local options = {}
        
        table.insert(options, {
            title = 'Izaberi igraca za give vehicle',
            description = 'Daj vozilo igracu',
            disabled = true
        })
        
        for _, player in ipairs(players) do
            table.insert(options, {
                title = player.name,
                description = 'ID: ' .. player.id,
                icon = 'user',
                onSelect = function()
                    openGiveVehicleMenu(player.id, player.name)
                end
            })
        end

        -- table.insert(options, {
        --     title = 'Nazad',
        --     description = 'Vrati se na admin panel',
        --     icon = 'arrow-left',
        --     menu = 'admin_panel'
        -- })
        
        lib.registerContext({
            id = 'give_vehicle_player_list',
            title = 'Give Vehicle',
            menu = 'admin_panel',
            options = options
        })
        
        lib.showContext('give_vehicle_player_list')
    end)
end

function openGiveVehicleMenu(playerId, playerName)
    local inputVehicle = lib.inputDialog('Give Vehicle - ' .. playerName, {
        {type = 'input', label = 'Model Vozila', placeholder = 'npr. adder, kuruma, sultan...', required = true},
        {type = 'checkbox', label = 'Spawnaj u vozilu?', checked = true}
    })
    
    if not inputVehicle then return end
    
    local vehicleModel = tostring(inputVehicle[1]):lower()
    local spawnInVehicle = inputVehicle[2]
    
    if vehicleModel then
        local confirm = lib.alertDialog({
            header = 'Potvrda Give Vehicle',
            content = ('Da li zelite da date vozilo %s igracu %s?'):format(vehicleModel, playerName),
            centered = true,
            cancel = true,
            labels = {
                confirm = 'DA',
                cancel = 'NE'
            }
        })
        
        if confirm == 'confirm' then
            TriggerServerEvent('admin:giveVehicleToPlayer', playerId, vehicleModel, spawnInVehicle)
            ESX.ShowNotification(('Poslao si vozilo %s igracu %s'):format(vehicleModel, playerName))
        end
    else
        ESX.ShowNotification('Neispravan unos!')
    end
end

function openGiveItemMenu(playerId, playerName)
    local inputItem = lib.inputDialog('Give Item - ' .. playerName, {
        {type = 'input', label = 'Ime Item-a', placeholder = 'npr. bread, water, phone...', required = true},
        {type = 'number', label = 'Kolicina', placeholder = '1', min = 1, max = 999999, required = true, default = 1}
    })
    
    if not inputItem then return end
    
    local itemName = tostring(inputItem[1])
    local itemCount = tonumber(inputItem[2])
    
    if itemName and itemCount then

        local confirm = lib.alertDialog({
            header = 'Potvrda Give Item',
            content = ('Da li zelite da date %s x%d igracu %s?'):format(itemName, itemCount, playerName),
            centered = true,
            cancel = true,
            labels = {
                confirm = 'DA',
                cancel = 'NE'
            }
        })
        
        if confirm == 'confirm' then
            TriggerServerEvent('admin:giveItemToPlayer', playerId, itemName, itemCount)
            ESX.ShowNotification(('Dao si %s x%d igracu %s'):format(itemName, itemCount, playerName))
        end
    else
        ESX.ShowNotification('Neispravan unos!')
    end
end

RegisterCommand(Config.Reports.Command.Name, function()

    local cmd = Config.Reports.Command

    local input = lib.inputDialog(cmd.Dialog.Title, {
        {
            type = 'input',
            label = cmd.Fields.Title.label,
            placeholder = cmd.Fields.Title.placeholder,
            required = cmd.Fields.Title.required
        },
        {
            type = 'select',
            label = cmd.Fields.Category.label,
            options = cmd.Categories,
            required = cmd.Fields.Category.required
        },
        {
            type = 'input',
            label = cmd.Fields.Details.label,
            placeholder = cmd.Fields.Details.placeholder,
            required = cmd.Fields.Details.required
        }
    })

    if not input then
        lib.notify({
            title = 'Report',
            description = cmd.Notify.Cancel,
            type = 'error'
        })
        return
    end

    local title = input[1]
    local category = input[2]
    local details = input[3]

    TriggerServerEvent('reports:createReport', title, category, details)

end)