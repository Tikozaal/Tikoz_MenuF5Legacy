ESX = exports["es_extended"]:getSharedObject()

local Tikozaal = {}
local PlayerData = {}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
     PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
	PlayerData.job = job  
	Citizen.Wait(5000) 
end)

Citizen.CreateThread(function()
    ESX.PlayerData = ESX.GetPlayerData()
    WeaponData = ESX.GetWeaponList()

    for i = 1, #WeaponData, 1 do
        if WeaponData[i].name == 'WEAPON_UNARMED' then
            WeaponData[i] = nil
        else
            WeaponData[i].hash = GetHashKey(WeaponData[i].name)
        end
    end

end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job2)
    ESX.PlayerData.job2 = job2
end)

RegisterNetEvent("Tikoz:Fmenu")
AddEventHandler("Tikoz:Fmenu", function(value, quantity)
	local weaponHash = GetHashKey(value)

	if HasPedGotWeapon(plyPed, weaponHash, false) and value ~= 'WEAPON_UNARMED' then
		AddAmmoToPed(plyPed, value, quantity)
	end
end)
function RefreshMoney()
    Citizen.CreateThread(function()
            ESX.Math.GroupDigits(ESX.PlayerData.money)
            ESX.Math.GroupDigits(ESX.PlayerData.accounts[1].money)
            ESX.Math.GroupDigits(ESX.PlayerData.accounts[2].money)
    end)
end
RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
	for i=1, #ESX.PlayerData.accounts, 1 do
		if ESX.PlayerData.accounts[i].name == account.name then
			ESX.PlayerData.accounts[i] = account
			break
		end
	end
end)

function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
    AddTextEntry(entryTitle, textEntry)
    DisplayOnscreenKeyboard(1, entryTitle, '', inputText, '', '', '', maxLength)
    blockinput = true
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        blockinput = false
        return result
    else
        Citizen.Wait(500)
        blockinput = false
        return nil
    end
end

Armes = {}

ESX.TriggerServerCallback('Tikoz:getOtherPlayerData', function(data)
	for i=1, #data.weapons, 1 do
		table.insert(Armes, {
			label    = ESX.GetWeaponLabel(data.weapons[i].name),
			value    = data.weapons[i].name,
			right    = data.weapons[i].ammo,
			itemType = 'item_weapon',
			amount   = data.weapons[i].ammo
		})
	end
end)

function factureetreprisetikoz()
    local amount = KeyboardInput("Entrer le montant", "Entrer le montant", "", 15)
    
    if not amount then
      ESX.ShowNotification('~r~Montant invalide')
    else
  
      local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
  
        if closestPlayer == -1 or closestDistance > 3.0 then
          ESX.ShowNotification('Pas de joueurs à ~b~proximité')
        else
          local playerPed = PlayerPedId()
  
            CreateThread(function()
              ClearPedTasks(playerPed)
              TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_'..ESX.PlayerData.job.name, "~b~"..ESX.PlayerData.job.label, amount)
              ESX.ShowNotification("Vous avez bien envoyer la ~b~facture")
            end)
        end
    end
end

function facturepersonelletikoz()
    local amount = KeyboardInput("Entrer le montant", "Entrer le montant", "", 15)
    
    if not amount then
      ESX.ShowNotification('~r~Montant invalide')
    else
  
      local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
  
        if closestPlayer == -1 or closestDistance > 3.0 then
          ESX.ShowNotification('Pas de joueurs à ~b~proximité')
        else
          local playerPed = PlayerPedId()
  
            Citizen.CreateThread(function()
           
              ClearPedTasks(playerPed)
              TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), PlayerPedId(), "~b~"..GetPlayerName(PlayerId()), amount)
              ESX.ShowNotification("Vous avez bien envoyer la ~b~facture")
            end)
        end
    end
end

