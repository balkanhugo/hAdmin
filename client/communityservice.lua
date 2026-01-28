ESX = exports['es_extended']:getSharedObject()

local isInService = false
local currentActions = 0
local activeProps = {}
local maxProps = Config.MaxProps


local function DisableCombat()
    DisablePlayerFiring(PlayerId(), true)
    DisableControlAction(0, 24, true) -- Attack
    DisableControlAction(0, 25, true) -- Aim
    DisableControlAction(0, 47, true) -- Weapon
    DisableControlAction(0, 58, true) -- Weapon
    DisableControlAction(0, 140, true) -- Melee Attack 1
    DisableControlAction(0, 141, true) -- Melee Attack 2
    DisableControlAction(0, 142, true) -- Melee Attack 3
    DisableControlAction(0, 143, true) -- Melee Attack 4
    DisableControlAction(0, 263, true) -- Melee Attack 1
    DisableControlAction(0, 264, true) -- Melee Attack 2
    DisableControlAction(0, 257, true) -- Attack 2
end

local function SpawnProps()
    while #activeProps < maxProps do
        local offset = vector3(math.random(-10, 10), math.random(-10, 10), 0)
        local coords = Config.ServiceLocation + offset
        
        local model = Config.Props[math.random(#Config.Props)]
        lib.requestModel(model)
        
        local prop = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
        PlaceObjectOnGroundProperly(prop)
        FreezeEntityPosition(prop, true)

        exports.ox_target:addLocalEntity(prop, {
            {
                name = 'clean_trash',
                label = _('clean_trash'),
                icon = 'fas fa-broom',
                onSelect = function()
                    lib.progressCircle({
                        duration = 5000,
                        label = _('cleaning_trash'),
                        position = 'bottom',
                        useWhileDead = false,
                        canCancel = false,
                        disable = {
                            car = true,
                            move = true,
                            combat = true
                        },
                        anim = {
                            dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                            clip = 'machinic_loop_mechandplayer'
                        }
                    })
                    
                    DeleteEntity(prop)
                    for k, v in pairs(activeProps) do
                        if v == prop then
                            table.remove(activeProps, k)
                            break
                        end
                    end
                    TriggerServerEvent('tj_communityservice:completeAction')
                    SpawnProps()
                end
            }
        })
        
        table.insert(activeProps, prop)
    end
end

local function ShowRemainingActions()
    if not isInService then return end
    
    local text = string.format(_('remairing_actions'), currentActions)
    lib.showTextUI(text, {
        position = 'right-center',
        icon = 'broom',
        style = {
            backgroundColor = 'rgba(0, 0, 0, 0.7)',
            color = 'white'
        }
    })
end

RegisterNetEvent('tj_communityservice:inService')
AddEventHandler('tj_communityservice:inService', function(actions)
    isInService = true
    currentActions = actions
    
    SetEntityCoords(PlayerPedId(), Config.ServiceLocation.x, Config.ServiceLocation.y, Config.ServiceLocation.z)
    
    SpawnProps()
    ShowRemainingActions()
    
    CreateThread(function()
        while isInService do
            Wait(0)
            DisableCombat()
            
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - Config.ServiceLocation)
            
            if distance > Config.MaxDistance then
                SetEntityCoords(PlayerPedId(), Config.ServiceLocation.x, Config.ServiceLocation.y, Config.ServiceLocation.z)
            end
            
            ShowRemainingActions()
        end
    end)
end)

RegisterNetEvent('tj_communityservice:updateActions')
AddEventHandler('tj_communityservice:updateActions', function(actions)
    currentActions = actions
    ShowRemainingActions()
end)

RegisterNetEvent('tj_communityservice:finishService')
AddEventHandler('tj_communityservice:finishService', function()
    isInService = false
    currentActions = 0
    
    lib.hideTextUI()
    
    for _, prop in pairs(activeProps) do
        DeleteEntity(prop)
    end
    
    ESX.ShowNotification(_('finished'))
    Wait(500)
    activeProps = {}
    SetEntityCoords(PlayerPedId(), Config.EndServiceLocation.x, Config.EndServiceLocation.y, Config.EndServiceLocation.z)
end)

RegisterNetEvent('tj_communityservice:heal')
AddEventHandler('tj_communityservice:heal', function()
    SetEntityHealth(PlayerPedId(), GetEntityMaxHealth(PlayerPedId()))
end)

RegisterCommand(Config.CommunityService.Command, function()
    ESX.TriggerServerCallback("community_service:checkAdmin", function(playerRank)
        if Config.AuthorizedGroups[playerRank] then
            lib.showContext('community_service_menu')
        else
            return ESX.ShowNotification(_('no_perm'))
        end 
    end)
end)

lib.registerContext({
    id = 'community_service_menu',
    title = _('comm_service_menu'),
    options = {
        {
            title = _('send_player'),
            description = _('comm_service_count'),
            onSelect = function()
                local input = lib.inputDialog(_('send_player'), {
                    {type = 'number', label = _('player_id'), description = _('player_id_desc'), required = true},
                    {type = 'number', label = _('actions'), description = _('actions_desc'), required = true, min = 1},
                    {type = 'input', label = _('reason'), description = _('reason_desc'), required = true}
                })
                
                if input then
                    TriggerServerEvent('tj_communityservice:sendToService', input[1], input[2], input[3])
                end
            end
        },
        {
            title = _('active_player_wiew'),
            description = _('active_player_desc'),
            onSelect = function()
                local players = lib.callback.await('tj_communityservice:getActivePlayers')
                local options = {}
                
                for _, player in ipairs(players) do
                    table.insert(options, {
                        title = player.name,
                        description = string.format(_('remaining_resaon'), player.remaining, player.total, player.reason),
                        onSelect = function()
                            lib.registerContext({
                                id = 'player_actions_menu',
                                title = string.format(_('actions_for'), player.name),
                                menu = 'active_players_menu',
                                options = {
                                    {
                                        title = _('remove_service'),
                                        description = _('remove_service_desc'),
                                        onSelect = function()
                                            TriggerServerEvent('tj_communityservice:removeFromService', player.id)
                                            lib.showContext('community_service_menu')
                                        end
                                    },
                                    {
                                        title = _('edit_actions'),
                                        description = _('edit_actions_desc'),
                                        onSelect = function()
                                            lib.registerContext({
                                                id = 'edit_actions_menu',
                                                title = _('edit_actions'),
                                                menu = 'player_actions_menu',
                                                options = {
                                                    {
                                                        title = _('add_actions'),
                                                        description = _('add_actions_desc'),
                                                        onSelect = function()
                                                            local input = lib.inputDialog(_('add_actions'), {
                                                                {type = 'number', label = _('number_actions'), description = _('number_add_description'), required = true, min = 1}
                                                            })
                                                            
                                                            if input then
                                                                TriggerServerEvent('tj_communityservice:addMarkers', player.id, input[1])
                                                                lib.showContext('community_service_menu')
                                                            end
                                                        end
                                                    },
                                                    {
                                                        title = _('remove_actions'),
                                                        description = _('remove_actions_desc'),
                                                        onSelect = function()
                                                            local input = lib.inputDialog(_('remove_actions'), {
                                                                {type = 'number', label = _('number_actions'), description = _('number_remove_description'), required = true, min = 1}
                                                            })
                                                            
                                                            if input then
                                                                TriggerServerEvent('tj_communityservice:removeMarkers', player.id, input[1])
                                                                lib.showContext('community_service_menu')
                                                            end
                                                        end
                                                    }
                                                }
                                            })
                                            lib.showContext('edit_actions_menu')
                                        end
                                    }
                                }
                            })
                            lib.showContext('player_actions_menu')
                        end
                    })
                end
                
                lib.registerContext({
                    id = 'active_players_menu',
                    title = _('active_players'),
                    menu = 'community_service_menu',
                    options = options
                })
                
                lib.showContext('active_players_menu')
            end
        }
    }
})

-- jobs

local function GetNearbyPlayers()
    local nearbyPlayers = {}
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, playerId in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)
            
            if distance <= Config.MaxTargetDistance then
                local serverPlayerId = GetPlayerServerId(playerId)
                local playerName = GetPlayerName(playerId)
                table.insert(nearbyPlayers, {
                    id = serverPlayerId,
                    name = playerName,
                    distance = distance
                })
            end
        end
    end
    
    return nearbyPlayers
