--FiveM Skydive Script
-- Version 1.0

version '1.0.0'
author 'Im2Slothy#0 & TonyVee#0'
description 'Talk to an AI in San Andreas'
repository 'https://github.com/Im2Slothy/FiveM-AI-ChatGPT-Conversation'

-- compatibility wrapper
fx_version 'adamant'
game 'common'

-- Add a client script 
client_script "client.lua"
client_script "server.lua"