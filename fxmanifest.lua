fx_version 'adamant'

game 'gta5'

description 'admin panel'
author 'Lazic and chyaro group'
lua54 'yes'
version '1.2.0'

server_script {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua'
}	

client_script {
	'client/*.lua'
}

shared_scripts {
	'shared/locale.lua',
	'locales/*.lua',
	'config.lua',
	'shared/utils.lua',
	'@es_extended/imports.lua',
	'@ox_lib/init.lua'
}

ui_page "html/ui.html"

files {
	"html/ui.html",
	"html/script.js",
	"html/main.css"
}
