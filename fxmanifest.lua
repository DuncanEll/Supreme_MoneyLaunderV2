  fx_version 'cerulean'
games { 'rdr3', 'gta5' }

author 'DuncanEll - (SUPREME)'
description 'supreme_moneylaunder'
version '1.0.1'

game 'gta5'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
	'config/config.lua'
}

server_scripts {
	'server/server.lua',
}

client_scripts {
	'client/client.lua',
}