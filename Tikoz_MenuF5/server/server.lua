ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('tikoz:playergroup', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer ~= nil then
		local playerGroup = xPlayer.getGroup()
        if playerGroup ~= nil then 
            cb(playerGroup)
        else
            cb(nil)
        end
	else
		cb(nil)
	end
end)

ESX.RegisterServerCallback('Tikoz:facture', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT * FROM billing WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		local bills = {}

		for i = 1, #result do
			bills[#bills + 1] = {
				id = result[i].id,
				label = result[i].label,
				amount = result[i].amount
			}
		end

		cb(bills)
	end)
end)


ESX.RegisterServerCallback('Tikoz:getOtherPlayerData', function(source, cb, target, notify)
	local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)


    if xPlayer then
        local data = {
            name = xPlayer.getName(),
            job = xPlayer.job.label,
            grade = xPlayer.job.grade_label,
            inventory = xPlayer.getInventory(),
            accounts = xPlayer.getAccounts(),
            weapons = xPlayer.getLoadout(),
			--argentpropre = xPlayer.getMoney()
        }

        cb(data)
    end
end)

RegisterServerEvent('Tikoz:RecruterF5')
AddEventHandler('Tikoz:RecruterF5', function(target, job, grade)
	local _source = source
	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	targetXPlayer.setJob(job, grade)
	TriggerClientEvent('esx:showNotification', _source, "Vous avez ~g~recruté " .. targetXPlayer.name .. "~w~.")
	TriggerClientEvent('esx:showNotification', target, "Vous avez été ~g~embauché par " .. sourceXPlayer.name .. "~w~.")
end)

RegisterServerEvent('Tikoz:PromotionF5')
AddEventHandler('Tikoz:PromotionF5', function(target)
	local _source = source

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if (targetXPlayer.job.grade == 3) then
		TriggerClientEvent('esx:showNotification', _source, "Vous ne pouvez pas plus ~b~promouvoir~w~ d'avantage.")
	else
		if (sourceXPlayer.job.name == targetXPlayer.job.name) then
			local grade = tonumber(targetXPlayer.job.grade) + 1
			local job = targetXPlayer.job.name

			targetXPlayer.setJob(job, grade)

			TriggerClientEvent('esx:showNotification', _source, "Vous avez ~b~promu " .. targetXPlayer.name .. "~w~.")
			TriggerClientEvent('esx:showNotification', target, "Vous avez été ~b~promu~s~ par " .. sourceXPlayer.name .. "~w~.")
		end
	end
end)


RegisterServerEvent('Tikoz:RetrograderF5')
AddEventHandler('Tikoz:RetrograderF5', function(target)
	local _source = source

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if (targetXPlayer.job.grade == 0) then
		TriggerClientEvent('esx:showNotification', _source, "Vous ne pouvez pas plus ~r~rétrograder~w~ d'avantage.")
	else
		if (sourceXPlayer.job.name == targetXPlayer.job.name) then
			local grade = tonumber(targetXPlayer.job.grade) - 1
			local job = targetXPlayer.job.name

			targetXPlayer.setJob(job, grade)

			TriggerClientEvent('esx:showNotification', _source, "Vous avez ~r~rétrogradé " .. targetXPlayer.name .. "~w~.")
			TriggerClientEvent('esx:showNotification', target, "Vous avez été ~r~rétrogradé par " .. sourceXPlayer.name .. "~w~.")
		else
			TriggerClientEvent('esx:showNotification', _source, "Vous n'avez pas ~r~l'autorisation~w~.")
		end
	end
end)

RegisterServerEvent('Tikoz:VirerF5')
AddEventHandler('Tikoz:VirerF5', function(target)
	local _source = source
	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	local job = "unemployed"
	local grade = "0"
	if (sourceXPlayer.job.name == targetXPlayer.job.name) then
		targetXPlayer.setJob(job, grade)
		TriggerClientEvent('esx:showNotification', _source, "Vous avez ~r~viré " .. targetXPlayer.name .. "~w~.")
		TriggerClientEvent('esx:showNotification', target, "Vous avez été ~g~viré par " .. sourceXPlayer.name .. "~w~.")
	else
		TriggerClientEvent('esx:showNotification', _source, "Vous n'avez pas ~r~l'autorisation~w~.")
	end
end)

