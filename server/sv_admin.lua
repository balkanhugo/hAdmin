ESX = exports["es_extended"]:getSharedObject()
AdminPlayers = {}

ESX.RegisterServerCallback('lazic:getAdminsPlayers',function(source,cb)
    cb(AdminPlayers)
end)

AddEventHandler('esx:playerDropped', function(source)
    if AdminPlayers[source] ~= nil then
        AdminPlayers[source] = nil
    end
    TriggerClientEvent('lazic:setaj_admine',-1,AdminPlayers)
end)

RegisterCommand('id', function(source)
    local admin = ESX.GetPlayerFromId(source)
    if not admin then return end
    
    local grupa = admin.getGroup()
    
    if IsAdmin(grupa) then
        if admin.proveriDuznost() == true then
            TriggerClientEvent('lazicAdmin:showIDs', source)
        else
            print('Player ' .. source .. ' is not on duty')
        end
    else
        print('Player ' .. source .. ' is not admin')
    end
end)

ESX.RegisterServerCallback('adminmenu:isAdmin', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb(false)
        return
    end

    local group = xPlayer.getGroup()
    cb(IsAdmin(group))
end)

RegisterNetEvent('adminmenu:checkPermission', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local group = xPlayer.getGroup()

    if IsAdmin(group) then
        TriggerClientEvent('adminmenu:open', src)
    else
        print('Player ' .. src .. ' is not admin')
    end
end)

local function SendAdminLog(type, title, description, color)
    local cfg = Config.AdminLogs[type]
    if not cfg or not cfg.enabled or not cfg.webhook or cfg.webhook == "" then return end
    if cfg.webhook:find("YOUR_WEBHOOK_HERE") then return end

    PerformHttpRequest(cfg.webhook, function() end, "POST", json.encode({
        username = "Admin Logs",
        embeds = {{
            title = title,
            description = description,
            color = color,
            footer = { text = os.date("%d.%m.%Y | %H:%M:%S") }
        }}
    }), { ["Content-Type"] = "application/json" })
end

ESX.RegisterServerCallback('admin:getPlayerCurrentGroup', function(source, cb, targetId)
    local xPlayer = ESX.GetPlayerFromId(targetId)
    if xPlayer then
        local group = xPlayer.getGroup() or Config.Groups.default
        cb(group)
    else
        cb(Config.Groups.default)
    end
end)

ESX.RegisterServerCallback('admin:getMyGroup', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local group = xPlayer.getGroup() or Config.Groups.default
        cb(group)
    else
        cb(Config.Groups.default)
    end
end)

ESX.RegisterServerCallback('admin:setPlayerGroup', function(source, cb, targetId, newGroup, reason)
    local admin = ESX.GetPlayerFromId(source)
    local target = ESX.GetPlayerFromId(targetId)
    
    if not admin or not target then
        cb(false, _('player_not_found'))
        return
    end

    local adminGroup = admin.getGroup() or Config.Groups.default
    local targetCurrentGroup = target.getGroup() or Config.Groups.default

    if adminGroup ~= 'owner' then
        local allowedGroups = Config.Groups.permissions[adminGroup] or {}
        local canSet = false
        for _, g in ipairs(allowedGroups) do
            if g == newGroup then
                canSet = true
                break
            end
        end

        if not canSet then
            cb(false, _('no_permission_group'))
            return
        end

        if IsGroupHigher(newGroup, adminGroup) or newGroup == adminGroup then
            cb(false, _('cannot_set_higher'))
            return
        end

        if source == targetId then
            cb(false, _('cannot_set_yourself'))
            return
        end
    end

    target.setGroup(newGroup)

    print(('^5[ADMIN] ^7%s (ID: %s) set group %s to player %s (ID: %s). Reason: %s^7'):format(
        admin.getName(), source, newGroup, target.getName(), targetId, reason
    ))

    SendAdminLog(
        "setgroup",
        "ADMIN SET GROUP",
        "**Admin:** "..admin.getName().." (ID "..source..")\n**Target:** "..target.getName().." (ID "..targetId..")\n**Old:** "..targetCurrentGroup.."\n**New:** "..newGroup.."\n**Reason:** "..reason,
        11184810
    )

    if targetId ~= source then
        TriggerClientEvent('ox_lib:notify', targetId, {
            title = _('set_group'),
            description = _('group_changed_notification') .. newGroup .. _('by_admin') .. admin.getName(),
            type = "inform",
            duration = 5000,
            position = "top-left"
        })
    end

    cb(true, _('group_changed', target.getName()))
end)

