fx_version "adamant" -- bodacious

game "gta5"

client_script {
    'config.lua',
    'client.lua'
}

server_script "@mysql-async/lib/MySQL.lua"

server_script {
    'config.lua',
    'server.lua'
}

ui_page('UI/index.html')

files {
    "UI/index.html",
    "UI/reset.css",
    "UI/main.css",
    "UI/jquery.js",
    "UI/index.js",
    "UI/hehe.js"
}