fx_version('cerulean')
games({ 'gta5' })
shared_scripts {"@es_extended/imports.lua","config.lua"}
server_scripts({
    "@es_extended/locale.lua",
    '@mysql-async/lib/MySQL.lua',
    "server/server.lua"
});

client_scripts({
    "@es_extended/locale.lua",
    "dependencies/pmenu.lua",
    "client/client.lua"
});