RegisterServerEvent('admin:giveVehicleToPlayer')
AddEventHandler('admin:giveVehicleToPlayer', function(targetId, vehicleModel, spawnInVehicle)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local targetPlayer = ESX.GetPlayerFromId(targetId)
    
    if not xPlayer or not targetPlayer then
        TriggerClientEvent('esx:showNotification', src, _('player_not_found'))
        return
    end

    local group = xPlayer.getGroup()
    
    if HasPermission(group, 'giveVehicle') then
        TriggerClientEvent('admin:spawnVehicleForPlayer', targetId, vehicleModel, spawnInVehicle)
        
        print(("[ADMIN] %s gave vehicle %s to player %s"):format(
            GetPlayerName(src),
            vehicleModel,
            GetPlayerName(targetId)
        ))

        SendAdminLog(
            "givevehicle",
            "ADMIN GIVE VEHICLE",
            "**Admin:** "..GetPlayerName(src).." (ID "..src..")\n**Target:** "..GetPlayerName(targetId).." (ID "..targetId..")\n**Vehicle:** "..vehicleModel,
            10181046
        )
        
        TriggerClientEvent('esx:showNotification', src, _('sent_vehicle', vehicleModel, GetPlayerName(targetId)))
    else
        TriggerClientEvent('esx:showNotification', src, _('no_permission'))
    end
end)

RegisterServerEvent('admin:giveCarToPlayer')
AddEventHandler('admin:giveCarToPlayer', function(targetId, vehicleModel, customPlate)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local targetPlayer = ESX.GetPlayerFromId(targetId)
    
    if not xPlayer or not targetPlayer then
        TriggerClientEvent('esx:showNotification', src, _('player_not_found'))
        return
    end

    local group = xPlayer.getGroup()
    
    if HasPermission(group, 'givecar') then
        -- Generate plate if not provided
        local plate = customPlate or GeneratePlate()
        
        -- Make sure plate is uppercase and max 8 characters
        plate = string.upper(plate):sub(1, 8)
        
        -- Insert vehicle into database
        MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, parking) VALUES (@owner, @plate, @vehicle, 1, "elgin")', {
            ['@owner'] = targetPlayer.identifier,
            ['@plate'] = plate,
            ['@vehicle'] = json.encode({
                model = GetHashKey(vehicleModel),
                plate = plate
            })
        }, function(rowsChanged)
            if rowsChanged > 0 then
                -- Notify both players
                TriggerClientEvent('esx:showNotification', src, _('sent_vehicle', vehicleModel, targetPlayer.getName()) .. ' (' .. plate .. ')')
                TriggerClientEvent('esx:showNotification', targetId, _('admin_gave_vehicle', vehicleModel) .. ' (' .. plate .. ')')
                
                -- Log the action
                print(('[GiveCar] %s gave %s a %s (Plate: %s)'):format(xPlayer.getName(), targetPlayer.getName(), vehicleModel, plate))
                
                SendAdminLog(
                    "givecar",
                    "ADMIN GIVE CAR (DB)",
                    "**Admin:** "..xPlayer.getName().." (ID "..src..")\n**Target:** "..targetPlayer.getName().." (ID "..targetId..")\n**Vehicle:** "..vehicleModel.."\n**Plate:** "..plate,
                    10181046
                )
            else
                TriggerClientEvent('esx:showNotification', src, _('error'))
            end
        end)
    else
        TriggerClientEvent('esx:showNotification', src, _('no_permission'))
    end
end)

RegisterServerEvent('admin:removeCarByPlate')
AddEventHandler('admin:removeCarByPlate', function(plate)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local group = xPlayer.getGroup()
    
    if HasPermission(group, 'removecar') then
        if not plate then
            TriggerClientEvent('esx:showNotification', src, _('invalid_input'))
            return
        end
        
        plate = string.upper(plate):gsub("%s+", "")
        
        -- Check if plate exists
        local result = MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM owned_vehicles WHERE plate = @plate', {
            ['@plate'] = plate
        })
        
        if result > 0 then
            MySQL.Async.execute('DELETE FROM owned_vehicles WHERE plate = @plate', {
                ['@plate'] = plate
            }, function(rowsChanged)
                if rowsChanged > 0 then
                    TriggerClientEvent('esx:showNotification', src, _('car_removed', plate))
                    print(('[RemoveCar] %s removed vehicle with plate %s'):format(xPlayer.getName(), plate))
                    
                    SendAdminLog(
                        "removecar",
                        "ADMIN REMOVE CAR (DB)",
                        "**Admin:** "..xPlayer.getName().." (ID "..src..")\n**Vehicle Plate:** "..plate,
                        15158332
                    )
                else
                    TriggerClientEvent('esx:showNotification', src, _('error'))
                end
            end)
        else
            TriggerClientEvent('esx:showNotification', src, _('car_not_found', plate))
        end
    else
        TriggerClientEvent('esx:showNotification', src, _('no_permission'))
    end