end

local function OpenPlayerSelectionDialog()
    local nearbyPlayers = GetNearbyPlayers()
    local playerOptions = {}
    for _, player in ipairs(nearbyPlayers) do
        table.insert(playerOptions, {
            label = string.format("%s (ID: %s)", player.name, player.id),
            value = player.id
        })
    end

    local input = lib.inputDialog(_('send_player'), {
        {
            type = 'select',
            label = _('player'),
            description = _('select_player'),
            options = playerOptions,
            required = true
        },
        {
            type = 'number',
            label = _('actions'),
            description = _('actions_desc'),
            required = true,
            min = 1
        },
        {
            type = 'input',
            label = _('reason'),
            description = _('reason_desc'),
            required = true
        }
    })
    
    if input then
        local selectedPlayerId = input[1]
        local actions = input[2]
        local reason = input[3]
        TriggerServerEvent('tj_communityservice:sendToService', selectedPlayerId, actions, reason)
    end
end

local function OpenCommunityServiceMenu()
    ESX.TriggerServerCallback("community_service:checkJobAccess", function(hasAccess)
        if hasAccess then
            OpenPlayerSelectionDialog()
        else
            return ESX.ShowNotification(_('no_perm'))
        end 
    end)
end

exports.ox_target:addGlobalPlayer({
    {
        name = 'community_service_action',
        label = _('send_to_service'),
        icon = 'fas fa-broom',
        canInteract = function(entity)
            return Config.JobRolesAccess[ESX.PlayerData.job.name] and not IsPedInAnyVehicle(PlayerPedId(), false)
        end,
        onSelect = function(data)
            local nearbyPlayers = GetNearbyPlayers()
            if #nearbyPlayers == 0 then
                ESX.ShowNotification(_('no_nearby_players'))
                return
            end
            OpenPlayerSelectionDialog()
        end
    }
})
