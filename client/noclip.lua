ESX = exports["es_extended"]:getSharedObject()

RNE = function(e, ...) RegisterNetEvent(e) AddEventHandler(e, ...) end
CT = function(h) Citizen.CreateThread(h) end
CW = function(a) Citizen.Wait(a) end

noclipActive = false
index = 1
noclipEntity = nil

RegisterNetEvent("lazicAdmin:noclip", function()
    noclipActive = not noclipActive

    if IsPedInAnyVehicle(PlayerPedId(), false) then
        noclipEntity = GetVehiclePedIsIn(PlayerPedId(), false)
    else
        noclipEntity = PlayerPedId()
    end

    SetEntityCollision(noclipEntity, not noclipActive, not noclipActive)
    FreezeEntityPosition(noclipEntity, noclipActive)
    SetEntityInvincible(noclipEntity, noclipActive)
    SetVehicleRadioEnabled(noclipEntity, not noclipActive)

    if not noclipActive then
        SetEntityInvincible(PlayerPedId(), false)
        SetPlayerInvincible(PlayerId(), false)
        return
    end

    CT(function()
        local buttons = setupScaleform("instructional_buttons")
        local currentSpeed = Config.Noclip.speeds[index].speed

        while noclipActive do
            CW(1)
            DrawScaleformMovieFullscreen(buttons)

            local yoff, zoff = 0.0, 0.0

            if IsControlJustPressed(1, Config.Noclip.controls.changeSpeed) then
                index = index + 1
                if index > #Config.Noclip.speeds then index = 1 end
                currentSpeed = Config.Noclip.speeds[index].speed
                buttons = setupScaleform("instructional_buttons")
            end

            if IsControlPressed(0, Config.Noclip.controls.goForward) then
                yoff = Config.Noclip.offsets.y
            end

            if IsControlPressed(0, Config.Noclip.controls.goBackward) then
                yoff = -Config.Noclip.offsets.y
            end

            if IsControlPressed(0, Config.Noclip.controls.turnLeft) then
                SetEntityHeading(noclipEntity, GetEntityHeading(noclipEntity) + Config.Noclip.offsets.h)
            end

            if IsControlPressed(0, Config.Noclip.controls.turnRight) then
                SetEntityHeading(noclipEntity, GetEntityHeading(noclipEntity) - Config.Noclip.offsets.h)
            end

            if IsControlPressed(0, Config.Noclip.controls.goUp) then
                zoff = Config.Noclip.offsets.z
            end

            if IsControlPressed(0, Config.Noclip.controls.goDown) then
                zoff = -Config.Noclip.offsets.z
            end

            local newPos = GetOffsetFromEntityInWorldCoords(
                noclipEntity,
                0.0,
                yoff * (currentSpeed + 0.3),
                zoff * (currentSpeed + 0.3)
            )

            local heading = GetEntityHeading(noclipEntity)
            SetEntityVelocity(noclipEntity, 0.0, 0.0, 0.0)
            SetEntityRotation(noclipEntity, 0.0, 0.0, 0.0, 0, false)
            SetEntityHeading(noclipEntity, heading)
            SetEntityCoordsNoOffset(
                noclipEntity,
                newPos.x,
                newPos.y,
                newPos.z,
                true,
                true,
                true
            )
        end
    end)
end)

function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

function Button(control)
    N_0xe83a3e3557a56640(control)
end

function setupScaleform(scaleform)
    local sf = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(sf) do CW(1) end

    PushScaleformMovieFunction(sf, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(sf, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(sf, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(4)
    Button(GetControlInstructionalButton(2, Config.Noclip.controls.goUp, true))
    ButtonMessage("Gore")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(sf, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    Button(GetControlInstructionalButton(2, Config.Noclip.controls.goDown, true))
    ButtonMessage("Dole")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(sf, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    Button(GetControlInstructionalButton(1, Config.Noclip.controls.turnRight, true))
    Button(GetControlInstructionalButton(1, Config.Noclip.controls.turnLeft, true))
    ButtonMessage("Levo / Desno")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(sf, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    Button(GetControlInstructionalButton(1, Config.Noclip.controls.goBackward, true))
    Button(GetControlInstructionalButton(1, Config.Noclip.controls.goForward, true))
    ButtonMessage("Napred / Nazad")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(sf, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    Button(GetControlInstructionalButton(2, Config.Noclip.controls.changeSpeed, true))
    ButtonMessage("Brzina (" .. Config.Noclip.speeds[index].label .. ")")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(sf, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(sf, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(Config.Noclip.background.r)
    PushScaleformMovieFunctionParameterInt(Config.Noclip.background.g)
    PushScaleformMovieFunctionParameterInt(Config.Noclip.background.b)
    PushScaleformMovieFunctionParameterInt(Config.Noclip.background.a)
    PopScaleformMovieFunctionVoid()

    return sf
end