end)

RegisterServerEvent('admin:logBoostVehicle')
AddEventHandler('admin:logBoostVehicle', function(vehicleName)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local group = xPlayer.getGroup()
    
    if HasPermission(group, 'fixVehicle') then
        print(("[ADMIN] %s boosted vehicle %s performance"):format(
            GetPlayerName(src),
            vehicleName
        ))

        SendAdminLog(
            "boostvehicle",
            "ADMIN BOOST VEHICLE",
            "**Admin:** "..GetPlayerName(src).." (ID "..src..")\n**Vehicle:** "..vehicleName,
            16753920
        )
    end
end)

RegisterServerEvent('admin:giveItemToPlayer')
AddEventHandler('admin:giveItemToPlayer', function(targetId, itemName, count)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local targetPlayer = ESX.GetPlayerFromId(targetId)
    
    if not xPlayer or not targetPlayer then
        TriggerClientEvent('esx:showNotification', src, _('player_not_found'))
        return
    end

    local group = xPlayer.getGroup()
    
    if HasPermission(group, 'giveItem') then
        local item = ESX.GetItemLabel(itemName)
        
        if not item then
            TriggerClientEvent('esx:showNotification', src, _('item_not_exist'))
            return
        end
        
        targetPlayer.addInventoryItem(itemName, count)
        
        print(("[ADMIN] %s gave item %s x%d to player %s"):format(
            GetPlayerName(src),
            itemName,
            count,
            GetPlayerName(targetId)
        ))

        SendAdminLog(
            "giveitem",
            "ADMIN GIVE ITEM",
            "**Admin:** "..GetPlayerName(src).." (ID "..src..")\n**Target:** "..GetPlayerName(targetId).." (ID "..targetId..")\n**Item:** "..itemName.." x"..count,
            3447003
        )
        
        TriggerClientEvent('esx:showNotification', src, _('gave_item', itemName, count, GetPlayerName(targetId)))
        TriggerClientEvent('esx:showNotification', targetId, _('admin_gave_item', itemName, count))
    else
        TriggerClientEvent('esx:showNotification', src, _('no_permission'))
    end
end)

