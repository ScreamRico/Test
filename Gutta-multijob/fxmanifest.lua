fx_version 'cerulean'
game 'gta5'

name 'ef-multijob'
author 'you'
description 'Multi-job UI for qb-core + ox_lib'
version '1.2.0'

lua54 'yes'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- optional, safe to keep
    'server.lua',
}

dependencies {
    'qb-core',
    'ox_lib'
}
