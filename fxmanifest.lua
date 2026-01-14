fx_version 'adamant'

game 'gta5'

description 'Lazic Admin System + Report System + Admin Tag'
lua54 'yes'
version '1.0.2'
legacyversion '1.9.1'

server_script {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua'
}	

client_script {
	'client/*.lua'
}

shared_scripts {
	'config.lua',
	'@es_extended/imports.lua',
	'@ox_lib/init.lua'
}

ui_page "html/ui.html"

files {
	"html/ui.html",
	"html/script.js",
	"html/main.css"
}