menuf5 = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {0, 251, 255}, Title = "Sac à Dos"},
    Data = { currentMenu = "Menu", "Test"},
    Events = {
		onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()


            if btn.name == "Inventaire" then
                TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                ESX.PlayerData = ESX.GetPlayerData()
                menuf5.Menu["Inventaire"].b = {}
                for i=1, #ESX.PlayerData.inventory, 1 do
                    local count = ESX.PlayerData.inventory[i].count
                    if count >= 1 then 
                        table.insert(menuf5.Menu["Inventaire"].b, { name = ESX.PlayerData.inventory[i].label .. " ~b~x"..count,slidemax = {"Utiliser","Donner","Jeter"}})
                    end
                end
                OpenMenu('Inventaire')
            end

            if btn.slidename == "Utiliser" then
                for i=1, #ESX.PlayerData.inventory, 1 do
                    local count = ESX.PlayerData.inventory[i].count
                    if ESX.PlayerData.inventory[i].label .. " ~b~x"..count == btn.name and count > 0 then
                        if ESX.PlayerData.inventory[i].usable then
                            TriggerServerEvent('esx:useItem', ESX.PlayerData.inventory[i].name)
                        else
                            ESX.ShowNotification('Pas utilisable', ESX.PlayerData.inventory[i].label)
                        end
                    end 
                end
            end
            
                for i=1, #ESX.PlayerData.inventory, 1 do
                    local count = ESX.PlayerData.inventory[i].count
                    if btn.slidename == "Donner" and btn.name == ESX.PlayerData.inventory[i].label .. " ~b~x"..count then
                        local quantity = KeyboardInput("Montant", 'Montant', "", 8)
                        local count = ESX.PlayerData.inventory[i].count
                        if ESX.PlayerData.inventory[i].label .. " ~b~x"..count == btn.name and count > 0 then
                            local foundPlayers = false
                            Tikozaal.closestPlayer, Tikozaal.closestDistance = ESX.Game.GetClosestPlayer()
                            if Tikozaal.closestDistance ~= -1 and Tikozaal.closestDistance <= 3 then
                                foundPlayers = true
                            end
                            if foundPlayers == true then
                                local closestPed = GetPlayerPed(Tikozaal.closestPlayer)
                                if quantity ~= nil and count > 0 then
                                    local post = true
                                    quantity = tonumber(quantity)
                                    if type(quantity) == 'number' then
                                        quantity = ESX.Math.Round(quantity)
                            
                                        if quantity <= 0 then
                                            post = false
                                        end
                                    end
                                    TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(Tikozaal.closestPlayer), 'item_standard', ESX.PlayerData.inventory[i].name, quantity)
                                    TaskPlayAnim(PlayerPedId(), "mp_common", "givetake2_a", 2.0, 2.0, 1000, 51, 0, false, false, false)
                                else
                                    ESX.ShowNotification('Montant invalide')
                                end
                            else
                                ESX.ShowNotification('Aucun joueur à ~b~proximité')
                            end
                        end
                    end
            end
            
            for i=1, #ESX.PlayerData.inventory, 1 do
                local count = ESX.PlayerData.inventory[i].count
                if btn.slidename == "Jeter" and btn.name == ESX.PlayerData.inventory[i].label .. " ~b~x"..count then
                    local quantity = KeyboardInput("Montant", "Montant", "", 15)
                    
                    if ESX.PlayerData.inventory[i].label .. " ~b~x"..count == btn.name and count > 0 then
                        if not IsPedSittingInAnyVehicle(plyPed) then
                            if quantity ~= nil then
                                local post = true
                                quantity = tonumber(quantity)
                                if type(quantity) == 'number' then
                                    quantity = ESX.Math.Round(quantity)
                                    if quantity <= 0 then
                                        post = false
                                    end
                                end
                                TriggerServerEvent('esx:removeInventoryItem', 'item_standard', ESX.PlayerData.inventory[i].name, quantity)
                                TaskPlayAnim(PlayerPedId(), "random@domestic", "pickup_low", 2.0, 2.0, 1000, 51, 0, false, false, false)
                                CloseMenu()
                                Wait(100)
                                CreateMenu(menuf5)
                                Wait(100)
                                TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                                ESX.PlayerData = ESX.GetPlayerData()
                                menuf5.Menu["Inventaire"].b = {}
                                for i=1, #ESX.PlayerData.inventory, 1 do
                                    local count = ESX.PlayerData.inventory[i].count
                                    if count >= 1 then 
                                        table.insert(menuf5.Menu["Inventaire"].b, { name = ESX.PlayerData.inventory[i].label .. "  (".. count ..")"  ,slidemax = {"Utiliser","Donner","Jeter"}})
                                    end
                                end
                            else
                                ESX.ShowNotification('Montant invalide')
                            end
                        else
                            ESX.ShowNotification('Impossible de jeter %s dans un véhicule', ESX.PlayerData.inventory[i].label)
                        end
                     end
                end
            end
        
       
            if btn.name == "Vêtement" then
                OpenMenu("Vêtement")
            elseif btn.name == "Haut" then
                TriggerEvent('Tikoz:VetHaut')
            elseif btn.name == "Bas" then
                TriggerEvent('Tikoz:VetBas')
            elseif btn.name == "Chaussure" then
                TriggerEvent('Tikoz:VetChaussure')
            elseif btn.name == "Gilet" then

                local ped = PlayerPedId()
                RequestAnimDict("clothingtie")
                while not HasAnimDictLoaded("clothingtie") do 
                    Citizen.Wait(0) 
                end
                SetBlockingOfNonTemporaryEvents(ped, true)
                TaskPlayAnim(ped, "clothingtie", "try_tie_negative_a", 1.0,-1.0, 2000, 1, 1, true, true, true)
                Citizen.Wait(1000)
                ClearPedTasks(PlayerPedId())
                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin1)
                    TriggerEvent('skinchanger:getSkin', function(skin2)
                        if skin1.bproof_1 ~= skin2.bproof_1 then
                            TriggerEvent('skinchanger:loadClothes', skin2, {['bproof_1'] = skin1.bproof_1, ['bproof_2'] = skin1.bproof_2})
                        else
                            TriggerEvent('skinchanger:loadClothes', skin2, {['bproof_1'] = 0, ['bproof_2'] = 0})
                        end
                    end)
                end)

            elseif btn.slidenum == 1 and btn.name == "Accessoire" then
                local ped = PlayerPedId()
                RequestAnimDict("mp_masks@standard_car@ds@")
                while not HasAnimDictLoaded("mp_masks@standard_car@ds@") do 
                    Citizen.Wait(0) 
                end
                SetBlockingOfNonTemporaryEvents(ped, true)
                TaskPlayAnim(ped, "mp_masks@standard_car@ds@", "put_on_mask", 1.0,-1.0, 2000, 1, 1, true, true, true)
                Citizen.Wait(1000)
                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin1)
                    TriggerEvent('skinchanger:getSkin', function(skin2)
                        if skin1.mask_1 ~= skin2.mask_1 then
                            TriggerEvent('skinchanger:loadClothes', skin2, {['mask_1'] = skin1.mask_1, ['mask_2'] = skin1.mask_2});
                        else
                            TriggerEvent('skinchanger:loadClothes', skin2, {['mask_1'] = 0, ['mask_2'] = 0});
                        end
                    end)
                end)

            elseif btn.slidenum == 2 and btn.name == "Accessoire" then
                local ped = PlayerPedId()
                RequestAnimDict("clothingspecs")
                while not HasAnimDictLoaded("clothingspecs") do 
                    Citizen.Wait(0) 
                end
                SetBlockingOfNonTemporaryEvents(ped, true)
                TaskPlayAnim(ped, "clothingspecs", "take_off", 1.0,-1.0, 2000, 1, 1, true, true, true)
                Citizen.Wait(1000)
                ClearPedTasks(PlayerPedId());
                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin1)
                    TriggerEvent('skinchanger:getSkin', function(skin2)
                        if skin1.glasses_1 ~= skin2.glasses_1 then
                            TriggerEvent('skinchanger:loadClothes', skin2, {['glasses_1'] = skin1.glasses_1, ['glasses_2'] = skin1.glasses_2});
                        else
                            TriggerEvent('skinchanger:loadClothes', skin2, {['glasses_1'] = 0, ['glasses_2'] = 0});
                        end
                    end)    
                end)

            elseif btn.slidenum == 3 and btn.name == "Accessoire" then
                TriggerEvent('Tikoz:VetSac')
            end

            if btn.name == "Portefeuille" then
                TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                ESX.PlayerData = ESX.GetPlayerData()
                RefreshMoney()
                menuf5.Menu["Portefeuille"].b = {}

                -- Si vous êtes en legacy et que l'argent s'affiche pas dans le portefeuille, enlever les commentaires en dessous,
                -- et retiré les 3 lignes table.insert ( ligne : 330, 331, 332)

                for i = 1, #ESX.PlayerData.accounts, 1 do
                    if ESX.PlayerData.accounts[i].name == 'money' then
                        table.insert(menuf5.Menu["Portefeuille"].b, { name = "Liquide :  ~g~"..ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money).."$",slidemax = { "Donner", "Jeter" } })
    
                    end
    
                    if ESX.PlayerData.accounts[i].name == 'bank' then
                        table.insert(menuf5.Menu["Portefeuille"].b, { name = "Banque :  ~o~" ..ESX.PlayerData.accounts[i].money.."$",ask = "" , askX =  true}) 
                    end
    
                    if ESX.PlayerData.accounts[i].name == 'black_money' then
                        table.insert(menuf5.Menu["Portefeuille"].b, { name = "Argent sale : ~r~" ..ESX.PlayerData.accounts[i].money.."$", slidemax = { "Donner", "Jeter" } })

                    end
                end

                -- table.insert(menuf5.Menu["Portefeuille"].b, { name = "Liquide :  ~g~" .. ESX.Math.GroupDigits(ESX.PlayerData.money).."$",slidemax = { "Donner", "Jeter" } })
                -- table.insert(menuf5.Menu["Portefeuille"].b, { name = "Banque :  ~o~" .. ESX.Math.GroupDigits(ESX.PlayerData.accounts[1].money).."$",ask = "" , askX =  true}) 
                -- table.insert(menuf5.Menu["Portefeuille"].b, { name = "Argent sale : ~r~" .. ESX.Math.GroupDigits(ESX.PlayerData.accounts[2].money).."$", slidemax = { "Donner", "Jeter" } })

                table.insert(menuf5.Menu["Portefeuille"].b, { name = "", ask = "", askX = true})
                
                table.insert(menuf5.Menu["Portefeuille"].b, { name = "Carte d'indentité", slidemax = {"Regarder", "Montrer"}})
                table.insert(menuf5.Menu["Portefeuille"].b, { name = "Permis de conduire", slidemax = {"Regarder", "Montrer"}})
                table.insert(menuf5.Menu["Portefeuille"].b, { name = "Permis de port d'arme", slidemax = {"Regarder", "Montrer"}})
                
                table.insert(menuf5.Menu["Portefeuille"].b, { name = "", ask = "", askX = true})
                
                table.insert(menuf5.Menu["Portefeuille"].b, { name = "Métier : ~b~" .. ESX.PlayerData.job.label, ask = "~b~"..ESX.PlayerData.job.grade_label, askX = true})
                table.insert(menuf5.Menu["Portefeuille"].b, { name = "Organisation : ~r~" .. ESX.PlayerData.job2.label, ask = "~r~"..ESX.PlayerData.job2.grade_label, askX = true})

                OpenMenu("Portefeuille")
            end

            if btn.slidename == "Regarder" and btn.name == "Carte d'indentité" then
                TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))

            elseif btn.slidename == "Montrer" and btn.name == "Carte d'indentité" then
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestDistance ~= -1 and closestDistance <= 3.0 then
						TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer))
					else
						ESX.ShowNotification('Aucun joueur ~r~proche !')
					end
            
            elseif btn.slidename == "Regarder" and btn.name == "Permis de conduire" then
                TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'driver')

            elseif btn.slidename == "Montrer" and btn.name == "Permis de conduire" then
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestDistance ~= -1 and closestDistance <= 3.0 then
						TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), 'driver')
					else
						ESX.ShowNotification('Aucun joueur ~r~proche !')
					end

            elseif btn.slidename == "Regarder" and btn.name == "Permis de port d'arme" then
                TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'weapon')
            elseif btn.slidename == "Montrer" and btn.name == "Permis de port d'arme" then
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestDistance ~= -1 and closestDistance <= 3.0 then
						TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), 'weapon')
					else
						ESX.ShowNotification('Aucun joueur ~r~proche !')
					end
            end
            
            for i = 1, #ESX.PlayerData.accounts, 1 do

                if btn.slidename == "Donner" and btn.name == "Liquide :  ~g~"..ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money).."$" then       
                    if item == walletMoney then
                        local quantity = KeyboardInput("Montant", "Montant", "", 15)
                        if quantity ~= nil then
                            local post = true
                            quantity = tonumber(quantity)
                            if type(quantity) == 'number' then
                                quantity = ESX.Math.Round(quantity)
                                if quantity <= 0 then
                                    post = false
                                end
                            end
                            local foundPlayers = false
                            Tikozaal.closestPlayer, Tikozaal.closestDistance = ESX.Game.GetClosestPlayer()
                            if Tikozaal.closestDistance ~= -1 and Tikozaal.closestDistance <= 3 then
                                foundPlayers = true
                            end
                            if foundPlayers == true then
                                local closestPed = GetPlayerPed(Tikozaal.closestPlayer)
                                if not IsPedSittingInAnyVehicle(closestPed) then
                                    if post == true then
                                        if item == walletMoney then
                                            TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_account', ESX.PlayerData.accounts[i].name, quantity)

                                            TaskPlayAnim(PlayerPedId(), "mp_common", "givetake2_a", 2.0, 2.0, 1000, 51, 0, false, false, false)
                                            OpenMenu("Portefeuille")
                                        end
                                    else
                                        ESX.ShowNotification('amount_invalid')
                                    end
                                else
                                    ESX.ShowNotification('Impossible de donner %s dans un véhicule')
                                end
                            else
                                ESX.ShowNotification('Aucun joueur à ~b~proximité')
                            end
                        end
                    end
                    OpenMenu("Menu")
                end
            end

            for i = 1, #ESX.PlayerData.accounts, 1 do

                if btn.slidename == "Jeter" and btn.name == "Liquide :  ~g~"..ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money).."$" then 
                    local quantity = KeyboardInput("Montant", "Montant", "", 15)
                    if quantity ~= nil then
                        local post = true
                        quantity = tonumber(quantity)
                        if type(quantity) == 'number' then
                            quantity = ESX.Math.Round(quantity)
        
                            if quantity <= 0 then
                                post = false
                            end
                        end
                        if not IsPedSittingInAnyVehicle(plyPed) then
                            if post == true then
                                if item == walletMoney then
									TriggerServerEvent('esx:removeInventoryItem', 'item_account', ESX.PlayerData.accounts[i].name, quantity)
                                    OpenMenu("Portefeuille")
                                end
                            else
                                ESX.ShowNotification('Montant invalide')
                            end
                        else
                            if item == walletMoney then
                                ESX.ShowNotification('Impossible de jeter %s dans un véhicule')
                            end
                        end
                    end
                end
            end

            for i = 1, #ESX.PlayerData.accounts, 1 do

                if btn.slidename == "Donner" and btn.name == "Argent sale : ~r~" ..ESX.PlayerData.accounts[i].money.."$" then
                        local quantity = KeyboardInput("Montant", 'Montant', "", 15)
                        if quantity ~= nil then
                            local post = true
                            quantity = tonumber(quantity)
                            if type(quantity) == 'number' then
                                quantity = ESX.Math.Round(quantity)
                                if quantity <= 0 then
                                    post = false
                                end
                            end
                            local foundPlayers = false
                            Tikozaal.closestPlayer, Tikozaal.closestDistance = ESX.Game.GetClosestPlayer()
                            if Tikozaal.closestDistance ~= -1 and Tikozaal.closestDistance <= 3 then
                                foundPlayers = true
                            end
                            if foundPlayers == true then
                                local closestPed = GetPlayerPed(Tikozaal.closestPlayer)
                                if not IsPedSittingInAnyVehicle(closestPed) then
                                    if post == true then               
                                        if item == walletdirtyMoney then
                                            TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(Tikozaal.closestPlayer), 'item_account', 'black_money', quantity)
                                            TaskPlayAnim(GetPlayerPed(-1), "mp_common", "givetake2_a", 2.0, 2.0, 1000, 51, 0, false, false, false)
                                            CloseMenu()
                                        end
                                    else
                                        ESX.ShowNotification('Montant invalide')
                                    end
                                else
                                    ESX.ShowNotification('Impossible de donner %s dans un véhicule')
                                end
                            else
                                ESX.ShowNotification('Aucun joueur à proximité')
                            end
                        end
                    end
                end
                
                for i = 1, #ESX.PlayerData.accounts, 1 do

                    if btn.slidename == "Jeter" and btn.name == "Argent sale : ~r~" ..ESX.PlayerData.accounts[i].money.."$" then
                        local quantity = KeyboardInput("Montant", 'Montant', "", 15)
                        if quantity ~= nil then
                            local post = true
                            quantity = tonumber(quantity)
                            if type(quantity) == 'number' then
                                quantity = ESX.Math.Round(quantity)
                                if quantity <= 0 then
                                    post = false
                                end
                            end
                            if not IsPedSittingInAnyVehicle(plyPed) then
                                if post == true then
                                    if item == walletdirtyMoney then
                                        TriggerServerEvent('esx:removeInventoryItem', 'item_account', 'black_money', quantity)
                                        OpenMenu("Portefeuille")
                                    end
                                else
                                ESX.ShowNotification('Montant invalide')
                                end
                            else
                                if item == walletdirtyMoney then
                                    ESX.ShowNotification('Impossible de jeter depuis un véhicule', 'de l\'argent sale')
                                end
                            end
                        end
                    end
                end
            if btn.name == "Gestion d'entreprise" and ESX.PlayerData.job.grade_name == "boss" then
                menuf5.Menu["Gestion d'entreprise"].b = {}
                table.insert(menuf5.Menu["Gestion d'entreprise"].b, { name = "Recruter", ask = "", askX = true})   
                table.insert(menuf5.Menu["Gestion d'entreprise"].b, { name = "Promouvoir", ask = "", askX = true})
                table.insert(menuf5.Menu["Gestion d'entreprise"].b, { name = "Destituer" , ask = "", askX = true})
                table.insert(menuf5.Menu["Gestion d'entreprise"].b, { name = "Virer", ask = "", askX = true})
                Citizen.Wait(200)
                OpenMenu("Gestion d'entreprise")
            end
            
            if btn.name == "Recruter" then 
                if ESX.PlayerData.job.grade_name == 'boss'  then
                    Tikozaal.closestPlayer, Tikozaal.closestDistance = ESX.Game.GetClosestPlayer()
                    if Tikozaal.closestPlayer == -1 or Tikozaal.closestDistance > 3.0 then
                        ESX.ShowNotification('Aucun joueur à ~b~proximité')
                    else
                        TriggerServerEvent('Tikoz:RecruterF5', GetPlayerServerId(Tikozaal.closestPlayer), ESX.PlayerData.job.name, 0)
                    end
                else
                    ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                end
            elseif btn.name == "Promouvoir" then
                if ESX.PlayerData.job.grade_name == 'boss' then
                    Tikozaal.closestPlayer, Tikozaal.closestDistance = ESX.Game.GetClosestPlayer()
                    if Tikozaal.closestPlayer == -1 or Tikozaal.closestDistance > 3.0 then
                        ESX.ShowNotification('Aucun joueur à ~b~proximité')
                    else
                        TriggerServerEvent('Tikoz:PromotionF5', GetPlayerServerId(Tikozaal.closestPlayer))
                    end
                else
                    ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                end
            elseif btn.name == "Virer" then 
                if ESX.PlayerData.job.grade_name == 'boss' then
                    Tikozaal.closestPlayer, Tikozaal.closestDistance = ESX.Game.GetClosestPlayer()
                    if Tikozaal.closestPlayer == -1 or Tikozaal.closestDistance > 3.0 then
                        ESX.ShowNotification('Aucun joueur à ~b~proximité')
                    else
                        TriggerServerEvent('Tikoz:VirerF5', GetPlayerServerId(Tikozaal.closestPlayer))
                    end
                else
                    ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                end
            elseif btn.name == "Destituer" then 
                if ESX.PlayerData.job.grade_name == 'boss' then
                    Tikozaal.closestPlayer, Tikozaal.closestDistance = ESX.Game.GetClosestPlayer()
                    if Tikozaal.closestPlayer == -1 or Tikozaal.closestDistance > 3.0 then
                        ESX.ShowNotification('Aucun joueur à ~b~proximité')
                    else
                        TriggerServerEvent('Tikoz:RetrograderF5', GetPlayerServerId(Tikozaal.closestPlayer))
                    end
                else
                    ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                end
            end
            
            if btn.name == "Gestion gang" and ESX.PlayerData.job2.grade_name == "boss" then
                menuf5.Menu["Gestion gang"].b = {}
                table.insert(menuf5.Menu["Gestion gang"].b, { name = "~s~Recruter", ask = "", askX = true})   
                table.insert(menuf5.Menu["Gestion gang"].b, { name = "~s~Promouvoir", ask = "", askX = true})
                table.insert(menuf5.Menu["Gestion gang"].b, { name = "~s~Destituer" , ask = "", askX = true})
                table.insert(menuf5.Menu["Gestion gang"].b, { name = "~s~Virer", ask = "", askX = true})
                Citizen.Wait(200)
                OpenMenu("Gestion gang")
            end

            if btn.name == "~s~Recruter" then 
                if ESX.PlayerData.job2.grade_name == 'boss'  then
                    Tikozaal.closestPlayer, Tikozaal.closestDistance = ESX.Game.GetClosestPlayer()
                    if Tikozaal.closestPlayer == -1 or Tikozaal.closestDistance > 3.0 then
                        ESX.ShowNotification('Aucun joueur à ~b~proximité')
                    else
                        TriggerServerEvent('Tikoz:MenuGangRecruterF5', GetPlayerServerId(Tikozaal.closestPlayer), ESX.PlayerData.job2.name, 0)
                    end
                else
                    ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                end
            elseif btn.name == "~s~Promouvoir" then
                if ESX.PlayerData.job2.grade_name == 'boss' then
                    Tikozaal.closestPlayer, Tikozaal.closestDistance = ESX.Game.GetClosestPlayer()
                    if Tikozaal.closestPlayer == -1 or Tikozaal.closestDistance > 3.0 then
                        ESX.ShowNotification('Aucun joueur à ~b~proximité')
                    else
                        TriggerServerEvent('Tikoz:MenuGangPromotionF5', GetPlayerServerId(Tikozaal.closestPlayer))
                    end
                else
                    ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                end
            elseif btn.name == "~s~Virer" then 
                if ESX.PlayerData.job2.grade_name == 'boss' then
                    Tikozaal.closestPlayer, Tikozaal.closestDistance = ESX.Game.GetClosestPlayer()
                    if Tikozaal.closestPlayer == -1 or Tikozaal.closestDistance > 3.0 then
                        ESX.ShowNotification('Aucun joueur à ~b~proximité')
                    else
                        TriggerServerEvent('Tikoz:MenuGangVirerF5', GetPlayerServerId(Tikozaal.closestPlayer))
                    end
                else
                    ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                end
            elseif btn.name == "~s~Destituer" then 
                if ESX.PlayerData.job2.grade_name == 'boss' then
                    Tikozaal.closestPlayer, Tikozaal.closestDistance = ESX.Game.GetClosestPlayer()
                    if Tikozaal.closestPlayer == -1 or Tikozaal.closestDistance > 3.0 then
                        ESX.ShowNotification('Aucun joueur à ~b~proximité')
                    else
                        TriggerServerEvent('Tikoz:MenuGangRetrograderF5', GetPlayerServerId(Tikozaal.closestPlayer))
                    end
                else
                    ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                end
            end

            if btn.name == "Gestion arme" then
                TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                ESX.PlayerData = ESX.GetPlayerData()
                menuf5.Menu["Gestion arme"].b = {}
                    if #WeaponData > 0 then
                        for i = 1, #WeaponData, 1 do
                            if (HasPedGotWeapon(PlayerPedId(), WeaponData[i].hash, false)) then
                                local currentAmmo = GetAmmoInPedWeapon(PlayerPedId(), WeaponData[i].hash)
                                table.insert(menuf5.Menu["Gestion arme"].b, { name = WeaponData[i].label.."~b~ x"..currentAmmo, slidemax = {"Donner", "Jeter"}})
                            end
                        end
                    end
                OpenMenu('Gestion arme')
            end

            for i=1, #WeaponData, 1 do
                local currentAmmo = GetAmmoInPedWeapon(PlayerPedId(), WeaponData[i].hash)
                if btn.slidename == "Donner" and btn.name == WeaponData[i].label.."~b~ x"..currentAmmo then
                    
                    Tikozaal.closestPlayer, Tikozaal.closestDistance = ESX.Game.GetClosestPlayer()
					if Tikozaal.closestDistance ~= -1 and Tikozaal.closestDistance <= 3 then
				 		foundPlayers = true
					end
					if foundPlayers == true then
						local closestPed = GetPlayerPed(Tikozaal.closestPlayer)
						if not IsPedSittingInAnyVehicle(closestPed) then
							TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(Tikozaal.closestPlayer), 'item_weapon', WeaponData[i].name, currentAmmo)
							CloseMenu()
						else
							ESX.ShowNotification( 'Impossible de donner %s dans un véhicule', label)
						end
					else
						ESX.ShowNotification('Aucun joueur à proximité')
					end

                elseif btn.slidename == "Jeter" and btn.name == WeaponData[i].label.."~b~ x"..currentAmmo then
                    TriggerServerEvent('esx:removeInventoryItem', 'item_weapon', WeaponData[i].name)
                    OpenMenu("Menu")
                end
            end

            ESX.TriggerServerCallback(('Tikoz:getUsergroup'), function(group) 

                for i=1, #Listeadmin, 1 do
                    if group == Listeadmin[i] then
                        if btn.name == "Administration" then
                            OpenMenu("Administration") 
                        end
                    end
                end
            end, args)



            if btn.name == "Menu personnelle" then
                OpenMenu('Menu Perso')
            elseif btn.name == "Heal" then
                ExecuteCommand('heal')

            elseif btn.name == "Invincible" and btn.checkbox == true then
                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped, true)
                SetEntityInvincible(veh, true)
                SetEntityProofs(veh, true, true, true, true, true, true, 1, true)
                SetVehicleTyresCanBurst(veh, false)
                SetVehicleCanBreak(veh, false)
                SetVehicleCanBeVisiblyDamaged(veh, false)
                SetEntityCanBeDamaged(veh, false)
                SetVehicleExplodesOnHighExplosionDamage(veh, false)
            elseif btn.name == "Invincible" and btn.checkbox == false then
                local ped = PlayerPedId()
                

            elseif btn.name == "Give ~g~cash" then
                tik = KeyboardInput("Combien vous voulez ? ", "Combien vous voulez ?", "", 15)
                TriggerServerEvent("Tikoz:AdminGiveMoneyMenuF", tik)
            elseif btn.name == "Give ~r~argent sale" then
                local id = GetPlayerServerId(PlayerId())
                tik = KeyboardInput("Combien vous voulez ? ", "Combien vous voulez ?", "", 15)
                ExecuteCommand("giveaccountmoney "..id.." black_money "..tik)
            elseif btn.name == "Give ~o~argent banque" then
	            local id = GetPlayerServerId(PlayerId())
                tik = KeyboardInput("Combien vous voulez ? ", "Combien vous voulez ?", "", 15)
                ExecuteCommand("giveaccountmoney "..id.." bank "..tik)
            end

            if btn.name == "Liste des joueurs" then
                OpenMenu('Joueurs')
            end
        
            if btn.name == "Téléportation" then
                menuf5.Menu["Téléportation"].b = {}
                table.insert(menuf5.Menu["Téléportation"].b, {name = "Vous téléporté à :", slidemax = {"~b~Concessionnaire", "~b~Benny's", "~b~Police", "~b~Hôpital"}})
                table.insert(menuf5.Menu["Téléportation"].b, {name = "Vous téléporté sur le GPS", ask = "", askX = true})
                table.insert(menuf5.Menu["Téléportation"].b, {name = "Téléporté un joueur à moi", ask = "", askX = true})
                table.insert(menuf5.Menu["Téléportation"].b, {name = "Vous téléporté sur un joueur", ask = "", askX = true})
                
                OpenMenu('Téléportation')
            end
                
                if btn.slidename == "~b~Concessionnaire" and btn.name == "Vous téléporté à :" then
                    local ped = PlayerPedId()
                    SetEntityCoords(ped, -57.93, -1108.43, 25.44)
                elseif btn.slidename == "~b~Police" and btn.name == "Vous téléporté à :" then
                    local ped = PlayerPedId()
                    SetEntityCoords(ped, 427.87, -978.96, 29.71)
                elseif btn.slidename == "~b~Hôpital" and btn.name == "Vous téléporté à :" then
                    local ped = PlayerPedId()
                    SetEntityCoords(ped, 296.08, -578.27, 43.16)
                elseif btn.slidename == "~b~Benny's" and btn.name == "Vous téléporté à :" then
                    local ped = PlayerPedId()
                    SetEntityCoords(ped, -206.64, -1302.51, 30.24)
                end
                
            if btn.name == "Vous téléporté sur le GPS" then
                local blip_on_map = GetFirstBlipInfoId(8)
                if DoesBlipExist(blip_on_map) then
                    Citizen.CreateThread(function()
                        local blipCoords = GetBlipInfoIdCoord(blip_on_map)
                        local foundGround, zCoords, zPos = false, -500.0, 0.0
                        while not foundGround do
                            zCoords = zCoords + 10.0
                            RequestCollisionAtCoord(blipCoords.x, blipCoords.y, zCoords)
                            Citizen.Wait(0)
                            foundGround, zPos = GetGroundZFor_3dCoord(blipCoords.x, blipCoords.y, zCoords)
                            if not foundGround and zCoords >= 2000.0 then
                                foundGround = true
                            end
                        end
                        SetPedCoordsKeepVehicle(PlayerPedId(), blipCoords.x, blipCoords.y, zPos)
                    end)
                else
                end
            end
            if btn.name == "Téléporté un joueur à moi" then
                local id = KeyboardInput("Quel est l'id ? ", "Quel est l'id ? ", "", 5)
                ExecuteCommand('bring '..id)
            elseif btn.name == "Vous téléporté sur un joueur" then
                local id = KeyboardInput("Quel est l'id ? ", "Quel est l'id ? ", "", 5)
                ExecuteCommand('goto '..id)
            end
   
            if btn.name == "Vehicule" then
                OpenMenu('Vehicule')
            elseif btn.name == "Liste des véhicules" then
                OpenMenu("Liste des véhicules")
            elseif btn.name == "Couleur" then
                OpenMenu('Couleur')
            end
            
            if btn.name == "Véhicule invincible" and btn.checkbox == true then
                local ped = PlayerPedId()
                local tikozal = GetVehiclePedIsIn(ped, true)
                SetEntityInvincible(tikozal, true)

                print("coucou")
            end
            
            if btn.slidename == "8h" and btn.name == "Changé l'heure" then
                ExecuteCommand("time 8 0")
            elseif btn.slidename == "10h" and btn.name == "Changé l'heure" then
                ExecuteCommand("time 10 0")
            elseif btn.slidename == "12h" and btn.name == "Changé l'heure" then
                ExecuteCommand("time 12 0")
            elseif btn.slidename == "14h" and btn.name == "Changé l'heure" then
                ExecuteCommand("time 14 0")
            elseif btn.slidename == "16h" and btn.name == "Changé l'heure" then
                ExecuteCommand("time 16 0")
            elseif btn.slidename == "18h" and btn.name == "Changé l'heure" then
                ExecuteCommand("time 18 0")
            elseif btn.slidename == "20h" and btn.name == "Changé l'heure" then
                ExecuteCommand("time 20 0")
            elseif btn.slidename == "22h" and btn.name == "Changé l'heure" then
                ExecuteCommand("time 22 0")
            elseif btn.slidename == "Minuit" and btn.name == "Changé l'heure" then
                ExecuteCommand("time 0 0")

            elseif btn.slidename == "Soleil" and btn.name == "Changé le temps" then
                ExecuteCommand('weather extrasunny')
            elseif btn.slidename == "Pluie" and btn.name == "Changé le temps" then
                ExecuteCommand('weather rain')
            elseif btn.slidename == "Neige" and btn.name == "Changé le temps" then
                ExecuteCommand('weather xmas')
            elseif btn.slidename == "Orage" and btn.name == "Changé le temps" then
                ExecuteCommand('weather thunder')

            elseif btn.name == "Freeze l'heure" then
                ExecuteCommand('freezetime')
            elseif btn.name == "Freeze le temps" then
                ExecuteCommand("freezeweather")
            end
            


            if btn.name == "Météo" then
                OpenMenu('Météo')
            end

            if btn.name == "Supprimé le véhicule" then
                ExecuteCommand("dv")
            end


            if btn.name == "Réparé" then
                local ped = PlayerPedId()
                local tikozal = GetVehiclePedIsIn(ped, false)
                SetVehicleFixed(tikozal)
                SetVehicleDirtLevel(tikozal, 0.0)
            elseif btn.name == "Noir" then
                local ped = PlayerPedId()
                local tikozal = GetVehiclePedIsIn(ped, lastVehicle)
                SetVehicleColours(tikozal, 0, 0)
            elseif btn.name == "Blanc" then
                local ped = PlayerPedId()
                local tikozal = GetVehiclePedIsIn(ped, lastVehicle)
                SetVehicleColours(tikozal, 111, 111)
            elseif btn.name == "Gris" then
                local ped = PlayerPedId()
                local tikozal = GetVehiclePedIsIn(ped, lastVehicle)
                SetVehicleColours(tikozal, 13, 13)            
            elseif btn.name == "Bleu" then
                local ped = PlayerPedId()
                local tikozal = GetVehiclePedIsIn(ped, lastVehicle)
                SetVehicleColours(tikozal, 64, 64)
            elseif btn.name == "Rouge" then
                local ped = PlayerPedId()
                local tikozal = GetVehiclePedIsIn(ped, lastVehicle)
                SetVehicleColours(tikozal, 29, 29)
            elseif btn.name == "Vert" then
                local ped = PlayerPedId()
                local tikozal = GetVehiclePedIsIn(ped, lastVehicle)
                SetVehicleColours(tikozal, 92, 92)
            elseif btn.name == "Jaune" then
                local ped = PlayerPedId()
                local tikozal = GetVehiclePedIsIn(ped, lastVehicle)
                SetVehicleColours(tikozal, 89, 89)
            elseif btn.name == "Orange" then
                local ped = PlayerPedId()
                local tikozal = GetVehiclePedIsIn(ped, lastVehicle)
                SetVehicleColours(tikozal, 38, 38)
            elseif btn.name == "Rose" then
                local ped = PlayerPedId()
                local tikozal = GetVehiclePedIsIn(ped, lastVehicle)
                SetVehicleColours(tikozal, 135, 135)
            end
            
            ESX.TriggerServerCallback("Tikoz:AdminvehiculeMenuF", function(adminveh) 

                if btn.name == "Compacts" then
                    menuf5.Menu["Compacts"].b = {}
                    for i=1, #adminveh, 1 do
                        if adminveh[i].category == "compacts" then
                            table.insert(menuf5.Menu["Compacts"].b, { name = adminveh[i].name, ask = "", askX = true})
                        end
                    end
                    OpenMenu('Compacts')
                end
                
                if btn.name == "Coupés" then
                    menuf5.Menu["Coupés"].b = {}
                    for i=1, #adminveh, 1 do
                        if adminveh[i].category == "coupes" then
                            table.insert(menuf5.Menu["Coupés"].b, { name = adminveh[i].name, ask = "", askX = true})
                        end
                    end
                    OpenMenu('Coupés')
                end
            
                if btn.name == "Sedans" then
                    menuf5.Menu["Sedans"].b = {}
                    for i=1, #adminveh, 1 do
                        if adminveh[i].category == "sedans" then
                            table.insert(menuf5.Menu["Sedans"].b, { name = adminveh[i].name, ask = "", askX = true})
                        end
                    end
                    OpenMenu('Sedans')
                end

                if btn.name == "Sports" then
                    menuf5.Menu["Sports"].b = {}
                    for i=1, #adminveh, 1 do
                        if adminveh[i].category == "sports" then
                            table.insert(menuf5.Menu["Sports"].b, { name = adminveh[i].name, ask = "", askX = true})
                        end
                    end
                    OpenMenu('Sports')
                end
            
                if btn.name == "Sports Classics" then
                    menuf5.Menu["Sports Classics"].b = {}
                    for i=1, #adminveh, 1 do
                        if adminveh[i].category == "sportsclassics" then
                            table.insert(menuf5.Menu["Sports Classics"].b, { name = adminveh[i].name, ask = "", askX = true})
                        end
                    end
                    OpenMenu('Sports Classics')
                end
            
                if btn.name == "Super" then
                    menuf5.Menu["Super"].b = {}
                    for i=1, #adminveh, 1 do
                        if adminveh[i].category == "super" then
                            table.insert(menuf5.Menu["Super"].b, { name = adminveh[i].name, ask = "", askX = true})
                        end
                    end
                    OpenMenu('Super')
                end
            
                if btn.name == "Muscle" then
                    menuf5.Menu["Muscle"].b = {}
                    for i=1, #adminveh, 1 do
                        if adminveh[i].category == "muscle" then
                            table.insert(menuf5.Menu["Muscle"].b, { name = adminveh[i].name, ask = "", askX = true})
                        end
                    end
                    OpenMenu('Muscle')
                end
            
                if btn.name == "Off Road" then
                    menuf5.Menu["Off Road"].b = {}
                    for i=1, #adminveh, 1 do
                        if adminveh[i].category == "offroad" then
                            table.insert(menuf5.Menu["Off Road"].b, { name = adminveh[i].name, ask = "", askX = true})
                        end
                    end
                    OpenMenu('Off Road')
                end
            
                if btn.name == "SUV" then
                    menuf5.Menu["SUV"].b = {}
                    for i=1, #adminveh, 1 do
                        if adminveh[i].category == "suvs" then
                            table.insert(menuf5.Menu["SUV"].b, { name = adminveh[i].name, ask = "", askX = true})
                        end
                    end
                    OpenMenu('SUV')
                end
            
                if btn.name == "Vans" then
                    menuf5.Menu["Vans"].b = {}
                    for i=1, #adminveh, 1 do
                        if adminveh[i].category == "vans" then
                            table.insert(menuf5.Menu["Vans"].b, { name = adminveh[i].name, ask = "", askX = true})
                        end
                    end
                    OpenMenu('Vans')
                end
            
                if btn.name == "Moto" then
                    menuf5.Menu["Moto"].b = {}
                    for i=1, #adminveh, 1 do
                        if adminveh[i].category == "motorcycles" then
                            table.insert(menuf5.Menu["Moto"].b, { name = adminveh[i].name, ask = "", askX = true})
                        end
                    end
                    OpenMenu('Moto')
                end
            
                if btn.name == "Imports" then
                    menuf5.Menu["Imports"].b = {}
                    for i=1, #adminveh, 1 do
                        if adminveh[i].category == "imports" then
                            table.insert(menuf5.Menu["Imports"].b, { name = adminveh[i].name, ask = "", askX = true})
                        end
                    end
                    OpenMenu('Imports')
                end

                for i=1, #adminveh, 1 do 
                    if btn.name == adminveh[i].name then
                        local ped = PlayerPedId()
                        local pos = GetEntityCoords(ped)
                        local h = GetEntityHeading(ped)
                        local pa = adminveh[i].name
                        local pi = adminveh[i].label
                        local po = GetHashKey(pi)
                        RequestModel(po)
                        while not HasModelLoaded(po) do Citizen.Wait(0) end
                        local pipo = CreateVehicle(po, pos, h, true, false)
                        TaskWarpPedIntoVehicle(PlayerPedId(), pipo, -1)
                        SetVehRadioStation(pipo, 'OFF')
                        
                    end
                end

            end, args)

            if btn.name == "Setjob" then
                local player = GetPlayerServerId(PlayerId())
                local job = KeyboardInput("Nom du job", "Nom du job", "", 15)
                local grade = KeyboardInput("Quel grade ? ", "Quel grade ? ", "", 3)
                ExecuteCommand("setjob "..player.." "..job.." "..grade)
            elseif btn.name == "Setjob2" then
                local player = GetPlayerServerId(PlayerId())
                local job = KeyboardInput("Nom du job", "Nom du job", "", 15)
                local grade = KeyboardInput("Quel grade ? ", "Quel grade ? ", "", 3)
                ExecuteCommand("setjob2 "..player.." "..job.." "..grade)
            elseif btn.name == "Give item" then
                local player = GetPlayerServerId(PlayerId())
                local item = KeyboardInput("Nom de l'item", "Nom de l'item", "", 15)
                local count = KeyboardInput("Combien ? ", "Combien ? ", "", 3)
                ExecuteCommand("giveitem "..player.." "..item.." "..count)
            elseif btn.name == "Give arme" then
                table.insert(menuf5.Menu["Menu arme"].b, {name = "Give toutes les armes", ask = "", askX = true})
                table.insert(menuf5.Menu["Menu arme"].b, {name = "Retirer toutes les armes", ask = "", askX = true})
                table.insert(menuf5.Menu["Menu arme"].b, {name = "Arme de poing", ask = ">", askX = true})
                table.insert(menuf5.Menu["Menu arme"].b, {name = "Arme blanche", ask = ">", askX = true})
                table.insert(menuf5.Menu["Menu arme"].b, {name = "Mitraillette", ask = ">", askX = true})
                table.insert(menuf5.Menu["Menu arme"].b, {name = "Fusil à pompe", ask = ">", askX = true})
                table.insert(menuf5.Menu["Menu arme"].b, {name = "Fusil d'assault", ask = ">", askX = true})
                table.insert(menuf5.Menu["Menu arme"].b, {name = "Fusil mitrailleur", ask = ">", askX = true})
                table.insert(menuf5.Menu["Menu arme"].b, {name = "Sniper", ask = ">", askX = true})
                table.insert(menuf5.Menu["Menu arme"].b, {name = "Lanceur", ask = ">", askX = true})
                table.insert(menuf5.Menu["Menu arme"].b, {name = "Grenade", ask = ">", askX = true})
                table.insert(menuf5.Menu["Menu arme"].b, {name = "Accessoire", ask = ">", askX = true})
                OpenMenu("Menu arme")
            end

            if btn.name == "Arme de poing" then
                menuf5.Menu["Arme de poing"].b = {}
                for i=1, #listepistolet, 1 do
                        table.insert(menuf5.Menu["Arme de poing"].b, { name = listepistolet[i].name, ask = "", askX = true})
                end
                OpenMenu('Arme de poing')
            end

            if btn.name == "Mitraillette" then
                menuf5.Menu["Mitraillette"].b = {}
                for i=1, #listemitraillette, 1 do
                        table.insert(menuf5.Menu["Mitraillette"].b, { name = listemitraillette[i].name, ask = "", askX = true})
                end
                OpenMenu('Mitraillette')
            end
            
            if btn.name == "Fusil à pompe" then
                menuf5.Menu["Fusil à pompe"].b = {}
                for i=1, #listepompe, 1 do
                        table.insert(menuf5.Menu["Fusil à pompe"].b, { name = listepompe[i].name, ask = "", askX = true})
                end
                OpenMenu('Fusil à pompe')
            end

            if btn.name == "Fusil d'assault" then
                menuf5.Menu["Fusil d'assault"].b = {}
                for i=1, #listeassault, 1 do
                        table.insert(menuf5.Menu["Fusil d'assault"].b, { name = listeassault[i].name, ask = "", askX = true})
                end
                OpenMenu("Fusil d'assault")
            end

            if btn.name == "Fusil mitrailleur" then
                menuf5.Menu["Fusil mitrailleur"].b = {}
                for i=1, #listefusilmitrailleur, 1 do
                        table.insert(menuf5.Menu["Fusil mitrailleur"].b, { name = listefusilmitrailleur[i].name, ask = "", askX = true})
                end
                OpenMenu("Fusil mitrailleur")
            end

            if btn.name == "Sniper" then
                menuf5.Menu["Sniper"].b = {}
                for i=1, #listesniper, 1 do
                        table.insert(menuf5.Menu["Sniper"].b, { name = listesniper[i].name, ask = "", askX = true})
                end
                OpenMenu('Sniper')
            end

            if btn.name == "Lanceur" then
                menuf5.Menu["Lanceur"].b = {}
                for i=1, #listelanceur, 1 do
                        table.insert(menuf5.Menu["Lanceur"].b, { name = listelanceur[i].name, ask = "", askX = true})
                end
                OpenMenu('Lanceur')
            end

            if btn.name == "Grenade" then
                menuf5.Menu["Grenade"].b = {}
                for i=1, #listegrenade, 1 do
                        table.insert(menuf5.Menu["Grenade"].b, { name = listegrenade[i].name, ask = "", askX = true})
                end
                OpenMenu('Grenade')
            end

            if btn.name == "Arme blanche" then
                menuf5.Menu["Arme blanche"].b = {}
                for i=1, #listearmeblanche, 1 do
                        table.insert(menuf5.Menu["Arme blanche"].b, { name = listearmeblanche[i].name, ask = "", askX = true})
                end
                OpenMenu('Arme blanche')
            end  

            if btn.name == "Give toutes les armes" then
                TriggerServerEvent('Tikoz:GiveAllWeapon')
            elseif btn.name == "Retirer toutes les armes" then
                TriggerServerEvent('Tikoz:RemoveWeapon')
            end

            for i=1, #listepistolet, 1 do
                if btn.name == listepistolet[i].name then
                    label = listepistolet[i].label
                    name = listepistolet[i].name
                    TriggerServerEvent("Tikoz:AmmuAchatPistolet",label)

                end
            end

            for i=1, #listemitraillette, 1 do
                if btn.name == listemitraillette[i].name then
                    label = listemitraillette[i].label
                    name = listemitraillette[i].name
                    TriggerServerEvent("Tikoz:AmmuAchatMitraillette",label)

                end
            end
            
            for i=1, #listepompe, 1 do
                if btn.name == listepompe[i].name then
                    label = listepompe[i].label
                    name = listepompe[i].name
                    TriggerServerEvent("Tikoz:AmmuAchatPompe",label)

                end
            end

            for i=1, #listeassault, 1 do
                if btn.name == listeassault[i].name then
                    label = listeassault[i].label
                    name = listeassault[i].name
                    TriggerServerEvent("Tikoz:AmmuAchatAssault",label)

                end
            end

            for i=1, #listefusilmitrailleur, 1 do
                if btn.name == listefusilmitrailleur[i].name then
                    label = listefusilmitrailleur[i].label
                    name = listefusilmitrailleur[i].name
                    TriggerServerEvent("Tikoz:AmmuAchatMitrailleur",label)

                end
            end

            for i=1, #listesniper, 1 do
                if btn.name == listesniper[i].name then
                    label = listesniper[i].label
                    name = listesniper[i].name
                    TriggerServerEvent("Tikoz:AmmuAchatSniper",label)

                end
            end

            for i=1, #listelanceur, 1 do
                if btn.name == listelanceur[i].name then
                    label = listelanceur[i].label
                    name = listelanceur[i].name
                    TriggerServerEvent("Tikoz:AmmuAchatLanceur",label)
                end
            end

            for i=1, #listegrenade, 1 do
                if btn.name == listegrenade[i].name then
                    label = listegrenade[i].label
                    name = listegrenade[i].name
                    TriggerServerEvent("Tikoz:AmmuAchatGrenade",label)
                end
            end

            for i=1, #listearmeblanche, 1 do
                if btn.name == listearmeblanche[i].name then
                    label = listearmeblanche[i].label
                    name = listearmeblanche[i].name
                    TriggerServerEvent("Tikoz:AmmuAchatArmeBlanche",label)
                end
            end
            
            if btn.slidename == "Normal" and btn.name == "Puissance moteur" then
                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped, false)
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(ped, false), 0.0)
            elseif btn.slidename == "x2" and btn.name == "Puissance moteur" then
                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped, false)
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(ped, false), 60.0)
            elseif btn.slidename == "x4" and btn.name == "Puissance moteur" then
                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped, false)
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(ped, false), 90.0)
            elseif btn.slidename == "x8" and btn.name == "Puissance moteur" then
                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped, false)
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(ped, false), 120.0)
            elseif btn.slidename == "x16" and btn.name == "Puissance moteur" then
                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped, false)
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(ped, false), 250.0)
            end

            if btn.name == "Allumer/Éteindre le moteur" and btn.checkbox == false then
                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped, false)
                SetVehicleEngineOn(veh, true, false, true)
            elseif btn.name == "Allumer/Éteindre le moteur" and btn.checkbox == true then
                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped, false)
                SetVehicleEngineOn(veh, false, false, true)
            end

            if btn.name == "Ouvrir/Fermé" and btn.slidename == "Porte avant gauche" then
                if not tik then
                    tik = true
                    SetVehicleDoorOpen(GetVehiclePedIsIn(PlayerPedId()), 0, false, false)
                elseif tik then
                    tik = false
                    SetVehicleDoorShut(GetVehiclePedIsIn(PlayerPedId()), 0, true, true)
                end
            elseif btn.name == "Ouvrir/Fermé" and btn.slidename == "Porte avant droite" then
                if not tik then
                    tik = true
                    SetVehicleDoorOpen(GetVehiclePedIsIn(PlayerPedId()), 1, false, false)
                elseif tik then
                    tik = false
                    SetVehicleDoorShut(GetVehiclePedIsIn(PlayerPedId()), 1, true, true)
                end
            elseif btn.name == "Ouvrir/Fermé" and btn.slidename == "Porte arrière droite" then
                if not tik then
                    tik = true
                    SetVehicleDoorOpen(GetVehiclePedIsIn(PlayerPedId()), 3, false, false)
                elseif tik then
                    tik = false
                    SetVehicleDoorShut(GetVehiclePedIsIn(PlayerPedId()), 3, true, true)
                end
            elseif btn.name == "Ouvrir/Fermé" and btn.slidename == "Porte arrière gauche" then
                if not tik then
                    tik = true
                    SetVehicleDoorOpen(GetVehiclePedIsIn(PlayerPedId()), 2, false, false)
                elseif tik then
                    tik = false
                    SetVehicleDoorShut(GetVehiclePedIsIn(PlayerPedId()), 2, true, true)
                end
            elseif btn.name == "Ouvrir/Fermé" and btn.slidename == "Capot" then
                if not tik then
                    tik = true
                    SetVehicleDoorOpen(GetVehiclePedIsIn(PlayerPedId()), 4, false, false)
                elseif tik then
                    tik = false
                    SetVehicleDoorShut(GetVehiclePedIsIn(PlayerPedId()), 4, true, true)
                end
            elseif btn.name == "Ouvrir/Fermé" and btn.slidename == "Coffre" then
                if not tik then
                    tik = true
                    SetVehicleDoorOpen(GetVehiclePedIsIn(PlayerPedId()), 5, false, false)
                elseif tik then
                    tik = false
                    SetVehicleDoorShut(GetVehiclePedIsIn(PlayerPedId()), 5, true, true)
                end
            end
              
            ESX.TriggerServerCallback("Tikoz:facture", function(bills) 

                if btn.name == "Facture" then
                    OpenMenu('Facture') 
                elseif btn.name == "Faire une facture" then
                    OpenMenu("Faire une facture")
                elseif btn.name == "Mes factures" then      
                    menuf5.Menu["Mes factures"].b = {}
                    for i=1, #bills, 1 do
                        table.insert(menuf5.Menu["Mes factures"].b, { name = bills[i].label, ask = "~g~"..bills[i].amount.."$", askX = true})
                    end
                    OpenMenu("Mes factures")
                end

                for i=1, #bills, 1 do
                    if btn.name == bills[i].label then
                        ESX.TriggerServerCallback('esx_billing:payBill', function() 
                        end,bills[i].id)
                        return
                        OpenMenu("Facture")
                    end
                end

                if btn.name == "Facture ~b~personelle" then
                    facturepersonelletikoz()
                elseif btn.name == "Facture ~b~entreprise" then
                    factureetreprisetikoz()
                end
            end, args)

