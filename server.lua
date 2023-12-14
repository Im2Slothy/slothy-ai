local aiPerson = nil

-- So this spawns the AI onto the map
function SpawnAI()
-- CREATE_PED
    print("Spawning AI...")
    local pedType = 4 -- Ped type for human-like characters
    local modelHash = GetHashKey('s_m_m_movalien_01') -- Alien Model
    local heading = 295.51 -- Heading of the AI
    local isNetwork = true
    local bScriptHostPed = false

    print("Model Hash:", modelHash)
    print("Coordinates: 253.9, -876.43, 30.29")

    aiPerson = CreatePed(pedType, modelHash, 253.9, -876.43, 30.30, heading, isNetwork, bScriptHostPed)  
    SetEntityInvincible(aiPerson, true)
    FreezeEntityPosition(aiPerson, true)
    SetEntityVisible(aiPerson, true, true) -- I think it wont spawn because of something here, I am getting the print statements though

    print("AI spawned successfully!")
end

-- When the script starts make sure the AI actually Spawns
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SpawnAI()
        print('AI spawned successfully!')
    end
end)