RegisterServerEvent('Tikoz:MenuGangRecruterF5')
AddEventHandler('Tikoz:MenuGangRecruterF5', function(target, job, grade)
	local _source = source
	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	targetXPlayer.setJob2(job, grade)
	TriggerClientEvent('esx:showNotification', _source, "Vous avez ~g~recruté " .. targetXPlayer.name .. "~w~.")
	TriggerClientEvent('esx:showNotification', target, "Vous avez été ~g~embauché par " .. sourceXPlayer.name .. "~w~.")
end)

RegisterServerEvent('Tikoz:MenuGangPromotionF5')
AddEventHandler('Tikoz:MenuGangPromotionF5', function(target)
	local _source = source

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if (targetXPlayer.job2.grade == 3) then
		TriggerClientEvent('esx:showNotification', _source, "Vous ne pouvez pas plus ~b~promouvoir~w~ d'avantage.")
	else
		if (sourceXPlayer.job2.name == targetXPlayer.job2.name) then
			local grade = tonumber(targetXPlayer.job2.grade) + 1
			local job = targetXPlayer.job2.name

			targetXPlayer.setJob2(job, grade)

			TriggerClientEvent('esx:showNotification', _source, "Vous avez ~b~promu " .. targetXPlayer.name .. "~w~.")
			TriggerClientEvent('esx:showNotification', target, "Vous avez été ~b~promu~s~ par " .. sourceXPlayer.name .. "~w~.")
		end
	end
end)


RegisterServerEvent('Tikoz:MenuGangRetrograderF5')
AddEventHandler('Tikoz:MenuGangRetrograderF5', function(target)
	local _source = source

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if (targetXPlayer.job2.grade == 0) then
		TriggerClientEvent('esx:showNotification', _source, "Vous ne pouvez pas plus ~r~rétrograder~w~ d'avantage.")
	else
		if (sourceXPlayer.job2.name == targetXPlayer.job2.name) then
			local grade = tonumber(targetXPlayer.job2.grade) - 1
			local job = targetXPlayer.job2.name

			targetXPlayer.setJob2(job, grade)

			TriggerClientEvent('esx:showNotification', _source, "Vous avez ~r~rétrogradé " .. targetXPlayer.name .. "~w~.")
			TriggerClientEvent('esx:showNotification', target, "Vous avez été ~r~rétrogradé par " .. sourceXPlayer.name .. "~w~.")
		else
			TriggerClientEvent('esx:showNotification', _source, "Vous n'avez pas ~r~l'autorisation~w~.")
		end
	end
end)

RegisterServerEvent('Tikoz:MenuGangVirerF5')
AddEventHandler('Tikoz:MenuGangVirerF5', function(target)
	local _source = source
	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	local job = "unemployed"
	local grade = "0"
	if (sourceXPlayer.job2.name == targetXPlayer.job2.name) then
		targetXPlayer.setJob2(job, grade)
		TriggerClientEvent('esx:showNotification', _source, "Vous avez ~r~viré " .. targetXPlayer.name .. "~w~.")
		TriggerClientEvent('esx:showNotification', target, "Vous avez été ~g~viré par " .. sourceXPlayer.name .. "~w~.")
	else
		TriggerClientEvent('esx:showNotification', _source, "Vous n'avez pas ~r~l'autorisation~w~.")
	end
end)

-------------- ADMINISTRATION ----------------------


ESX.RegisterServerCallback('Tikoz:getUsergroup', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local group = xPlayer.getGroup()
	cb(group)
end)

ESX.RegisterServerCallback('Tikoz:AdminvehiculeMenuF', function(source, cb)

    local xPlayer = ESX.GetPlayerFromId(source)
    local adminveh = {}

    MySQL.Async.fetchAll('SELECT * FROM tikoz_adminvehicule', {

    }, function(result)

        for i=1, #result, 1 do

            table.insert(adminveh, {
                name = result[i].name,
                label = result[i].label,
                category = result[i].category,
            })

        end

        cb(adminveh)
    
    end)

end)


RegisterNetEvent('Tikoz:AdminGiveMoneyMenuF')
AddEventHandler('Tikoz:AdminGiveMoneyMenuF', function(tik)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.addMoney(tik)
end)