end,
},
    Menu = {
        ["Menu"] = {
            b = {
                {name = "Inventaire", ask = ">", askX = true},
                {name = "Portefeuille", ask = ">", askX = true},
                {name = "Facture", ask = ">", askX = true},
                {name = "Gestion arme", ask = ">", askX = true},
                {name = "Gestion véhicule", ask = ">", askX = true},
                {name = "Vêtement", ask = ">", askX = true},
                {name = "Gestion d'entreprise", ask = ">", askX = true},
                {name = "Gestion gang", ask = ">", askX = true},
                {name = "Administration", ask = ">", askX = true},
            }
        },
        ["Gestion arme"] = {
            b = {
            }
        },
        ["Facture"] = {
            b = {
                {name = "Faire une facture", ask = ">", askX = true},
                {name = "Mes factures", ask = ">", askX = true},
            }
        },
        ["Faire une facture"] = {
            b = {
                {name = "Facture ~b~personelle", ask = "", askX = true},
                {name = "Facture ~b~entreprise", ask = "", askX = true},
            }
        },
        ["Mes factures"] = {
            b = {
            }
        },
        ["gestion véhicule"] = {
            b = {
                {name = "Ouvrir/Fermé", slidemax = {"Porte avant gauche", "Porte avant droite", "Porte arrière gauche", "Porte arrière droite", "Capot", "Coffre"}},
                {name = "Allumer/Éteindre le moteur", checkbox = false},
            }
        },
        ["Gestion d'entreprise"] = {
            b = {
            }
        },
        ["Gestion gang"] = {
            b = {
            }
        },
        ["Inventaire"] = {
            b = {
            }
        },
        ["Portefeuille"] = {
            b = {
            }
        },
        ["Administration"] = {
            b = {
                {name = "Menu personnelle", ask = ">", askX = true},
                {name = "Téléportation", ask = ">", askX = true},
                {name = "Vehicule", ask = ">", askX = true},
                {name = "Météo", ask = ">", askX = true},
            }
        },
        ["Vêtement"] = {
            b = {
                {name = "Haut", ask = "", askX = true},
                {name = "Bas", ask = "", askX = true},
                {name = "Chaussure", ask = "", askX = true},
                {name = "Gilet", ask = "", askX = true},
                {name = "Accessoire", slidemax = {"Masque", "Lunette", "Sac"}}
            }
        },
        ["Menu Perso"] = {
            b = {
                {name = "Heal", ask = "", askX = true},
                {name = "Invincible", checkbox = false},
                {name = "", ask = "", askX = true},
                {name = "Setjob", ask = "", askX = true},
                {name = "Setjob2", ask = "", askX = true},
                {name = "Give item", ask = "", askX = true},
                {name = "Give arme", ask = "", askX = true},
                {name = "", ask = "", askX = true},
                {name = "Give ~g~cash", ask = "", askX = true},
                {name = "Give ~r~argent sale", ask = "", askX = true},
                {name = "Give ~o~argent banque", ask = "", askX = true},
            }
        },
        ["Joueurs"] = {
            b = {

            }
        },
        ["Téléportation"] = {
            b = {
                {name = "Vous téléporté sur le GPS", ask = "", askX = true},
                
            }
        },
        ["Menu arme"] = {
            b = { 
            }
        },
        ["Vehicule"] = {
            b = {
                {name = "Liste des véhicules", ask = ">", askX = true},
                {name = "Couleur", ask = ">", askX = true},
                {name = "Réparé", ask = "", askX = true},
                {name = "Puissance moteur", slidemax = {"Normal", "x2", "x4", "x8", "x16"}},
                {name = "Supprimé le véhicule", ask = "", askX = true},
            }
        },
        ["Liste des véhicules"] = {
            b = {
                {name = "Imports", ask = ">", askX = true},
                {name = "Compacts", ask = ">", askX = true},
                {name = "Coupés", ask = ">", askX = true},
                {name = "Sedans", ask = ">", askX = true},
                {name = "Sports", ask = ">", askX = true},
                {name = "Sports Classics", ask = ">", askX = true},
                {name = "Super", ask = ">", askX = true},
                {name = "Muscle", ask = ">", askX = true},
                {name = "Off Road", ask = ">", askX = true},
                {name = "SUV", ask = ">", askX = true},
                {name = "Vans", ask = ">", askX = true},
                {name = "Moto", ask = ">", askX = true},
            }
        },
        ["Couleur"] = {
            b = {
                {name = "Noir", ask = "", askX = true},
                {name = "Blanc", ask = "", askX = true},
                {name = "Gris", ask = "", askX = true},
                {name = "Bleu", ask = "", askX = true},
                {name = "Rouge", ask = "", askX = true},
                {name = "Vert", ask = "", askX = true},
                {name = "Jaune", ask = "", askX = true},
                {name = "Orange", ask = "", askX = true},
                {name = "Rose", ask = "", askX = true},

            }
        },
        ["Météo"] = {
            b = {
                {name = "Changé l'heure", slidemax = {"8h", "10h", "12h", "14h", "16h", "18h", "20h", "22h", "Minuit"}},
                {name = "Changé le temps", slidemax = {"Soleil", "Pluie", "Orage", "Neige"}},
                {name = "Freeze l'heure", ask = "", askX = true},
                {name = "Freeze le temps", ask = "", askX = true},
            }
        },
        ["Imports"] = {
            b = {
            }
        },
        ["Compacts"] = {
            b = {
            }
        },
        ["Coupés"] = {
            b = {
            }
        },
        ["Sedans"] = {
            b = {
            }
        },
        ["Sports"] = {
            b = {
            }
        },
        ["Sports Classics"] = {
            b = {
            }
        },
        ["Super"] = {
            b = {
            }
        },
        ["Muscle"] = {
            b = {
            }
        },
        ["Off Road"] = {
            b = {
            }
        },
        ["SUV"] = {
            b = {
            }
        },
        ["Vans"] = {
            b = {
            }
        },
        ["Moto"] = {
            b = {
            }
        },
        ["Arme de poing"] = {
            b = {
            }
        },
        ["Arme blanche"] = {
            b = {
            }
        },
        ["Mitraillette"] = {
            b = {
            }
        },
        ["Fusil à pompe"] = {
            b = {
            }
        },
        ["Fusil d'assault"] = {
            b = {
            }
        },
        ["Fusil mitrailleur"] = {
            b = {
            }
        },
        ["Sniper"] = {
            b = {
            }
        },
        ["Lanceur"] = {
            b = {
            }
        },
        ["Grenade"] = {
            b = {
            }
        },
    }
}


