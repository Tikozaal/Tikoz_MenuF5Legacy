fx_version('cerulean')
games({ 'gta5' })

server_scripts({
    '@mysql-async/lib/MySQL.lua',
    "server/server.lua"
});

client_scripts({
    "dependencies/pmenu.lua",
    "config.lua",
    "client/client.lua"
});