fx_version 'cerulean'
game 'gta5'

name "Vehicle Speed Limit"
description "A vehicle speed limit system that prevents vehicles from exceeding 175 mph."
author "wavygandalf / skeezle"
version "1.0.0"

lua54 'yes'

server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'

client_scripts {
    'config.lua',
    'client.lua',
}
