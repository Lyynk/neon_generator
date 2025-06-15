fx_version 'cerulean'
game 'gta5'

lua54 'yes' -- Add this line

author 'Emmler'
description 'Daily Random Item Generator'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua',
    '@qbx_core/modules/playerdata.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'ox_lib',
    'ox_target',
    'ox_inventory'
}

files {
    'config.lua'
}