ESX.RegisterServerCallback('admin:getOnlinePlayers', function(source, cb)
    local players = {}
    
    for _, playerId in ipairs(GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            local steamName = GetPlayerName(playerId)
            
            table.insert(players, {
                id = tonumber(playerId),
                name = steamName,
                identifier = xPlayer.identifier,
                group = xPlayer.getGroup(),
                job = xPlayer.getJob()
            })
        end
    end
    
    cb(players)
end)

ESX.RegisterServerCallback('admin:getPlayerDetails', function(source, cb, targetId)
    local xPlayer = ESX.GetPlayerFromId(targetId)
    
    if xPlayer then
        local steamName = GetPlayerName(targetId)
        local job = xPlayer.getJob()
        local accounts = xPlayer.getAccounts()
        
        local accountMoney = {}
        for _, account in ipairs(accounts) do
            accountMoney[account.name] = account.money
        end
        
        cb({
            id = tonumber(targetId),
            name = steamName,
            identifier = xPlayer.identifier,
            group = xPlayer.getGroup(),
            job = job.label .. ' (' .. job.grade_label .. ')',
            job_name = job.name,
            job_grade = job.grade,
            cash = xPlayer.getMoney(),
            bank = accountMoney.bank or 0,
            black_money = accountMoney.black_money or 0
        })
    else
        cb(nil)
    end
end)

AdminPlayers = {}

ESX.RegisterServerCallback('admin:checkDuty', function(source, cb)
    local admin = ESX.GetPlayerFromId(source)
    if admin then
        cb(admin.proveriDuznost() == true)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('lazic:getAdminsPlayers', function(source, cb)
    cb(AdminPlayers)
end)

AddEventHandler('esx:playerDropped', function(source)
    if AdminPlayers[source] ~= nil then
        AdminPlayers[source] = nil
        TriggerClientEvent('lazic:setaj_admine', -1, AdminPlayers)
    end
end)

RegisterNetEvent('admin:enterDuty')
AddEventHandler('admin:enterDuty', function()
    local src = source
    local admin = ESX.GetPlayerFromId(src)
    if not admin then return end

    local grupa = admin.getGroup()
    local steamName = GetPlayerName(src)

    if not IsAdmin(grupa) then
        TriggerClientEvent('ox_lib:notify', src, {
            description = _('no_admin_permission'),
            type = 'error'
        })
        return
    end

    if admin.proveriDuznost() then
        return
    end

    admin.staviDuznost(true)

    if AdminPlayers[src] == nil then
        AdminPlayers[src] = {
            source = src,
            group = admin.getGroup()
        }
    end

    SendAdminLog(
        "duty",
        "ADMIN DUTY ON",
        "**Admin:** "..steamName.." (ID "..src..")\n**Group:** "..grupa,
        3066993
    )

    TriggerClientEvent('lazic:setaj_admine', -1, AdminPlayers)
    TriggerClientEvent('admin:onDutyEntered', src)
    TriggerClientEvent('admin:notifikacijausaoduznost', src)
end)

RegisterNetEvent('admin:leaveDuty')
AddEventHandler('admin:leaveDuty', function()
    local src = source
    local admin = ESX.GetPlayerFromId(src)
    if not admin then return end

    local grupa = admin.getGroup()
    local steamName = GetPlayerName(src)

    if not admin.proveriDuznost() then
        return
    end

    admin.staviDuznost(false)
    AdminPlayers[src] = nil

    SendAdminLog(
        "duty",
        "ADMIN DUTY OFF",
        "**Admin:** "..steamName.." (ID "..src..")\n**Group:** "..grupa,
        15105570
    )

    TriggerClientEvent('lazic:removeAdminTag', -1, src)
    TriggerClientEvent('lazic:setaj_admine', -1, AdminPlayers)
    TriggerClientEvent('admin:notifikacijaizasaoduznost', src)
end)

RegisterServerEvent('admin:teleportToPlayer')
AddEventHandler('admin:teleportToPlayer', function(targetId, playerGroup)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local group = xPlayer.getGroup()
    
    if HasPermission(group, 'gotoplayer') then
        local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
        TriggerClientEvent('admin:doTeleport', source, targetCoords)

        SendAdminLog(
            "gotoplayer",
            "ADMIN GOTO",
            "**Admin:** "..GetPlayerName(src).." (ID "..src..")\n**Target:** "..GetPlayerName(targetId).." (ID "..targetId..")",
            9807270
        )
    else
        print("Player " .. source .. " doesn't have permission for teleport!")
    end
end)

RegisterServerEvent('admin:teleportPlayerToMe')
AddEventHandler('admin:teleportPlayerToMe', function(targetId, coords)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local group = xPlayer.getGroup()
    
    if HasPermission(group, 'bringplayer') then
        TriggerClientEvent('admin:doTeleport', targetId, coords)

        SendAdminLog(
            "bringplayer",
            "ADMIN BRING",
            "**Admin:** "..GetPlayerName(src).." (ID "..src..")\n**Target:** "..GetPlayerName(targetId).." (ID "..targetId..")",
            15158332
        )
    else
        print("Player " .. source .. " doesn't have permission for teleport!")
    end
end)

RegisterServerEvent('admin:healPlayer')
AddEventHandler('admin:healPlayer', function(targetId, playerGroup)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local group = xPlayer.getGroup()
    
    if HasPermission(group, 'heal') then
        TriggerClientEvent('admin:doHeal', targetId)
        print("Admin " .. GetPlayerName(source) .. " healed player " .. GetPlayerName(targetId))
        TriggerClientEvent('esx:showNotification', source, _('player_healed', GetPlayerName(targetId)))

        SendAdminLog(
            "heal",
            "ADMIN HEAL",
            "**Admin:** "..GetPlayerName(src).." (ID "..src..")\n**Target:** "..GetPlayerName(targetId).." (ID "..targetId..")",
            65280
        )
    else
        print("Player " .. GetPlayerName(source) .. " doesn't have permission for heal!")
        TriggerClientEvent('esx:showNotification', source, _('no_permission'))
    end
end)

RegisterServerEvent('admin:revivePlayer')
AddEventHandler('admin:revivePlayer', function(targetId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local group = xPlayer.getGroup()
    
    if HasPermission(group, 'revive') then
        TriggerClientEvent('esx_ambulancejob:revive', targetId)

        print("Admin " .. GetPlayerName(src) .. " revived player " .. GetPlayerName(targetId))
        TriggerClientEvent('esx:showNotification', src, _('player_revived', GetPlayerName(targetId)))

        SendAdminLog(
            "revive",
            "ADMIN REVIVE",
            "**Admin:** "..GetPlayerName(src).." (ID "..src..")\n**Target:** "..GetPlayerName(targetId).." (ID "..targetId..")",
            16711680
        )
    else
        print("Player " .. GetPlayerName(src) .. " doesn't have permission for revive!")
        TriggerClientEvent('esx:showNotification', src, _('no_permission'))
    end
end)

local cachedJobs = nil
local jobsLoading = false
local jobsCallbacks = {}

ESX.RegisterServerCallback('admin:getAllJobs', function(source, cb)
    if cachedJobs then
        cb(cachedJobs)
        return
    end

    table.insert(jobsCallbacks, cb)

    if jobsLoading then return end
    jobsLoading = true

    MySQL.Async.fetchAll('SELECT * FROM jobs', {}, function(jobsResult)
        local jobs = {}
        for _, job in ipairs(jobsResult) do
            jobs[job.name] = { label = job.label, grades = {} }
        end

        MySQL.Async.fetchAll('SELECT * FROM job_grades ORDER BY grade ASC', {}, function(gradesResult)
            for _, grade in ipairs(gradesResult) do
                if jobs[grade.job_name] then
                    jobs[grade.job_name].grades[tostring(grade.grade)] = {
                        label = grade.label,
                        salary = grade.salary,
                        skin_male = grade.skin_male,
                        skin_female = grade.skin_female
                    }
                end
            end

            cachedJobs = jobs
            jobsLoading = false

            for _, callback in ipairs(jobsCallbacks) do
                callback(cachedJobs)
            end
            jobsCallbacks = {}
        end)
    end)
end)

ESX.RegisterServerCallback('admin:getPlayerCurrentJob', function(source, cb, targetId)
    local attempts = 0
    local targetPlayer = ESX.GetPlayerFromId(targetId)

    local function waitForPlayer()
        targetPlayer = ESX.GetPlayerFromId(targetId)
        attempts = attempts + 1

        if targetPlayer then
            local job = targetPlayer.getJob()
            cb({
                name = job.name,
                label = job.label,
                grade = job.grade,
                grade_label = job.grade_label,
                salary = job.salary
            })
        elseif attempts > 10 then
            cb({
                name = _('unknown'),
                label = _('unknown'),
                grade = 0,
                grade_label = _('unknown'),
                salary = 0
            })
        else
            Citizen.Wait(100)
            waitForPlayer()
        end
    end

    waitForPlayer()
end)

RegisterServerEvent('admin:setPlayerJob')
AddEventHandler('admin:setPlayerJob', function(targetId, jobName, grade)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local targetPlayer = ESX.GetPlayerFromId(targetId)
    
    if not xPlayer or not targetPlayer then
        TriggerClientEvent('esx:showNotification', src, _('player_not_found'))
        return
    end

    local group = xPlayer.getGroup()
    
    if HasPermission(group, 'setJob') then
        targetPlayer.setJob(jobName, grade)
        
        print(("[ADMIN] %s changed job for player %s to %s (grade: %s)"):format(
            GetPlayerName(src),
            GetPlayerName(targetId),
            jobName,
            grade
        ))
        
        TriggerClientEvent('esx:showNotification', src, _('job_changed', GetPlayerName(targetId), jobName, grade))
        TriggerClientEvent('esx:showNotification', targetId, _('admin_changed_job'))

        SendAdminLog(
            "setjob",
            "ADMIN SET JOB",
            "**Admin:** "..GetPlayerName(src).." (ID "..src..")\n**Target:** "..GetPlayerName(targetId).." (ID "..targetId..")\n**Job:** "..jobName.." | Grade "..grade,
            16776960
        )
    else
        TriggerClientEvent('esx:showNotification', src, _('no_permission'))
    end
end)

-- REPORT SYSTEM
local reports = {}
local lastReport = {}
local REPORT_COOLDOWN = 15 * 60

RegisterNetEvent('reports:createReport')
AddEventHandler('reports:createReport', function(title, category, details)
    local src = source
    local currentTime = os.time()

    if lastReport[src] and (currentTime - lastReport[src] < REPORT_COOLDOWN) then
        local remaining = REPORT_COOLDOWN - (currentTime - lastReport[src])
        TriggerClientEvent('ox_lib:notify', src, {
            title = _('report_cooldown'),
            description = _('report_cooldown_msg', math.ceil(remaining/60)),
            type = "error",
            duration = 5000,
            position = "top-left"
        })
        return
    end

    lastReport[src] = currentTime
    local id = math.random(1000,9999)
    local steamName = GetPlayerName(src)
    
    reports[id] = {
        playerId = src,
        steamName = steamName or _('unknown'),
        title = title,
        category = category,
        details = details,
        takenBy = nil,
        status = 'active',
        createdAt = currentTime
    }

    -- Notify all online admins who are on duty
    for k,v in pairs(ESX.GetPlayers()) do
        local admin = ESX.GetPlayerFromId(v)
        if admin and IsAdmin(admin.get('group')) then
            if admin.proveriDuznost() == true then
                TriggerClientEvent('ox_lib:notify', v, {
                    title = _('new_report'),
                    description = steamName .. _('sent_report') .. title,
                    type = "inform",
                    duration = 5000,
                    position = "top-left"
                })
            end
        end
    end
    
    TriggerClientEvent('ox_lib:notify', src, {
        title = _('report'),
        description = _('report_sent'),
        type = "success",
        duration = 5000,
        position = "top-left"
    })
end)

ESX.RegisterServerCallback('reports:getAllReports', function(source, cb)
    cb(reports)
end)

RegisterNetEvent('reports:updateReport')
AddEventHandler('reports:updateReport', function(reportId, action)
    local src = source
    local report = reports[reportId]
    if not report then return end

    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not IsAdmin(xPlayer.get('group')) then return end

    local adminName = GetPlayerName(src)

    if action == 'take' then
        if report.takenBy ~= nil then
            TriggerClientEvent('ox_lib:notify', src, {
                title = _('report'),
                description = _('report_already_taken'),
                type = 'error'
            })
            return
        end

        report.takenBy = src
        report.takenByName = adminName
        report.status = 'taken'

    elseif action == 'release' then
        if report.takenBy ~= src then
            TriggerClientEvent('ox_lib:notify', src, {
                title = _('report'),
                description = _('report_not_yours'),
                type = 'error'
            })
            return
        end

        report.takenBy = nil
        report.takenByName = nil
        report.status = 'active'

    elseif action == 'complete' then
        if report.takenBy ~= src then return end
        report.status = 'completed'

    elseif action == 'delete' then
        if report.takenBy ~= src then
            TriggerClientEvent('ox_lib:notify', src, {
                title = _('report'),
                description = _('only_taker_can_delete'),
                type = 'error'
            })
            return
        end
        reports[reportId] = nil
    end

    -- Update all admins
    for _, v in pairs(ESX.GetPlayers()) do
        local admin = ESX.GetPlayerFromId(v)
        if admin and IsAdmin(admin.get('group')) then
            TriggerClientEvent('reports:updateClient', v, reportId, report)
        end
    end
end)

RegisterNetEvent('admin:sendMessageToPlayer')
AddEventHandler('admin:sendMessageToPlayer', function(playerId, message)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not IsAdmin(xPlayer.get('group')) then return end

    local adminName = GetPlayerName(src)

    TriggerClientEvent('ox_lib:notify', playerId, {
        title = _('message_from_admin'),
        description = message,
        type = 'inform',
        position = 'top',
        duration = 7000
    })
end)

-- Function to generate random plate
function GeneratePlate()
    local plate = ""
    local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    for i = 1, 8 do
        local rand = math.random(1, #charset)
        plate = plate .. string.sub(charset, rand, rand)
    end
    
    -- Check if plate already exists
    local result = MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM owned_vehicles WHERE plate = @plate', {
        ['@plate'] = plate
    })
    
    if result > 0 then
        -- Plate exists, generate new one
        return GeneratePlate()
    end
    
    return plate
end