RegisterServerEvent("Tikoz:AmmuAchatPistolet")
AddEventHandler("Tikoz:AmmuAchatPistolet", function(label)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

    
	xPlayer.addWeapon(label, 250)
	
		
end)

RegisterServerEvent("Tikoz:AmmuAchatMitraillette")
AddEventHandler("Tikoz:AmmuAchatMitraillette", function(label)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

    
	xPlayer.addWeapon(label, 250)
		
end)

RegisterServerEvent("Tikoz:AmmuAchatPompe")
AddEventHandler("Tikoz:AmmuAchatPompe", function(label)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

    
	xPlayer.addWeapon(label, 250)
		
end)

RegisterServerEvent("Tikoz:AmmuAchatAssault")
AddEventHandler("Tikoz:AmmuAchatAssault", function(label)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

    
	xPlayer.addWeapon(label, 250)
		
end)

RegisterServerEvent("Tikoz:AmmuAchatMitrailleur")
AddEventHandler("Tikoz:AmmuAchatMitrailleur", function(label)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.addWeapon(label, 250)
		
end)

RegisterServerEvent("Tikoz:AmmuAchatSniper")
AddEventHandler("Tikoz:AmmuAchatSniper", function(label)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.addWeapon(label, 250)
		
end)

RegisterServerEvent("Tikoz:AmmuAchatLanceur")
AddEventHandler("Tikoz:AmmuAchatLanceur", function(label)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

    xPlayer.addWeapon(label, 250)
		
end)

RegisterServerEvent("Tikoz:AmmuAchatGrenade")
AddEventHandler("Tikoz:AmmuAchatGrenade", function(label)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

    xPlayer.addWeapon(label, 250)
		
end)

RegisterServerEvent("Tikoz:AmmuAchatArmeBlanche")
AddEventHandler("Tikoz:AmmuAchatArmeBlanche", function(label)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

    xPlayer.addWeapon(label, 250)
		
end)

