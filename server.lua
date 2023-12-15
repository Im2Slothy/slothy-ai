-- Function to draw text in 3D
function DrawText3D(x, y, z, text, scl, font)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local camX, camY, camZ = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(camX, camY, camZ, x, y, z, 1)

    local scale = (1 / dist) * scl
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov

    if onScreen then
        SetTextScale(0.0 * scale, 1.1 * scale)
        SetTextFont(font)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Function to add an NPC
function addNPC(x, y, z, heading, model, headingText)
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        Wait(15)
    end
    ped = CreatePed(4, GetHashKey(model), x, y, z - 1, heading, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
end

-- Main code to spawn NPCs and display text
CreateThread(function()
    local displayText = true
    local displayDistance = 20.0
    local displayColor = "~g~"

    local peds = {
        -- { x, y, z, ped heading, ped model, heading text }
        {254.34, -876.95, 30.30, 292.66, "s_m_m_scientist_01", "Talk to an AI"}
    }

    for _, v in pairs(peds) do
        addNPC(v[1], v[2], v[3], v[4], v[5], v[6])
    end

    while displayText do
        local pos = GetEntityCoords(PlayerPedId())
        Wait(0)
        for _, v in pairs(peds) do
            local distance = #(pos - vec3(v[1], v[2], v[3]))
            if (distance < displayDistance) then
                DrawText3D(v[1], v[2], v[3] + 1, displayColor .. v[6], 1.2, 1)
            end
        end
    end
end)