local chatGPTEnabled = true
local aiPed = nil

-- Function to prompt the player to press a key when close to the AI
function PromptForQuestion()
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed)
    local aiPos = GetEntityCoords(aiPed)
    local distance = #(pos - aiPos)

    if distance < 3.0 then
        DrawText3D(aiPos.x, aiPos.y, aiPos.z + 2.0, "~b~Press E to ask a question", 0.5, 0)
        if IsControlJustReleased(0, 38) then -- 'E' key
            DisplayOnscreenKeyboard(true, "FMMC_KEY_TIP8", "", "", "", "", "", 128)
            while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
                Wait(0)
            end
            local question = GetOnscreenKeyboardResult()
            if question and question ~= "" then
                AskQuestion(question)
            end
        end
    end
end

-- Function to ask a question to ChatGPT and display the response
function AskQuestion(question)
    local response = GetChatGPTResponse(question)

    -- Display the response above the AI's head
    if response then
        local aiPos = GetEntityCoords(aiPed)
        DrawText3D(aiPos.x, aiPos.y, aiPos.z + 2.5, "~g~ChatGPT: " .. response, 0.5, 0)
    end
end

-- Function to send a question to ChatGPT and get a response
function GetChatGPTResponse(question)
    local apiKey = "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"
    local apiUrl = "https://api.openai.com/v1/chat/completions"

    local requestData = {
        model = "gpt-3.5-turbo",
        messages = {
            {
                role = "user",
                content = question,
            },
            {
                role = "system",
                content = "You are a personal assistant for a FiveM server called Slothy's Testing Server",
            }
        }
    }

    PerformHttpRequest(apiUrl, function(statusCode, response, headers)
        if statusCode == 200 then
            local responseData = json.decode(response)
            if responseData and responseData.choices then
                local answer = responseData.choices[1].message.content
                return answer
            else
                print("ChatGPT API request failed:", response)
                return nil
            end
        else
            print("ChatGPT API request failed. Status code:", statusCode)
            return nil
        end
    end, 'POST', json.encode(requestData), {
        ['Content-Type'] = 'application/json',
        ['Authorization'] = 'Bearer ' .. apiKey
    })
end

-- Main loop to check for player interaction
CreateThread(function()
    while true do
        Wait(0)
        if chatGPTEnabled then
            local playerPed = PlayerPedId()
            if IsPedOnFoot(playerPed) then
                PromptForQuestion()
            end
        end
    end
end)

-- Function to draw text in 3D
function DrawText3D(x, y, z, text, scale, font)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.0 * scale, 0.35 * scale)
        SetTextFont(font)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end
