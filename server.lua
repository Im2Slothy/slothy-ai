QBCore = exports['qb-core']:GetCoreObject()
local GROK_API_KEY = Config.APIKey

RegisterServerEvent('slothyAI:askQuestion')
AddEventHandler('slothyAI:askQuestion', function(question)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Prepare the API request data
    local requestData = json.encode({
        model = "grok-2-latest",
        messages = {
            {
                role = "system",
                content = "You're an answer person that works on the side of the road. You answer questions for people, be 100% honest with your answers."
            },
            {
                role = "user",
                content = question
            }
        },
        max_tokens = 150,
        stream = false,
        temperature = 0
    })

    -- Make the API call
    PerformHttpRequest(
        "https://api.x.ai/v1/chat/completions",
        function(statusCode, response, headers)
            if statusCode == 200 then
                local responseData = json.decode(response)
                if responseData and responseData.choices and responseData.choices[1] then
                    local answer = responseData.choices[1].message.content:match("^%s*(.-)%s*$") -- Trim whitespace
                    TriggerClientEvent('slothyAI:showResponse', src, answer)
                else
                    TriggerClientEvent('slothyAI:showResponse', src, "Error processing response")
                end
            else
                TriggerClientEvent('slothyAI:showResponse', src, "Sorry, I'm having technical difficulties")
                print("API request failed with status code: " .. statusCode)
            end
        end,
        "POST",
        requestData,
        {
            ["Authorization"] = "Bearer " .. GROK_API_KEY,
            ["Content-Type"] = "application/json"
        }
    )
end)
