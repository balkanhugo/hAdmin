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
    local grupa = admin.getGroup()
    if grupa == "admin" or grupa == "superadmin" or grupa == "helper" or grupa == "headadmin" or grupa == "developer" or grupa == "owner" or grupa == "direktor" then
        if admin.proveriDuznost() == true then
            TriggerClientEvent('lazicAdmin:showIDs', source)
        else
            --TriggerClientEvent('lmodciz_repair:nemasDozvoluIDDDDD', source)
            print('nisi na duznosti')
        end
    else
        --TriggerClientEvent('lmodciz_repair:nemasDozvolu', source)
        print('nisi admin')
    end
end)

ESX.RegisterServerCallback('adminmenu:isAdmin', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        cb(false)
        return
    end

    local group = xPlayer.getGroup()

    if group == 'admin' or group == 'superadmin' or group == 'helper' or group == 'developer' or group == 'headadmin' or group == 'direktor' or group == 'owner' then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent('adminmenu:checkPermission', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    local group = xPlayer.getGroup()

    if group == 'admin' or group == 'superadmin' or group == 'helper' or group == 'developer' or group == 'headadmin' or group == 'direktor' or group == 'owner' then
        TriggerClientEvent('adminmenu:open', src)
    else
        print('no admin sinko')
    end
end)

local function SendAdminLog(type, title, description, color)
    local cfg = Config.AdminLogs[type]
    if not cfg or not cfg.enabled or not cfg.webhook or cfg.webhook == "" then return end

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
        local group = xPlayer.getGroup() or 'user'
        cb(group)
    else
        cb('user')
    end
end)

ESX.RegisterServerCallback('admin:getMyGroup', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local group = xPlayer.getGroup() or 'user'
        cb(group)
    else
        cb('user')
    end
end)

ESX.RegisterServerCallback('admin:setPlayerGroup', function(source, cb, targetId, newGroup, reason)
    local admin = ESX.GetPlayerFromId(source)
    local target = ESX.GetPlayerFromId(targetId)
    
    if not admin or not target then
        cb(false, 'Igrac nije pronadjen')
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
            cb(false, 'Nemate dozvolu za ovu grupu')
            return
        end

        local adminIndex = Config.Groups.index[adminGroup] or 1
        local newGroupIndex = Config.Groups.index[newGroup] or 1

        if newGroupIndex >= adminIndex then
            cb(false, Config.Groups.messages.higherGroup)
            return
        end

        if source == targetId then
            cb(false, Config.Groups.messages.selfSet)
            return
        end
    end

    target.setGroup(newGroup)

    print(('^5[ADMIN] ^7%s (ID: %s) je setovao grupu %s igracu %s (ID: %s). Razlog: %s^7'):format(
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
            title = "Grupa Promenjena",
            description = "Vasa grupa je promenjena u: " .. newGroup .. " od strane " .. admin.getName(),
            type = "inform",
            duration = 5000,
            position = "top-right"
        })
    end

    cb(true, 'Grupa uspesno promenjena')
end)