RegisterServerEvent("Tikoz:GiveAllWeapon") ----- La partie fun du F5 (:
AddEventHandler("Tikoz:GiveAllWeapon", function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

    xPlayer.addWeapon("weapon_dagger", 1)
	xPlayer.addWeapon("weapon_bat", 1)
    xPlayer.addWeapon("weapon_bottle", 1)
    xPlayer.addWeapon("weapon_crowbar", 1)
    xPlayer.addWeapon("weapon_flashlight", 1)
    xPlayer.addWeapon("weapon_golfclub", 1)
    xPlayer.addWeapon("weapon_hammer", 1)
    xPlayer.addWeapon("weapon_hatchet", 1)
    xPlayer.addWeapon("weapon_knuckle", 1)
    xPlayer.addWeapon("weapon_knife", 1)
    xPlayer.addWeapon("weapon_machete", 1)
    xPlayer.addWeapon("weapon_switchblade", 1)
    xPlayer.addWeapon("weapon_nightstick", 1)
    xPlayer.addWeapon("weapon_wrench", 1)
    xPlayer.addWeapon("weapon_battleaxe", 1)
    xPlayer.addWeapon("weapon_poolcue", 1)
    xPlayer.addWeapon("weapon_stone_hatchet", 1)
    xPlayer.addWeapon("weapon_pistol", 255)
	xPlayer.addWeapon("weapon_pistol_mk2", 255)
    xPlayer.addWeapon("weapon_combatpistol", 255)
    xPlayer.addWeapon("weapon_appistol", 255)
    xPlayer.addWeapon("weapon_stungun", 255)
    xPlayer.addWeapon("weapon_pistol50", 255)
    xPlayer.addWeapon("weapon_snspistol", 255)
    xPlayer.addWeapon("weapon_snspistol_mk2", 255)
    xPlayer.addWeapon("weapon_heavypistol", 255)
    xPlayer.addWeapon("weapon_vintagepistol", 255)
    xPlayer.addWeapon("weapon_flaregun", 255)
    xPlayer.addWeapon("weapon_marksmanpistol", 255)
    xPlayer.addWeapon("weapon_revolver", 255)
    xPlayer.addWeapon("weapon_revolver_mk2", 255)
    xPlayer.addWeapon("weapon_doubleaction", 255)
    xPlayer.addWeapon("weapon_raypistol", 255)
    xPlayer.addWeapon("weapon_ceramicpistol", 255)
    xPlayer.addWeapon("weapon_navyrevolver", 255)
    xPlayer.addWeapon("weapon_gadgetpistol", 255)
    xPlayer.addWeapon("weapon_stungun_mp", 255)
    xPlayer.addWeapon("weapon_microsmg", 255)
    xPlayer.addWeapon("weapon_smg", 255)
    xPlayer.addWeapon("weapon_smg_mk2", 255)
    xPlayer.addWeapon("weapon_assaultsmg", 255)
    xPlayer.addWeapon("weapon_combatpdw", 255)
    xPlayer.addWeapon("weapon_machinepistol", 255)
    xPlayer.addWeapon("weapon_minismg", 255)
    xPlayer.addWeapon("weapon_raycarbine", 255)
    xPlayer.addWeapon("weapon_pumpshotgun", 255)
    xPlayer.addWeapon("weapon_pumpshotgun_mk2", 255)
    xPlayer.addWeapon("weapon_sawnoffshotgun", 255)
    xPlayer.addWeapon("weapon_assaultshotgun", 255)
    xPlayer.addWeapon("weapon_bullpupshotgun", 255)
    xPlayer.addWeapon("weapon_musket", 255)
    xPlayer.addWeapon("weapon_heavyshotgun", 255)
    xPlayer.addWeapon("weapon_dbshotgun", 255)
    xPlayer.addWeapon("weapon_autoshotgun", 255)
    xPlayer.addWeapon("weapon_combatshotgun", 255)
    xPlayer.addWeapon("weapon_assaultrifle", 255)
    xPlayer.addWeapon("weapon_assaultrifle_mk2", 255)
    xPlayer.addWeapon("weapon_carbinerifle", 255)
    xPlayer.addWeapon("weapon_carbinerifle_mk2", 255)
    xPlayer.addWeapon("weapon_advancedrifle", 255)
    xPlayer.addWeapon("weapon_specialcarbine", 255)
    xPlayer.addWeapon("weapon_specialcarbine_mk2", 255)
    xPlayer.addWeapon("weapon_bullpuprifle", 255)
    xPlayer.addWeapon("weapon_bullpuprifle_mk2", 255)
    xPlayer.addWeapon("weapon_compactrifle", 255)
    xPlayer.addWeapon("weapon_militaryrifle", 255)
    xPlayer.addWeapon("weapon_heavyrifle", 255)
    xPlayer.addWeapon("weapon_tacticalrifle", 255)
    xPlayer.addWeapon("weapon_mg", 255)
    xPlayer.addWeapon("weapon_combatmg", 255)
    xPlayer.addWeapon("weapon_combatmg_mk2", 255)
    xPlayer.addWeapon("weapon_gusenberg", 255)
    xPlayer.addWeapon("weapon_sniperrifle", 255)
    xPlayer.addWeapon("weapon_heavysniper", 255)
    xPlayer.addWeapon("weapon_heavysniper_mk2", 255)
    xPlayer.addWeapon("weapon_marksmanrifle", 255)
    xPlayer.addWeapon("weapon_marksmanrifle_mk2", 255)
    xPlayer.addWeapon("weapon_precisionrifle", 255)
    xPlayer.addWeapon("weapon_rpg", 255)
    xPlayer.addWeapon("weapon_grenadelauncher", 255)
    xPlayer.addWeapon("weapon_grenadelauncher_smoke", 255)
    xPlayer.addWeapon("weapon_minigun", 255)
    xPlayer.addWeapon("weapon_firework", 255)
    xPlayer.addWeapon("weapon_railgun", 255)
    xPlayer.addWeapon("weapon_hominglauncher", 255)
    xPlayer.addWeapon("weapon_compactlauncher", 255)
    xPlayer.addWeapon("weapon_rayminigun", 255)
    xPlayer.addWeapon("weapon_emplauncher", 255)
    xPlayer.addWeapon("weapon_grenade", 255)
    xPlayer.addWeapon("weapon_bzgas", 255)
	xPlayer.addWeapon("weapon_molotov", 255)
    xPlayer.addWeapon("weapon_stickybomb", 255)
    xPlayer.addWeapon("weapon_proxmine", 255)
    xPlayer.addWeapon("weapon_snowball", 255)
    xPlayer.addWeapon("weapon_pipebomb", 255)
    xPlayer.addWeapon("weapon_ball", 255)
    xPlayer.addWeapon("weapon_smokegrenade", 255)
    xPlayer.addWeapon("weapon_flare", 255)
    xPlayer.addWeapon("weapon_petrolcan", 255)
    xPlayer.addWeapon("gadget_parachute", 255)
    xPlayer.addWeapon("weapon_fireextinguisher", 255)
    xPlayer.addWeapon("weapon_hazardcan", 255)
    xPlayer.addWeapon("weapon_fertilizercan", 255)	
end)

RegisterServerEvent("Tikoz:RemoveWeapon") ----- La partie fun du F5 (:
AddEventHandler("Tikoz:RemoveWeapon", function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

    xPlayer.removeWeapon("weapon_dagger", 1)
	xPlayer.removeWeapon("weapon_bat", 1)
    xPlayer.removeWeapon("weapon_bottle", 1)
    xPlayer.removeWeapon("weapon_crowbar", 1)
    xPlayer.removeWeapon("weapon_flashlight", 1)
    xPlayer.removeWeapon("weapon_golfclub", 1)
    xPlayer.removeWeapon("weapon_hammer", 1)
    xPlayer.removeWeapon("weapon_hatchet", 1)
    xPlayer.removeWeapon("weapon_knuckle", 1)
    xPlayer.removeWeapon("weapon_knife", 1)
    xPlayer.removeWeapon("weapon_machete", 1)
    xPlayer.removeWeapon("weapon_switchblade", 1)
    xPlayer.removeWeapon("weapon_nightstick", 1)
    xPlayer.removeWeapon("weapon_wrench", 1)
    xPlayer.removeWeapon("weapon_battleaxe", 1)
    xPlayer.removeWeapon("weapon_poolcue", 1)
    xPlayer.removeWeapon("weapon_stone_hatchet", 1)
    xPlayer.removeWeapon("weapon_pistol", 255)
	xPlayer.removeWeapon("weapon_pistol_mk2", 255)
    xPlayer.removeWeapon("weapon_combatpistol", 255)
    xPlayer.removeWeapon("weapon_appistol", 255)
    xPlayer.removeWeapon("weapon_stungun", 255)
    xPlayer.removeWeapon("weapon_pistol50", 255)
    xPlayer.removeWeapon("weapon_snspistol", 255)
    xPlayer.removeWeapon("weapon_snspistol_mk2", 255)
    xPlayer.removeWeapon("weapon_heavypistol", 255)
    xPlayer.removeWeapon("weapon_vintagepistol", 255)
    xPlayer.removeWeapon("weapon_flaregun", 255)
    xPlayer.removeWeapon("weapon_marksmanpistol", 255)
    xPlayer.removeWeapon("weapon_revolver", 255)
    xPlayer.removeWeapon("weapon_revolver_mk2", 255)
    xPlayer.removeWeapon("weapon_doubleaction", 255)
    xPlayer.removeWeapon("weapon_raypistol", 255)
    xPlayer.removeWeapon("weapon_ceramicpistol", 255)
    xPlayer.removeWeapon("weapon_navyrevolver", 255)
    xPlayer.removeWeapon("weapon_gadgetpistol", 255)
    xPlayer.removeWeapon("weapon_stungun_mp", 255)
    xPlayer.removeWeapon("weapon_microsmg", 255)
    xPlayer.removeWeapon("weapon_smg", 255)
    xPlayer.removeWeapon("weapon_smg_mk2", 255)
    xPlayer.removeWeapon("weapon_assaultsmg", 255)
    xPlayer.removeWeapon("weapon_combatpdw", 255)
    xPlayer.removeWeapon("weapon_machinepistol", 255)
    xPlayer.removeWeapon("weapon_minismg", 255)
    xPlayer.removeWeapon("weapon_raycarbine", 255)
    xPlayer.removeWeapon("weapon_pumpshotgun", 255)
    xPlayer.removeWeapon("weapon_pumpshotgun_mk2", 255)
    xPlayer.removeWeapon("weapon_sawnoffshotgun", 255)
    xPlayer.removeWeapon("weapon_assaultshotgun", 255)
    xPlayer.removeWeapon("weapon_bullpupshotgun", 255)
    xPlayer.removeWeapon("weapon_musket", 255)
    xPlayer.removeWeapon("weapon_heavyshotgun", 255)
    xPlayer.removeWeapon("weapon_dbshotgun", 255)
    xPlayer.removeWeapon("weapon_autoshotgun", 255)
    xPlayer.removeWeapon("weapon_combatshotgun", 255)
    xPlayer.removeWeapon("weapon_assaultrifle", 255)
    xPlayer.removeWeapon("weapon_assaultrifle_mk2", 255)
    xPlayer.removeWeapon("weapon_carbinerifle", 255)
    xPlayer.removeWeapon("weapon_carbinerifle_mk2", 255)
    xPlayer.removeWeapon("weapon_advancedrifle", 255)
    xPlayer.removeWeapon("weapon_specialcarbine", 255)
    xPlayer.removeWeapon("weapon_specialcarbine_mk2", 255)
    xPlayer.removeWeapon("weapon_bullpuprifle", 255)
    xPlayer.removeWeapon("weapon_bullpuprifle_mk2", 255)
    xPlayer.removeWeapon("weapon_compactrifle", 255)
    xPlayer.removeWeapon("weapon_militaryrifle", 255)
    xPlayer.removeWeapon("weapon_heavyrifle", 255)
    xPlayer.removeWeapon("weapon_tacticalrifle", 255)
    xPlayer.removeWeapon("weapon_mg", 255)
    xPlayer.removeWeapon("weapon_combatmg", 255)
    xPlayer.removeWeapon("weapon_combatmg_mk2", 255)
    xPlayer.removeWeapon("weapon_gusenberg", 255)
    xPlayer.removeWeapon("weapon_sniperrifle", 255)
    xPlayer.removeWeapon("weapon_heavysniper", 255)
    xPlayer.removeWeapon("weapon_heavysniper_mk2", 255)
    xPlayer.removeWeapon("weapon_marksmanrifle", 255)
    xPlayer.removeWeapon("weapon_marksmanrifle_mk2", 255)
    xPlayer.removeWeapon("weapon_precisionrifle", 255)
    xPlayer.removeWeapon("weapon_rpg", 255)
    xPlayer.removeWeapon("weapon_grenadelauncher", 255)
    xPlayer.removeWeapon("weapon_grenadelauncher_smoke", 255)
    xPlayer.removeWeapon("weapon_minigun", 255)
    xPlayer.removeWeapon("weapon_firework", 255)
    xPlayer.removeWeapon("weapon_railgun", 255)
    xPlayer.removeWeapon("weapon_hominglauncher", 255)
    xPlayer.removeWeapon("weapon_compactlauncher", 255)
    xPlayer.removeWeapon("weapon_rayminigun", 255)
    xPlayer.removeWeapon("weapon_emplauncher", 255)
    xPlayer.removeWeapon("weapon_grenade", 255)
    xPlayer.removeWeapon("weapon_bzgas", 255)
	xPlayer.removeWeapon("weapon_molotov", 255)
    xPlayer.removeWeapon("weapon_stickybomb", 255)
    xPlayer.removeWeapon("weapon_proxmine", 255)
    xPlayer.removeWeapon("weapon_snowball", 255)
    xPlayer.removeWeapon("weapon_pipebomb", 255)
    xPlayer.removeWeapon("weapon_ball", 255)
    xPlayer.removeWeapon("weapon_smokegrenade", 255)
    xPlayer.removeWeapon("weapon_flare", 255)
    xPlayer.removeWeapon("weapon_petrolcan", 255)
    xPlayer.removeWeapon("gadget_parachute", 255)
    xPlayer.removeWeapon("weapon_fireextinguisher", 255)
    xPlayer.removeWeapon("weapon_hazardcan", 255)
    xPlayer.removeWeapon("weapon_fertilizercan", 255)	
end)

