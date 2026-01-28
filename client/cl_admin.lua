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
        title = _('duty_menu'),
        menu = 'admin_panel',
        options = {
            {
                title = _('enter_duty'),
                description = _('start_admin_duty'),
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
        title = _('admin_menu'),
        menu = 'duty_menu',
        options = {
            {
                title = _('reports'),
                description = _('view_active_reports'),
                icon = 'clipboard-list',
                onSelect = function()
                    ESX.TriggerServerCallback('reports:getAllReports', function(allReports)
                        local options = {}

                        for id, report in pairs(allReports) do
                            if report.status ~= 'deleted' then
                                local statusText = _('status_' .. report.status) or report.status
                                local takenText = report.takenByName
                                    and (_('report_taken_by') .. report.takenByName)
                                    or _('report_free')

                                local displayTitle = string.format('%s | ID: %d | %s: %s', 
                                    report.steamName, 
                                    report.playerId,
                                    _('report_title'),
                                    report.title
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
                            title = _('reports'),
                            menu = 'admin_panel',
                            options = options
                        })

                        lib.showContext('admin_reports')
                    end)
                end
            },
            {
                title = _('players'),
                description = _('player_list'),
                icon = 'users',
                onSelect = function()
                    openPlayersList()
                end
            },
            {
                title = _('toggle_ids'),
                description = _('toggle_ids_desc'),
                icon = 'id-badge',
                onSelect = function()
                    openPlayerID()
                end
            },
            {
                title = _('teleport_waypoint'),
                description = _('teleport_waypoint_desc'),
                icon = 'location-dot',
                onSelect = function()
                    if not HasPermission(Config.Permissions.teleportwaypoint) then
                        return lib.notify({
                            title = _('admin_system'),
                            description = _('no_permission'),
                            type = 'error',
                            duration = 3000
                        })
                    end
                    local waypoint = GetFirstBlipInfoId(8)
                    local ped = PlayerPedId()

                    if not DoesBlipExist(waypoint) then
                        return lib.notify({
                            title = _('admin_system'),
                            description = _('no_waypoint'),
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

                    ESX.ShowNotification(_('teleported_to_waypoint'))
                end
            },
            {
                title = _('bring_player'),
                description = _('bring_player_desc'),
                icon = 'user-plus',
                onSelect = function()
                    if not HasPermission(Config.Permissions.bringplayer) then
                        return lib.notify({
                            title = _('admin_system'),
                            description = _('no_permission'),
                            type = 'error',
                            duration = 3000
                        })
                    end
                    openBringPlayerList()
                end
            },
            {
                title = _('goto_player'),
                description = _('goto_player_desc'),
                icon = 'user-check',
                onSelect = function()
                    if not HasPermission(Config.Permissions.gotoplayer) then
                        return lib.notify({
                            title = _('admin_system'),
                            description = _('no_permission'),
                            type = 'error',
                            duration = 3000
                        })
                    end
                    openTeleportToPlayerList()
                end
            },
            {
                title = _('noclip'),
                description = _('noclip_desc'),
                icon = 'plane',
                onSelect = function()
                    if not HasPermission(Config.Permissions.noclip) then
                        return lib.notify({
                            title = _('admin_system'),
                            description = _('no_permission'),
                            type = 'error',
                            duration = 3000
                        })
                    end
                    TriggerEvent('lazicAdmin:noclip')
                end
            },
            {
                title = _('invisible'),
                description = _('invisible_desc'),
                icon = 'ghost',
                onSelect = function()
                    if not HasPermission(Config.Permissions.invisible) then
                        return lib.notify({
                            title = _('admin_system'),
                            description = _('no_permission'),
                            type = 'error',
                            duration = 3000
                        })
                    end
                    invisiblecommand()
                end
            },
            {
                title = _('give_vehicle'),
                description = _('give_vehicle_desc'),
                icon = 'car',
                onSelect = function()
                    if not HasPermission(Config.Permissions.giveVehicle) then
                        return lib.notify({
                            title = _('admin_system'),
                            description = _('no_permission'),
                            type = 'error',
                            duration = 3000
                        })
                    end
                    openGiveVehiclePlayerList()
                end
            },
            {
                title = _('revive_player'),
                description = _('revive_player_desc'),
                icon = 'syringe',
                onSelect = function()
                    if not HasPermission(Config.Permissions.revive) then
                        return lib.notify({
                            title = _('admin_system'),
                            description = _('no_permission'),
                            type = 'error',
                            duration = 3000
                        })
                    end
                    openRevivePlayerList()
                end
            },
            {
                title = _('heal_player'),
                description = _('heal_player_desc'),
                icon = 'heart',
                onSelect = function()
                    if not HasPermission(Config.Permissions.heal) then
                        return lib.notify({
                            title = _('admin_system'),
                            description = _('no_permission'),
                            type = 'error',
                            duration = 3000
                        })
                    end
                    openHealPlayerList()
                end
            },
            {
                title = _('give_markers'),
                description = _('give_markers_desc'),
                icon = 'broom',
                onSelect = function()
                    if not HasPermission(Config.Permissions.markeri) then
                        return lib.notify({
                            title = _('admin_system'),
                            description = _('no_permission'),
                            type = 'error',
                            duration = 3000
                        })
                    end
                    staviigracanamarkere()
                end
            },
            {
                title = _('set_job'),
                description = _('set_job_desc'),
                icon = 'briefcase',
                onSelect = function()
                    if not HasPermission(Config.Permissions.setJob) then
                        return lib.notify({
                            title = _('admin_system'),
                            description = _('no_permission'),
                            type = 'error',
                            duration = 3000
                        })
                    end
                    openSetJobPlayerList()
                end
            },
            {
                title = _('set_group'),
                description = _('set_group_desc'),
                icon = 'users',
                onSelect = function()
                    if not HasPermission(Config.Permissions.setGroup) then
                        return lib.notify({
                            title = _('admin_system'),
                            description = _('no_permission'),
                            type = 'error',
                            duration = 3000
                        })
                    end
                    openSetGroupPlayerList()
                end
            },
            {
                title = _('give_item'),
                description = _('give_item_desc'),
                icon = 'gift',
                onSelect = function()
                    if not HasPermission(Config.Permissions.giveItem) then
                        return lib.notify({
                            title = _('admin_system'),
                            description = _('no_permission'),
                            type = 'error',
                            duration = 3000
                        })
                    end
                    openGiveItemPlayerList()
                end
            },
            {
                title = _('fix_vehicle'),
                description = _('fix_vehicle_desc'),
                icon = 'wrench',
                onSelect = function()
                    if not HasPermission(Config.Permissions.fixVehicle) then
                        return lib.notify({
                            title = _('admin_system'),
                            description = _('no_permission'),
                            type = 'error',
                            duration = 3000
                        })
                    end
                    popravijebenovozilo()
                end
            },
            {
                title = _('delete_vehicle'),
                description = _('delete_vehicle_desc'),
                icon = 'xmark',
                onSelect = function()
                    obrisijebenovozilo()
                end
            },
            {
                title = _('leave_duty'),
                description = _('end_admin_duty'),
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
    local reportTime = report.createdAt or _('unknown')
    local myServerId = GetPlayerServerId(PlayerId())
    local isTakenByMe = report.takenBy == myServerId
    local isLocked = report.takenBy ~= nil and not isTakenByMe
    
    if type(report.createdAt) == "number" then
        local hours = math.floor((report.createdAt % 86400) / 3600)
        local minutes = math.floor((report.createdAt % 3600) / 60)
        local seconds = math.floor(report.createdAt % 60)
        reportTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    end

    local statusText = _('status_' .. report.status) or report.status
    local categoryText = _('category_' .. report.category) or report.category
    local takenStatus = report.takenBy and _('status_taken') or _('status_active')
    local takenByText = report.takenByName
        and (_('report_taken_by') .. report.takenByName)
        or _('report_free')

    lib.registerContext({
        id = 'report_actions_'..reportId,
        title = "#" .. reportId .. " - " .. (report.title or _('report_title')),
        menu = 'admin_reports',
        options = {
            {
                title = _('report_category') .. ": " .. categoryText,
                description = _('status') .. ": " .. takenStatus,
                icon = 'clock',
                readOnly = true
            },
            {
                title = _('view_details'),
                description = report.details or _('no_details'),
                icon = 'file-lines',
                readOnly = true
            },
            {
                title = _('goto_player'),
                description = _('teleport_to_player') .. " " .. (report.steamName or _('player')),
                icon = 'location-dot',
                disabled = not isOnDuty or (Config.Reports.Lock.Enable and Config.Reports.Lock.OnlyTakerCanDelete and isLocked),
                onSelect = function()
                    TriggerServerEvent('admin:teleportToPlayer', report.playerId)
                    lib.notify({
                        title = _('admin_system'),
                        description = _('teleported_to', report.steamName or _('player')),
                        type = 'success',
                        duration = 3000
                    })
                end
            },
            {
                title = _('bring_player'),
                description = _('teleport_player_to_you') .. " " .. (report.steamName or _('player')),
                icon = 'user-plus',
                disabled = not isOnDuty or (Config.Reports.Lock.Enable and Config.Reports.Lock.OnlyTakerCanDelete and isLocked),
                onSelect = function()
                    local ped = PlayerPedId()
                    local coords = GetEntityCoords(ped)
                    TriggerServerEvent('admin:teleportPlayerToMe', report.playerId, coords)
                    lib.notify({
                        title = _('admin_system'),
                        description = _('brought_to_you', report.steamName or _('player')),
                        type = 'success',
                        duration = 3000
                    })
                end
            },
            {
                title = _('send_message'),
                description = _('send_message_to', report.steamName or _('player')),
                icon = 'message',
                disabled = not isOnDuty or (Config.Reports.Lock.Enable and Config.Reports.Lock.OnlyTakerCanDelete and isLocked),
                onSelect = function()
                    local input = lib.inputDialog(
                        _('send_message_to', report.steamName or _('player')),
                        {
                            {
                                type = 'textarea',
                                label = _('message'),
                                placeholder = _('message_placeholder'),
                                required = true,
                                rows = 4
                            }
                        }
                    )

                    if not input then return end

                    TriggerServerEvent('admin:sendMessageToPlayer', report.playerId, input[1])

                    lib.notify({
                        title = _('admin_system'),
                        description = _('message_sent', report.steamName or _('player')),
                        type = 'success'
                    })
                end
            },
            {
                title = report.takenBy and _('release_report') or _('take_report'),
                description = report.takenBy and takenByText or _('take_report_desc'),
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
                title = _('delete_report'),
                description = _('delete_report_confirm'),
                icon = 'trash',
                onSelect = function()
                    local confirm = lib.alertDialog({
                        header = _('delete_report'),
                        content = _('delete_report_confirm'),
                        centered = true,
                        cancel = true,
                        labels = {
                            confirm = _('confirm'),
                            cancel = _('cancel')
                        }
                    })

                    if confirm then
                        TriggerServerEvent('reports:updateReport', reportId, 'delete')
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
            title = _('admin_system'),
            description = _('now_invisible'),
            type = 'success',
            duration = 3000
        })
    else
        ResetEntityAlpha(ped)
        lib.notify({
            title = _('admin_system'),
            description = _('now_visible'),
            type = 'info',
            duration = 3000
        })
    end
end

function popravijebenovozilo()
    local playerPed = PlayerPedId()

    if not IsPedInAnyVehicle(playerPed, false) then
        lib.notify({
            title = _('admin_system'),
            description = _('must_be_in_vehicle'),
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
        title = _('admin_system'),
        description = _('vehicle_fixed'),
        type = 'success',
        duration = 3000
    })
end

function staviigracanamarkere()
    lib.hideContext()
    ExecuteCommand(Config.CommunityService.Command)
end

function openPlayerID()
    ExecuteCommand('id')
end

function openPlayersList()
    ESX.TriggerServerCallback('admin:getOnlinePlayers', function(players)
        local options = {}
        
        table.insert(options, {
            title = _('online_players') .. ': ' .. #players,
            description = _('currently_on_server'),
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
        
        lib.registerContext({
            id = 'players_list',
            title = _('players'),
            menu = 'admin_panel',
            options = options
        })
        
        lib.showContext('players_list')
    end)
end

-- Continue in next artifact due to length...
-- Continuation of cl_admin.lua with localization

function openSetGroupPlayerList()
    ESX.TriggerServerCallback('admin:getOnlinePlayers', function(players)   
        local options = {}
        
        table.insert(options, {
            title = _('select_player_group'),
            description = _('change_player_group'),
            disabled = true
        })
        
        for _, player in ipairs(players) do
            ESX.TriggerServerCallback('admin:getPlayerCurrentGroup', function(currentGroup)
                local groupLabel = getGroupLabel(currentGroup) or _('unknown')
                
                table.insert(options, {
                    title = player.name,
                    description = 'ID: ' .. player.id .. ' | ' .. _('current_group') .. ': ' .. groupLabel,
                    icon = 'user',
                    metadata = {
                        {label = _('current_group'), value = groupLabel}
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
            title = _('set_group'),
            menu = 'admin_panel',
            options = options
        })
        
        lib.showContext('setgroup_player_list')
    end)
end

function getGroupLabel(group)
    return _('group_' .. group) or group
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

function openGroupSelectionMenu(playerId, playerName, currentGroup)
    ESX.TriggerServerCallback('admin:getMyGroup', function(myGroup)
        local options = {}

        table.insert(options, {
            title = _('select_group_for') .. playerName,
            description = 'ID: ' .. playerId,
            disabled = true
        })

        for _, group in ipairs(Config.Groups.order) do
            local canSet = canSetGroup(myGroup, group)
            local reason = ""

            if playerId == GetPlayerServerId(PlayerId()) and group == myGroup then
                canSet = false
                reason = _('cannot_set_yourself')
            end

            if getGroupIndex(group) > getGroupIndex(myGroup) then
                canSet = false
                reason = _('cannot_set_higher')
            end

            if group == myGroup then
                canSet = false
                reason = _('cannot_set_same')
            end

            table.insert(options, {
                title = getGroupLabel(group),
                description = canSet
                    and _('set_as', playerName, getGroupLabel(group))
                    or reason,
                icon = group == currentGroup and 'circle-check' or 'user-group',
                disabled = not canSet,
                metadata = {
                    {
                        label = _('status'),
                        value = group == currentGroup and _('current_group_status')
                            or (canSet and _('available') or _('blocked'))
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
            title = _('reset_to_user'),
            description = _('reset_to_user_desc'),
            icon = 'user-slash',
            metadata = {
                { label = _('warning'), value = _('reset_warning') }
            },
            onSelect = function()
                resetToUser(playerId, playerName)
            end
        })

        lib.registerContext({
            id = 'group_selection_menu',
            title = _('set_group') .. ' - ' .. playerName,
            menu = 'setgroup_player_list',
            options = options
        })

        lib.showContext('group_selection_menu')
    end)
end

function setPlayerGroup(playerId, playerName, group)
    local input = lib.inputDialog(_('confirm_group_change') .. playerName, {
        {type = 'input', label = _('reason_required'), placeholder = _('reason_placeholder'), required = true}
    })
    
    if not input then return end
    
    local reason = input[1]
    
    ESX.TriggerServerCallback('admin:setPlayerGroup', function(success, message)
        if success then
            lib.notify({
                title = _('admin_system'),
                description = _('group_changed', playerName),
                type = 'success',
                duration = 3000
            })
            openSetGroupPlayerList()
        else
            lib.notify({
                title = _('admin_system'),
                description = message or _('group_change_error'),
                type = 'error',
                duration = 3000
            })
        end
    end, playerId, group, reason)
end

function resetToUser(playerId, playerName)
    local input = lib.inputDialog(_('confirm_group_reset') .. playerName, {
        {type = 'input', label = _('reason_required'), placeholder = _('reason_reset_placeholder'), required = true}
    })
    
    if not input then return end
    
    local reason = input[1]
    
    ESX.TriggerServerCallback('admin:setPlayerGroup', function(success, message)
        if success then
            lib.notify({
                title = _('admin_system'),
                description = _('group_reset_success', playerName),
                type = 'success',
                duration = 3000
            })
            openSetGroupPlayerList()
        else
            lib.notify({
                title = _('admin_system'),
                description = message or _('reset_error'),
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
            title = _('select_goto_player'),
            description = _('teleport_to_player'),
            disabled = true
        })
        
        for _, player in ipairs(players) do
            table.insert(options, {
                title = player.name,
                description = 'ID: ' .. player.id,
                icon = 'location-dot',
                onSelect = function()
                    TriggerServerEvent('admin:teleportToPlayer', player.id, grupa)
                    ESX.ShowNotification(_('teleported_to_player', player.name))
                end
            })
        end
        
        lib.registerContext({
            id = 'teleport_to_player_list',
            title = _('goto_player'),
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
            title = _('select_player_job'),
            description = _('change_player_job'),
            disabled = true
        })

        if total == 0 then
            return
        end

        for _, player in ipairs(players) do
            ESX.TriggerServerCallback('admin:getPlayerCurrentJob', function(currentJob)
                loaded = loaded + 1

                local jobLabel = currentJob and currentJob.label or _('unknown')
                local gradeLabel = currentJob and currentJob.grade_label or _('unknown')

                table.insert(options, {
                    title = player.name,
                    description = 'ID: ' .. player.id .. ' | ' .. jobLabel .. ' - ' .. gradeLabel,
                    icon = 'user',
                    metadata = {
                        {label = _('metadata_current_job'), value = jobLabel},
                        {label = _('rank'), value = gradeLabel}
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
                        title = _('set_job'),
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
            ESX.ShowNotification(_('error_loading_jobs'))
            return
        end
        
        local options = {}
        
        table.insert(options, {
            title = _('select_job_for') .. playerName,
            description = _('current_job_display') .. (currentJob.label or _('unknown')) .. ' - ' .. (currentJob.grade_label or _('unknown')),
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
                description = _('select_job') .. ': ' .. job.label,
                icon = 'briefcase',
                arrow = true,
                onSelect = function()
                    openGradeSelectionMenu(playerId, playerName, job.name, job, currentJob)
                end
            })
        end
        
        lib.registerContext({
            id = 'job_selection_menu',
            title = _('select_job'),
            menu = 'setjob_player_list',
            options = options
        })
        
        lib.showContext('job_selection_menu')
    end)
end

function openGradeSelectionMenu(playerId, playerName, jobName, jobData, currentJob)
    local options = {}
    
    table.insert(options, {
        title = _('select_rank_for') .. playerName,
        description = _('job') .. ': ' .. jobData.label,
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
            description = _('salary') .. (gradeData.salary or 0),
            icon = 'user-tie',
            metadata = {
                {label = _('grade'), value = gradeNum},
                {label = _('salary'), value = '$' .. (gradeData.salary or 0)}
            },
            onSelect = function()
                showJobChangeConfirmation(playerId, playerName, jobName, gradeNum, jobData.label, gradeData.label, gradeData.salary)
            end
        })
    end
    
    lib.registerContext({
        id = 'grade_selection_menu',
        title = _('select_rank'),
        menu = 'job_selection_menu',
        options = options
    })
    
    lib.showContext('grade_selection_menu')
end

function showJobChangeConfirmation(playerId, playerName, jobName, gradeNum, jobLabel, gradeLabel, salary)
    lib.registerContext({
        id = 'confirm_job_change',
        title = _('job_confirmation'),
        menu = 'grade_selection_menu',
        options = {
            {
                title = _('confirm_job_change'),
                description = playerName,
                disabled = true
            },
            {
                title = _('new_job'),
                description = jobLabel .. ' - ' .. gradeLabel,
                disabled = true
            },
            {
                title = _('salary') .. (salary or 0),
                description = _('rank') .. ': ' .. gradeNum,
                disabled = true
            },
            {
                title = _('confirm'),
                description = _('change_player_job'),
                icon = 'check',
                onSelect = function()
                    TriggerServerEvent('admin:setPlayerJob', playerId, jobName, gradeNum)
                    ESX.ShowNotification(_('job_changed', playerName, jobLabel, gradeLabel))
                    Citizen.Wait(300)
                    openSetJobPlayerList()
                end
            },
            {
                title = _('cancel'),
                description = _('back'),
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
            title = _('select_heal_player'),
            description = _('heal_selected_player'),
            disabled = true
        })
        
        for _, player in ipairs(players) do
            table.insert(options, {
                title = player.name,
                description = 'ID: ' .. player.id,
                icon = 'heart',
                onSelect = function()
                    TriggerServerEvent('admin:healPlayer', player.id, grupa)
                    ESX.ShowNotification(_('player_healed', player.name))
                end
            })
        end
        
        lib.registerContext({
            id = 'heal_player_list',
            title = _('heal_player'),
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
            title = _('select_revive_player'),
            description = _('revive_selected_player'),
            disabled = true
        })
        
        for _, player in ipairs(players) do
            table.insert(options, {
                title = player.name,
                description = 'ID: ' .. player.id,
                icon = 'syringe',
                onSelect = function()
                    TriggerServerEvent('admin:revivePlayer', player.id, grupa)
                    ESX.ShowNotification(_('player_revived', player.name))
                end
            })
        end
        
        lib.registerContext({
            id = 'revive_player_list',
            title = _('revive_player'),
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
            title = _('select_bring_player'),
            description = _('teleport_player_to_you'),
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
                    ESX.ShowNotification(_('player_brought', player.name))
                end
            })
        end
        
        lib.registerContext({
            id = 'bring_player_list',
            title = _('bring_player'),
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
            title = _('admin_system'),
            description = _('no_permission'),
            type = 'error',
            duration = 3000
        })
    end
    
    if not IsModelInCdimage(modelHash) or not IsModelAVehicle(modelHash) then
        ESX.ShowNotification(_('vehicle_not_exist'))
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
    
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleOnGroundProperly(vehicle)
    
    if spawnInVehicle then
        SetPedIntoVehicle(playerPed, vehicle, -1)
    end
    
    ESX.ShowNotification(_('admin_gave_vehicle', vehicleModel))
    
    SetModelAsNoLongerNeeded(modelHash)
    
    if GetResourceState('esx_vehicleshop') == 'started' then
        TriggerServerEvent('esx_vehicleshop:setVehicleOwned', vehicleModel, GetVehicleNumberPlateText(vehicle))
    end
end)

function openPlayerDetails(playerId, playerName)
    ESX.TriggerServerCallback('admin:getPlayerDetails', function(playerData)
        if not playerData then
            lib.notify({
                description = _('player_not_found'),
                type = 'error'
            })
            return
        end
        
        local options = {
            {
                title = _('steam_name'),
                description = playerData.name,
            },
            {
                title = 'ID',
                description = '' .. playerData.id,
            },
            {
                title = _('admin_group'),
                description = playerData.group or 'N/A',
            },
            {
                title = _('job'),
                description = playerData.job,
            },
            {
                title = _('cash'),
                description = '$' .. playerData.cash,
            },
            {
                title = _('bank'),
                description = '$' .. playerData.bank,
            },
            {
                title = _('black_money'),
                description = '$' .. playerData.black_money,
            }
        }
        
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
        description = _('no_admin_permission'),
        type = 'error'
    })
end)

RegisterNetEvent('admin:doTeleport')
AddEventHandler('admin:doTeleport', function(coords)
    if not HasPermission(Config.Permissions.gotoplayer) then
        return lib.notify({
            title = _('admin_system'),
            description = _('no_permission'),
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
            title = _('admin_system'),
            description = _('no_permission'),
            type = 'error',
            duration = 3000
        })
    end

    ClearPedBloodDamage(ped)
    ResetPedVisibleDamage(ped)
    ClearPedLastWeaponDamage(ped)
    TriggerEvent('esx_basicneeds:healPlayer', source)
    ESX.ShowNotification(_('admin_healed_you'))
end)

RegisterNetEvent('admin:notifikacijausaoduznost')
AddEventHandler('admin:notifikacijausaoduznost', function()
    lib.notify({
        title = _('admin_system'),
        description = _('now_on_duty'),
        type = 'info',
        duration = 3000
    })
end)

RegisterNetEvent('admin:notifikacijaizasaoduznost')
AddEventHandler('admin:notifikacijaizasaoduznost', function()
    lib.notify({
        title = _('admin_system'),
        description = _('left_duty'),
        type = 'error',
        duration = 3000
    })
end)

RegisterNetEvent('admin:doRevive')
AddEventHandler('admin:doRevive', function()
    local ped = PlayerPedId()
    local maxHealth = GetEntityMaxHealth(ped)

    if not HasPermission(Config.Permissions.revive) then
        return lib.notify({
            title = _('admin_system'),
            description = _('no_permission'),
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
        ESX.ShowNotification(_('admin_revived_you'))
    else
        ESX.ShowNotification(_('not_dead'))
    end
end)

function openGiveItemPlayerList()
    ESX.TriggerServerCallback('admin:getOnlinePlayers', function(players)
        local options = {}
        
        table.insert(options, {
            title = _('select_player_item'),
            description = _('give_item_to_player'),
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
        
        lib.registerContext({
            id = 'give_item_player_list',
            title = _('give_item'),
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
            title = _('select_player_vehicle'),
            description = _('give_vehicle_to_player'),
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
        
        lib.registerContext({
            id = 'give_vehicle_player_list',
            title = _('give_vehicle'),
            menu = 'admin_panel',
            options = options
        })
        
        lib.showContext('give_vehicle_player_list')
    end)
end

function openGiveVehicleMenu(playerId, playerName)
    local inputVehicle = lib.inputDialog(_('give_vehicle') .. ' - ' .. playerName, {
        {type = 'input', label = _('vehicle_model'), placeholder = _('vehicle_model_placeholder'), required = true},
        {type = 'checkbox', label = _('spawn_in_vehicle'), checked = true}
    })
    
    if not inputVehicle then return end
    
    local vehicleModel = tostring(inputVehicle[1]):lower()
    local spawnInVehicle = inputVehicle[2]
    
    if vehicleModel then
        local confirm = lib.alertDialog({
            header = _('confirm_give_vehicle'),
            content = _('confirm_give_vehicle_msg', vehicleModel, playerName),
            centered = true,
            cancel = true,
            labels = {
                confirm = _('yes'),
                cancel = _('no')
            }
        })
        
        if confirm == 'confirm' then
            TriggerServerEvent('admin:giveVehicleToPlayer', playerId, vehicleModel, spawnInVehicle)
            ESX.ShowNotification(_('sent_vehicle', vehicleModel, playerName))
        end
    else
        ESX.ShowNotification(_('invalid_input'))
    end
end

function openGiveItemMenu(playerId, playerName)
    local inputItem = lib.inputDialog(_('give_item') .. ' - ' .. playerName, {
        {type = 'input', label = _('item_name'), placeholder = _('item_name_placeholder'), required = true},
        {type = 'number', label = _('quantity'), placeholder = '1', min = 1, max = 999999, required = true, default = 1}
    })
    
    if not inputItem then return end
    
    local itemName = tostring(inputItem[1])
    local itemCount = tonumber(inputItem[2])
    
    if itemName and itemCount then
        local confirm = lib.alertDialog({
            header = _('confirm_give_item'),
            content = _('confirm_give_item_msg', itemName, itemCount, playerName),
            centered = true,
            cancel = true,
            labels = {
                confirm = _('yes'),
                cancel = _('no')
            }
        })
        
        if confirm == 'confirm' then
            TriggerServerEvent('admin:giveItemToPlayer', playerId, itemName, itemCount)
            ESX.ShowNotification(_('gave_item', itemName, itemCount, playerName))
        end
    else
        ESX.ShowNotification(_('invalid_input'))
    end
end

RegisterCommand(Config.Reports.Command, function()
    local cmd = Config.Reports.Command

    local input = lib.inputDialog(_('new_report'), {
        {
            type = 'input',
            label = _('report_title'),
            placeholder = _('short_title'),
            required = true
        },
        {
            type = 'select',
            label = _('report_category'),
            options = {
                {value = 'cheater', label = _('category_cheater')},
                {value = 'bug', label = _('category_bug')},
                {value = 'player', label = _('category_player')},
                {value = 'admin', label = _('category_admin')}
            },
            required = true
        },
        {
            type = 'input',
            label = _('report_details'),
            placeholder = _('explain_problem'),
            required = true
        }
    })

    if not input then
        lib.notify({
            title = _('report'),
            description = _('report_cancelled'),
            type = 'error'
        })
        return
    end

    local title = input[1]
    local category = input[2]
    local details = input[3]

    TriggerServerEvent('reports:createReport', title, category, details)
end)

