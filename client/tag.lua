ESX = exports["es_extended"]:getSharedObject()

local currentAdminPlayers = {}
local visibleAdmins = {}

RegisterNetEvent('lazic:setaj_admine')
AddEventHandler('lazic:setaj_admine', function(admins)
    currentAdminPlayers = admins

    for id, _ in pairs(visibleAdmins) do
        if admins[id] == nil then
            visibleAdmins[id] = nil
        end
    end
end)

RegisterNetEvent('lazic:removeAdminTag')
AddEventHandler('lazic:removeAdminTag', function(src)
    visibleAdmins[src] = nil
    currentAdminPlayers[src] = nil
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.AdminTags.NearCheckWait)
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)

        for k, v in pairs(currentAdminPlayers) do
            local playerServerID = GetPlayerFromServerId(v.source)
            if playerServerID ~= -1 then
                local adminPed = GetPlayerPed(playerServerID)
                local adminCoords = GetEntityCoords(adminPed)

                local distance = #(adminCoords - pedCoords)
                if distance < (Config.AdminTags.SeeDistance) then
                    visibleAdmins[v.source] = v
                else
                    visibleAdmins[v.source] = nil
                end
            end
        end
    end
end)

function getAdminTagColor(group)
    local color = Config.AdminTags.Colors[group]
        or Config.AdminTags.DefaultColor

    return string.format(
        "%d, %d, %d, %.1f",
        color.r,
        color.g,
        color.b,
        color.a
    )
end

local showIDs = false
local pokazujem = false

RegisterNetEvent("lazicAdmin:showIDs", function()
    showIDs = not showIDs
end)

RegisterNetEvent("lazicAdmin2:showIDs2", function()
    showIDs = false
    pokazujem = false
end)

CreateThread(function()
    while true do
        -- Fast-exit: if neither IDs nor nearby admin tags are active, sleep a full second
        -- and skip all the expensive native calls entirely.
        local needsDraw = showIDs or (not pokazujem and next(currentAdminPlayers) ~= nil)
        if not needsDraw then
            Wait(1000)
        else
            local pPed   = PlayerPedId()
            local coord  = GetEntityCoords(pPed)
            local igraci = GetActivePlayers()
            local letSleep = true

            for i = 1, #igraci do
                local ped2       = GetPlayerPed(igraci[i])
                local coord2     = GetEntityCoords(ped2)
                local srvID      = GetPlayerServerId(igraci[i])
                local playerData = Player(srvID).state
                local bojaTag    = getAdminTagColor(playerData.aGroup)

                if not pokazujem and #(coord - coord2) < 20 and not showIDs then
                    if Config.AdminTags.Colors[playerData.aGroup] and playerData.aduty then
                        letSleep = false
                        draw3dNUI(
                            "<span style='color:rgba("..bojaTag.."); font-size: 1.5em;'>[ "..playerData.aGroup.." ]</span> <br> "..GetPlayerName(igraci[i]),
                            coord2 + vector3(0.0,0.0,1.1),
                            "player-"..srvID
                        )
                    end
                end

                if showIDs and #(coord - coord2) < 100 then
                    letSleep = false
                    draw3dNUI(
                        "[ "..srvID.." ] | "..GetPlayerName(igraci[i]),
                        coord2 + vector3(0.0,0.0,0.855),
                        "ids-"..srvID
                    )
                end
            end

            if letSleep then
                Wait(1000)
            else
                Wait(20)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        -- When no admins are in range, sleep and skip all native calls.
        -- When admins are nearby, draw at ~33fps (30ms) — imperceptible for 3D text
        -- but cuts this thread's cost by ~95% compared to the original Wait(0).
        if next(visibleAdmins) == nil then
            Wait(750)
        else
            Wait(30)
            for k, v in pairs(visibleAdmins) do
                local playerServerID = GetPlayerFromServerId(v.source)
                if playerServerID ~= -1 then
                    local adminPed    = GetPlayerPed(playerServerID)
                    local adminCoords = GetEntityCoords(adminPed)
                    local bojaTag     = getAdminTagColor(v.group)

                    if IsEntityVisible(adminPed) then
                        draw3dNUI(
                            "<span style='color:rgba("..bojaTag.."); font-size:1.8vh;'>[ "..Config.Groups.labels[v.group].." ]</span> <br> "..GetPlayerName(playerServerID),
                            adminCoords + vector3(0.0,0.0,1.1),
                            'ids-'..playerServerID
                        )
                    end
                end
            end
        end
    end
end)

function draw3dNUI(text, coords, id)
    local paused = IsPauseMenuActive()
    local onScreen,_x,_y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)
    if not paused then
        isDrawing = true
        SendNUIMessage({action = "display", x = _x, y = _y, text = text, id = id})
    end
end

exports('crtajNUI', function(text, coords, id)
    draw3dNUI(text, coords, id)
end)
