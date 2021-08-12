local display = false
ESX				= nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterCommand(Config.UIOpener, function()
    -- MAİN WİRO
    TriggerEvent('BetterBank:CheckATM')
    -- MAİN WİRO
end)
--===============================================
--==          Banka Bliplerini ekler           ==
--===============================================
CreateThread(function()
    for k,v in pairs(Config.Banks) do
        v.blip = AddBlipForCoord(v.Location, v.Location, v.Location)
        SetBlipSprite(v.blip, v.id)
        SetBlipAsShortRange(v.blip, true)
	    BeginTextCommandSetBlipName("STRING")
        SetBlipColour(v.blip, 2)
        AddTextComponentString(v.name)
        EndTextCommandSetBlipName(v.blip)
    end
end)

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
        status = bool,
    })
end

Citizen.CreateThread(function()
    while display do
        Citizen.Wait(0)
        DisableControlAction(0, 1, display) -- LookLeftRight
        DisableControlAction(0, 2, display) -- LookUpDown
        DisableControlAction(0, 142, display) -- MeleeAttackAlternate
        DisableControlAction(0, 18, display) -- Enter
        DisableControlAction(0, 322, display) -- ESC
        DisableControlAction(0, 106, display) -- VehicleMouseControlOverride
    end
end)

CreateThread(function()
    while Config.openBankWithCom do
        Wait(1)
        if ESX ~= nil then
            local plyPed = PlayerPedId()
            local pos = GetEntityCoords(plyPed)

            for k,v in pairs(Config.Banks) do
                if (#(v.Location - pos) < 1) then
                    drawTxt(v.Location.x, v.Location.y, v.Location.z, "[E] Hesabına Eris")
                    if IsControlJustPressed(0, 38) then
                        MainBankOpener()
                    end
                elseif (#(v.Location - pos) < 4.5) then
                    drawTxt(v.Location.x, v.Location.y, v.Location.z, "Banka")
                end
            end
        end
    end
end)

RegisterNetEvent("BetterBank:CheckATM")
AddEventHandler("BetterBank:CheckATM", function()
    if PlayerNearATM() or nearBank() then
        MainBankOpener()
    end
end)

function PlayerNearATM()
    for i = 1, #Config.Atms do
        local obj = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 0.75, Config.Atms[i], 0, 0, 0)
        if DoesEntityExist(obj) then
            TaskTurnPedToFaceEntity(PlayerPedId(), obj, 3.0)
            TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_ATM", 0, true)
            return true
        end
    end
    TriggerEvent('wiro_notify:show', "error", Config.atmYokMSG, 3000)
    return false
end

function nearBank()
    if not Config.openBankWithCom then
        local player = PlayerPedId()
        local playerloc = GetEntityCoords(player, 0)

        for k,v in pairs(Config.Banks) do
            local distance = GetDistanceBetweenCoords(v.Location.x, v.Location.y, v.Location.z, playerloc['x'], playerloc['y'], playerloc['z'], true)
            if distance <= 3 then
                TaskPlayAnim(player, "anim@amb@prop_human_atm@interior@male@enter", "enter", 3.5, -8, -1, 2, 0, 0, 0, 0, 0)
                return true
            end
        end
        return false
    end
    return false
end

function drawTxt(x, y, z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

function MainBankOpener()
    --MAİN STARTER
    TriggerEvent('BetterBank:resetislem')
    TriggerServerEvent('BetterBank:balance')
    TriggerEvent('BetterBank:SonYirmiEkle')
    TriggerEvent('BetterBank:FaturalarEkle')
    SetDisplay(not display)
    --MAİN STARTER
end 

--===============================================
--==                 Events                    ==
--===============================================
RegisterNetEvent('currentbalance')
AddEventHandler('currentbalance', function(balance)
	local id = PlayerId()
    local playerName
    local IBAN

    ESX.TriggerServerCallback('BetterBank:GetNameAndIBAN', function(data)
        playerName = data.firstname .. ' ' .. data.lastname
        IBAN = data.IBAN
    end)

    Citizen.Wait(200)

	SendNUIMessage({
		type = "balance",
		balance = balance,
		player = playerName,
        IBAN = IBAN
	})
end)

RegisterNetEvent('BetterBank:AnlıkSonIslemEkle')
AddEventHandler('BetterBank:AnlıkSonIslemEkle', function(islem, miktar, neZaman, kimden, amount)
    if amount == nil or Config.anlikSonIslemEkleMin <= amount then
        SendNUIMessage({
            type = islem,
            ekle = true,
            miktar = tostring(miktar),
            neZaman = tostring(neZaman),
            kimden = kimden,
            animasyon = true
        })
    
    else 
        SendNUIMessage({
            type = islem,
            ekle = false,
            animasyon = true
        })
    end
end)

RegisterNetEvent('BetterBank:resetislem')
AddEventHandler('BetterBank:resetislem', function(islem, miktar, neZaman, kimden)
	SendNUIMessage({
		type = "reset"
	})
end)

RegisterNetEvent('BetterBank:SonYirmiEkle')
AddEventHandler('BetterBank:SonYirmiEkle', function()
    local islem = {}
    local neKadar = {}
    local neZaman = {}
    local kimden = {}

    local kackeredonsun = 5

    ESX.TriggerServerCallback('BetterBank:SonYirmiEklee', function(data)
        islem = data.islem
        neKadar = data.neKadar
        neZaman = data.neZaman
        kimden = data.kimden
        kackeredonsun = data.kackeredonsun
    end)
    
    Citizen.Wait(600)

    for i = 0,kackeredonsun,1 do
        SendNUIMessage({
            type = islem[i],
            ekle = true,
            miktar = neKadar[i],
            neZaman = neZaman[i],
            kimden = kimden[i]
        })
    end
end)

RegisterNetEvent('BetterBank:FaturalarEkle')
AddEventHandler('BetterBank:FaturalarEkle', function()
    local senderIBAN = {}
    local senderName = {}
    local label = {}
    local amount = {}
    local neZaman = {}

    local kackeredonsun = 5

    ESX.TriggerServerCallback('BetterBank:FaturalarEkleServer', function(data)
        senderIBAN = data.senderIBAN
        senderName = data.senderName
        label = data.label
        amount = data.amount
        neZaman = data.neZaman
        kackeredonsun = data.kackeredonsun - 1
    end)
    
    Citizen.Wait(600)

    

    for i = 0,kackeredonsun,1 do
        SendNUIMessage({
            type = "fatura",
            senderIBAN = senderIBAN[i],
            senderName = senderName[i],
            label = label[i],
            amount = amount[i],
            neZaman = neZaman[i]
        })
    end

end)

RegisterNetEvent('BetterBank:FaturaAnlikSil')
AddEventHandler('BetterBank:FaturaAnlikSil', function(tarih, label)

    print(tarih, label)

    SendNUIMessage({
        type = "faturaSil",
        tarih = tarih,
        label = label
    })

end)

RegisterNetEvent('BetterBank:HataMesaj')
AddEventHandler('BetterBank:HataMesaj', function()
    SendNUIMessage({
        type = "hata",
    })
end)

--===============================================
--==           NUI CALL BACKS                  ==
--===============================================
RegisterNUICallback('deposit', function(data)
	TriggerServerEvent('BetterBank:deposit', tonumber(data.amount), data.IBAN, data.islem ,data.neZaman, data.kimden, data.duzenlenmisAmount)
	TriggerServerEvent('BetterBank:balance')
end)

RegisterNUICallback('withdraw', function(data)
	TriggerServerEvent('BetterBank:withdraw', tonumber(data.amount), data.IBAN, data.islem ,data.neZaman, data.kimden, data.duzenlenmisAmount)
	TriggerServerEvent('BetterBank:balance')
end)

RegisterNUICallback('transfer', function(data)
	TriggerServerEvent('BetterBank:transfer', data.IBANTarget, tonumber(data.amount), data.targetIslem, data.senderIBAN, data.senderIslem, data.neZaman, data.duzenlenmisAmount)
    Citizen.Wait(500)
	TriggerServerEvent('BetterBank:balance')
end)

RegisterNUICallback('payBill', function(data)

	TriggerServerEvent('BetterBank:payBill', data.tarih, data.label, data.playerIBAN, data.duzenlenmisAmount)
    Citizen.Wait(500)
	TriggerServerEvent('BetterBank:balance')
end)

RegisterNUICallback("exit", function(data)
    ClearPedTasksImmediately(PlayerPedId())
    SetDisplay(false)
end)
--===============================================
--==                ON LOAD                    ==
--===============================================
AddEventHandler('es:playerLoaded',function(source)
    TriggerServerEvent('BetterBank:balance')
end)