fx_version 'cerulean'
game 'gta5'

author 'Radin_Valkron'
description 'Advanced Job Management & Society System for ESX'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'configs/config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'ox_lib',
    'mysql-async',
    'essentialmode',
}