RegisterNetEvent('Tikoz:VetHaut')
AddEventHandler('Tikoz:VetHaut', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtie', 'try_tie_neutral_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())

            if skina.torso_1 ~= skinb.torso_1 then
                vethaut = true
                TriggerEvent('skinchanger:loadClothes', skinb, {['torso_1'] = skina.torso_1, ['torso_2'] = skina.torso_2, ['tshirt_1'] = skina.tshirt_1, ['tshirt_2'] = skina.tshirt_2, ['arms'] = skina.arms})
            else
                TriggerEvent('skinchanger:loadClothes', skinb, {['torso_1'] = 15, ['torso_2'] = 0, ['tshirt_1'] = 15, ['tshirt_2'] = 0, ['arms'] = 15})
                vethaut = false
            end
        end)
    end)
end)

RegisterNetEvent('Tikoz:VetBas')
AddEventHandler('Tikoz:VetBas', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtrousers', 'try_trousers_neutral_c'

            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())

            if skina.pants_1 ~= skinb.pants_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['pants_1'] = skina.pants_1, ['pants_2'] = skina.pants_2})
                vetbas = true
            else
                vetbas = false
                if skina.sex == 1 then
                    TriggerEvent('skinchanger:loadClothes', skinb, {['pants_1'] = 15, ['pants_2'] = 0})
                else
                    TriggerEvent('skinchanger:loadClothes', skinb, {['pants_1'] = 61, ['pants_2'] = 1})
                end
            end
        end)
    end)
