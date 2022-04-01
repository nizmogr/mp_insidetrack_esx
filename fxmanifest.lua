fx_version 'cerulean'
game 'gta5'

shared_script 'config.lua'

client_scripts {
    'client/utils.lua',
    'client/presets.lua',
    'client/client.lua',
    'client/bigScreen.lua',
    'client/screens/*.lua',
}

server_scripts {
    'server/server.lua',
}