RegisterServerEvent('admin:giveVehicleToPlayer')
AddEventHandler('admin:giveVehicleToPlayer', function(targetId, vehicleModel, spawnInVehicle)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local targetPlayer = ESX.GetPlayerFromId(targetId)
    
    if not xPlayer or not targetPlayer then
        TriggerClientEvent('esx:showNotification', src, 'Igrac nije pronadjen!')
        return
    end

    local group = xPlayer.getGroup()
    
    if group == 'admin' or group == 'superadmin' or group == 'helper' or group == 'developer' or group == 'headadmin' or group == 'direktor' or group == 'owner' then
        TriggerClientEvent('admin:spawnVehicleForPlayer', targetId, vehicleModel, spawnInVehicle)
        
        print(("[ADMIN] %s je poslao vozilo %s igracu %s"):format(
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
        
        TriggerClientEvent('esx:showNotification', src, ('Poslao si vozilo %s igracu %s'):format(vehicleModel, GetPlayerName(targetId)))
        
    else
        TriggerClientEvent('esx:showNotification', src, 'Nemate permisije za ovu akciju!')
    end
end)

RegisterServerEvent('admin:giveItemToPlayer')
AddEventHandler('admin:giveItemToPlayer', function(targetId, itemName, count)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local targetPlayer = ESX.GetPlayerFromId(targetId)
    
    if not xPlayer or not targetPlayer then
        TriggerClientEvent('esx:showNotification', src, 'Igrac nije pronadjen!')
        return
    end

    local group = xPlayer.getGroup()
    
    if group == 'admin' or group == 'superadmin' or group == 'helper' or group == 'developer' or group == 'headadmin' or group == 'direktor' or group == 'owner' then
        local item = ESX.GetItemLabel(itemName)
        
        if not item then
            TriggerClientEvent('esx:showNotification', src, 'Item ne postoji!')
            return
        end
        
        targetPlayer.addInventoryItem(itemName, count)
        
        print(("[ADMIN] %s je dao item %s x%d igracu %s"):format(
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
        
        TriggerClientEvent('esx:showNotification', src, ('Dao si %s x%d igracu %s'):format(itemName, count, GetPlayerName(targetId)))
        
        TriggerClientEvent('esx:showNotification', targetId, ('Admin vam je dao %s x%d'):format(itemName, count))
        
    else
        TriggerClientEvent('esx:showNotification', src, 'Nemate permisije za ovu akciju!')
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

    local allowedGroups = { "admin", "superadmin", "helper", "headadmin", "developer", "owner", "direktor" }

    local allowed = false
    for _, v in ipairs(allowedGroups) do
        if grupa == v then
            allowed = true
            break
        end
    end

    if not allowed then
        TriggerClientEvent('ox_lib:notify', src, {
            description = 'Nemas dozvolu za admin meni!',
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
    if group == 'admin' or group == 'superadmin' or group == 'helper' or group == 'developer' or group == 'headadmin' or group == 'direktor' or group == 'owner' then
        local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
        TriggerClientEvent('admin:doTeleport', source, targetCoords)

        SendAdminLog(
            "gotoplayer",
            "ADMIN GOTO",
            "**Admin:** "..GetPlayerName(src).." (ID "..src..")\n**Target:** "..GetPlayerName(targetId).." (ID "..targetId..")",
            9807270
        )
    else
        print("Player " .. source .. " nema permisije za teleport!")
    end
end)

RegisterServerEvent('admin:teleportPlayerToMe')
AddEventHandler('admin:teleportPlayerToMe', function(targetId, coords)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    local group = xPlayer.getGroup()
    if group == 'admin' or group == 'superadmin' or group == 'helper' or group == 'developer' or group == 'headadmin' or group == 'direktor' or group == 'owner' then
        TriggerClientEvent('admin:doTeleport', targetId, coords)

        SendAdminLog(
            "bringplayer",
            "ADMIN BRING",
            "**Admin:** "..GetPlayerName(src).." (ID "..src..")\n**Target:** "..GetPlayerName(targetId).." (ID "..targetId..")",
            15158332
        )
    else
        print("Player " .. source .. " nema permisije za teleport!")
    end
end)

RegisterServerEvent('admin:healPlayer')
AddEventHandler('admin:healPlayer', function(targetId, playerGroup)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    local group = xPlayer.getGroup()
    
    if group == 'admin' or group == 'superadmin' or group == 'helper' or group == 'developer' or group == 'headadmin' or group == 'direktor' or group == 'owner' then
        TriggerClientEvent('admin:doHeal', targetId)
        print("Admin " .. GetPlayerName(source) .. " je healovao igraca " .. GetPlayerName(targetId))
        TriggerClientEvent('esx:showNotification', source, 'Igrac ' .. GetPlayerName(targetId) .. ' je izlecen!')

        SendAdminLog(
            "heal",
            "ADMIN HEAL",
            "**Admin:** "..GetPlayerName(src).." (ID "..src..")\n**Target:** "..GetPlayerName(targetId).." (ID "..targetId..")",
            65280
        )
    else
        print("Player " .. GetPlayerName(source) .. " nema permisije za heal!")
        TriggerClientEvent('esx:showNotification', source, 'Nemate permisije za ovu akciju!')
    end
end)

RegisterServerEvent('admin:revivePlayer')
AddEventHandler('admin:revivePlayer', function(targetId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local group = xPlayer.getGroup()
    if group == 'admin' or group == 'superadmin' or group == 'helper' or group == 'developer' or group == 'headadmin' or group == 'direktor' or group == 'owner' then

        TriggerClientEvent('esx_ambulancejob:revive', targetId)

        print("Admin " .. GetPlayerName(src) .. " je revive-ovao igraca " .. GetPlayerName(targetId))
        TriggerClientEvent('esx:showNotification', src, 'Igrac ' .. GetPlayerName(targetId) .. ' je ozivljen!')

        SendAdminLog(
            "revive",
            "ADMIN REVIVE",
            "**Admin:** "..GetPlayerName(src).." (ID "..src..")\n**Target:** "..GetPlayerName(targetId).." (ID "..targetId..")",
            16711680
        )
    else
        print("Player " .. GetPlayerName(src) .. " nema permisije za revive!")
        TriggerClientEvent('esx:showNotification', src, 'Nemate permisije za ovu akciju!')
    end
end)

-- RegisterCommand("aduty", function(source)
--     local admin = ESX.GetPlayerFromId(source)
--     local grupa = admin.getGroup()
--     local steamName = GetPlayerName(source)

--     if grupa == "admin" or grupa == "superadmin" or grupa == "helper" or grupa == "headadmin"
--     or grupa == "developer" or grupa == "owner" or grupa == "direktor" then

--         if admin.proveriDuznost() == false then

--             admin.staviDuznost(true)

--             if AdminPlayers[source] == nil then
--                 AdminPlayers[source] = {
--                     source = source, 
--                     group = admin.getGroup()
--                 }
--             end

--             LogToDiscord(
--                 "Admin Duty | Ulazak na duznost",
--                 "**Steam:** " .. steamName ..
--                 "\n**ID:** " .. source ..
--                 "\n**Grupa:** " .. grupa,
--                 65280
--             )

--         else

--             admin.staviDuznost(false)
--             AdminPlayers[source] = nil

--             LogToDiscord(
--                 "Admin Duty | Izlazak sa duznosti",
--                 "**Steam:** " .. steamName ..
--                 "\n**ID:** " .. source ..
--                 "\n**Grupa:** " .. grupa,
--                 16711680
--             )
--         end

--     else
--         TriggerClientEvent('lmodciz_admin:nemasDozvolu', source)
--     end

--     TriggerClientEvent('lazic:setaj_admine', -1, AdminPlayers)
-- end)

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
                name = "Nepoznato",
                label = "Nepoznato",
                grade = 0,
                grade_label = "Nepoznato",
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
        TriggerClientEvent('esx:showNotification', src, 'Igrac nije pronadjen!')
        return
    end

    local group = xPlayer.getGroup()
    
    if group == 'admin' or group == 'superadmin' or group == 'helper' or group == 'developer' or group == 'headadmin' or group == 'direktor' or group == 'owner' then
        targetPlayer.setJob(jobName, grade)
        
        print(("[ADMIN] %s je promenio posao igracu %s na %s (grade: %s)"):format(
            GetPlayerName(src),
            GetPlayerName(targetId),
            jobName,
            grade
        ))
        
        TriggerClientEvent('esx:showNotification', src, ('Promenjen posao za %s'):format(GetPlayerName(targetId)))
        TriggerClientEvent('esx:showNotification', targetId, 'Admin vam je promenio posao!')

        SendAdminLog(
            "setjob",
            "ADMIN SET JOB",
            "**Admin:** "..GetPlayerName(src).." (ID "..src..")\n**Target:** "..GetPlayerName(targetId).." (ID "..targetId..")\n**Job:** "..jobName.." | Grade "..grade,
            16776960
        )
    else
        TriggerClientEvent('esx:showNotification', src, 'Nemate permisije za ovu akciju!')
    end
end)

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
            title = "Report Cooldown",
            description = "Mozete poslati novi report za jos " .. math.ceil(remaining/60) .. " minuta.",
            type = "error",
            duration = 5000,
            position = "top-right"
        })
        return
    end

    lastReport[src] = currentTime
    local id = math.random(1000,9999)
    local steamName = GetPlayerName(src)
    
    reports[id] = {
        playerId = src,
        steamName = steamName or "Nepoznato",
        title = title,
        category = category,
        details = details,
        takenBy = nil,
        status = 'active',
        createdAt = currentTime
    }

    for k,v in pairs(ESX.GetPlayers()) do
        local admin = ESX.GetPlayerFromId(v)
        if admin and admin.get('group') ~= 'user' then
            if admin.proveriDuznost() == true then
                TriggerClientEvent('ox_lib:notify', v, {
                    title = "Novi Report",
                    description = steamName .. " je poslao report: " .. title,
                    type = "inform",
                    duration = 5000,
                    position = "top-right"
                })
            end
        end
    end
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
    if not xPlayer or xPlayer.get('group') == 'user' then return end

    local adminName = GetPlayerName(src)

    if action == 'take' then
        if report.takenBy ~= nil then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Report',
                description = 'Ovaj report je vec preuzet!',
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
                title = 'Report',
                description = 'Ne mozes osloboditi report koji nisi preuzeo!',
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
                title = 'Report',
                description = 'Samo admin koji je preuzeo report moze da ga obrise!',
                type = 'error'
            })
            return
        end
        reports[reportId] = nil
    end

    for _, v in pairs(ESX.GetPlayers()) do
        local admin = ESX.GetPlayerFromId(v)
        if admin and admin.get('group') ~= 'user' then
            TriggerClientEvent('reports:updateClient', v, reportId, report)
        end
    end
end)

RegisterNetEvent('admin:sendMessageToPlayer')
AddEventHandler('admin:sendMessageToPlayer', function(playerId, message)
    local src = source

    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or xPlayer.get('group') == 'user' then return end

    local adminName = GetPlayerName(src)

    TriggerClientEvent('ox_lib:notify', playerId, {
        title = 'Poruka od Admina',
        description = message,
        type = 'inform',
        position = 'top',
        duration = 7000
    })
end)