end)

RegisterNetEvent('Tikoz:VetChaussure')
AddEventHandler('Tikoz:VetChaussure', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingshoes', 'try_shoes_positive_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())
            if skina.shoes_1 ~= skinb.shoes_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['shoes_1'] = skina.shoes_1, ['shoes_2'] = skina.shoes_2})
                vetch = true
            else
                vetch = false
                if skina.sex == 1 then
                    TriggerEvent('skinchanger:loadClothes', skinb, {['shoes_1'] = 35, ['shoes_2'] = 0})
                else
                    TriggerEvent('skinchanger:loadClothes', skinb, {['shoes_1'] = 34, ['shoes_2'] = 0})
                end
            end
        end)
    end)
end)

RegisterNetEvent('Tikoz:VetSac')
AddEventHandler('Tikoz:VetSac', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtie', 'try_tie_neutral_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())
            if skina.bags_1 ~= skinb.bags_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['bags_1'] = skina.bags_1, ['bags_2'] = skina.bags_2})
                vetsac = true
            else
                TriggerEvent('skinchanger:loadClothes', skinb, {['bags_1'] = 0, ['bags_2'] = 0})
                vetsac = false
            end
        end)
    end)
end)

RegisterCommand('Tikoz:OpenMenu', function()
    CreateMenu(menuf5)
end, false)
RegisterKeyMapping('Tikoz:OpenMenu', 'Menu Radial', 'keyboard', 'F5')

