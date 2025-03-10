QBCore = exports['qb-core']:GetCoreObject()

local currentResponse = nil
local displayActive = false
local displayPed = nil

-- Load and create the ped when resource starts
Citizen.CreateThread(function()
    RequestModel(GetHashKey(Config.AIModel))
    while not HasModelLoaded(GetHashKey(Config.AIModel)) do
        Wait(1)
    end

    local ped = CreatePed(4, GetHashKey(Config.AIModel), Config.AILocation.x, Config.AILocation.y, Config.AILocation.z-1, Config.AILocation.heading, false, true)
    SetEntityHeading(ped, Config.AILocation.heading)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    displayPed = ped

    -- Add qb-target interaction
    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                type = "client",
                event = "slothyAI:openQuestionMenu",
                icon = "fas fa-question",
                label = "Ask Question",
            },
        },
        distance = 2.0
    })

    -- Single thread for text display
    while true do
        Wait(0)
        if currentResponse and displayPed then
            local coords = GetEntityCoords(displayPed)
            DrawText3D(coords.x, coords.y, coords.z + 1.0, currentResponse)
        end
    end
end)

-- Handle the question menu
RegisterNetEvent('slothyAI:openQuestionMenu')
AddEventHandler('slothyAI:openQuestionMenu', function()
    local input = exports['qb-input']:ShowInput({
        header = "Ask the AI",
        submitText = "Submit",
        inputs = {
            {
                type = 'text',
                isRequired = true,
                name = 'question',
                text = 'Type your question here'
            }
        }
    })
    
    if input and input.question then
        TriggerServerEvent('slothyAI:askQuestion', input.question)
    end
end)

-- Display AI response above ped
RegisterNetEvent('slothyAI:showResponse')
AddEventHandler('slothyAI:showResponse', function(response)
    if displayPed then
        currentResponse = response
        if not displayActive then
            displayActive = true
            Citizen.CreateThread(function()
                Wait(10000) -- Display for 10 seconds
                currentResponse = nil
                displayActive = false
            end)
        end
    end
end)

-- Simple word wrap function
function WordWrap(text, maxCharsPerLine)
    local wrappedText = {}
    local currentLine = ""
    local words = {}
    
    -- Split text into words
    for word in string.gmatch(text, "%S+") do
        table.insert(words, word)
    end
    
    -- Build lines
    for i, word in ipairs(words) do
        local newLength = string.len(currentLine .. word)
        if newLength <= maxCharsPerLine then
            currentLine = currentLine .. (currentLine == "" and "" or " ") .. word
        else
            if currentLine ~= "" then
                table.insert(wrappedText, currentLine)
            end
            currentLine = word
        end
    end
    if currentLine ~= "" then
        table.insert(wrappedText, currentLine)
    end
    
    return wrappedText
end

-- 3D text and bubble drawing function
function DrawText3D(x, y, z, text)
    -- Word wrap the text
    local maxCharsPerLine = 30
    local lines = WordWrap(text, maxCharsPerLine)
    local lineHeight = 0.1
    
    -- Adjust this value to lower the text (increase negative value to move down)
    local heightOffset = 0 
    
    -- Draw each line of text
    for i, line in ipairs(lines) do
        local textZ = z + heightOffset + (lineHeight * (i - 1))
        DrawText3DLine(x, y, textZ, line)
    end
end

-- Draw a single line of text with better visibility
function DrawText3DLine(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.25, 0.25) -- Increased size for better visibility
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255) -- Full opacity
        SetTextEntry("STRING")
        SetTextCentre(1)
        SetTextDropshadow(1, 0, 0, 0, 255) -- Added drop shadow for visibility
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end
