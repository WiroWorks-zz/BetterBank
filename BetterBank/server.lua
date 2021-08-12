ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('BetterBank:balance')
AddEventHandler('BetterBank:balance', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	balance = xPlayer.getAccount('bank').money
	TriggerClientEvent('currentbalance', _source, balance)
end)

RegisterServerEvent('BetterBank:deposit')
AddEventHandler('BetterBank:deposit', function(amount, IBAN, islem, neZaman, kimden, duzenlenmisAmount)
	local _source = source
	
	local xPlayer = ESX.GetPlayerFromId(_source)
	if amount == nil or amount <= 0 or amount > xPlayer.getMoney() then
		TriggerClientEvent('BetterBank:HataMesaj', source)
	else
		xPlayer.removeMoney(amount)
		xPlayer.addAccountMoney('bank', tonumber(amount))
		TriggerEvent('BetterBank:SonIslemEkle', IBAN, islem, tostring(duzenlenmisAmount), neZaman, kimden, amount)
		TriggerClientEvent('BetterBank:AnlıkSonIslemEkle', _source, "paraYatirma", tostring(duzenlenmisAmount), neZaman, "", amount)
	end
end)

RegisterServerEvent('BetterBank:withdraw')
AddEventHandler('BetterBank:withdraw', function(amount, IBAN, islem, neZaman, kimden, duzenlenmisAmount)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local base = 0
	amount = tonumber(amount)
	base = xPlayer.getAccount('bank').money
	if amount == nil or amount <= 0 or amount > base then
		TriggerClientEvent('BetterBank:HataMesaj', source)
	else
		xPlayer.removeAccountMoney('bank', amount)
		xPlayer.addMoney(amount)
		TriggerEvent('BetterBank:SonIslemEkle', IBAN, islem, tostring(duzenlenmisAmount), neZaman, kimden, amount)
		TriggerClientEvent('BetterBank:AnlıkSonIslemEkle', _source, "paraCekme", tostring(duzenlenmisAmount), neZaman, "", amount)
	end
end)

RegisterServerEvent('BetterBank:transfer')
AddEventHandler('BetterBank:transfer', function(targetIBAN, amount, targetIslem, senderIBAN, senderIslem, neZaman, duzenlenmisAmount)
	_source = source

	local gerceklesti = BankParaGonder(source, targetIBAN, tonumber(amount))
	if gerceklesti then
		local forTargetKimden = GetNameFromIBAN(senderIBAN)
		local forSenderKimden = GetNameFromIBAN(targetIBAN)
		Citizen.Wait(500)
		TriggerEvent('BetterBank:SonIslemEkle', targetIBAN, targetIslem, tostring(duzenlenmisAmount), neZaman, forTargetKimden, amount)
		TriggerEvent('BetterBank:SonIslemEkle', senderIBAN, senderIslem, tostring(duzenlenmisAmount), neZaman, forSenderKimden, amount)
		TriggerClientEvent('BetterBank:AnlıkSonIslemEkle', _source, "gidenTransfer", tostring(duzenlenmisAmount), neZaman, forSenderKimden, amount)
	end
end)

RegisterServerEvent('BetterBank:payBill')
AddEventHandler('BetterBank:payBill', function(tarih, label, payerIBAN, duzenlenmisAmount)

	local _source = source

	local result = MySQL.Sync.fetchAll('SELECT senderIBAN, amount FROM billing WHERE neZaman = @neZaman AND label = @label', {
		['@neZaman'] = tarih,
		['@label'] = label
	})
	
	local payerIdentifier = GetIdentifierFromIBAN(payerIBAN)
	local payerID = ESX.GetPlayerFromIdentifier(payerIdentifier)
	payerBalance = payerID.getAccount('bank').money


	local targetIdentifier = GetIdentifierFromIBAN(result[1].senderIBAN)
	local targetID = ESX.GetPlayerFromIdentifier(targetIdentifier)

	local billAmount = result[1].amount

	local senderIBAN = result[1].senderIBAN

	if payerBalance > billAmount then
		if targetID == nil then 

			local result = MySQL.Sync.fetchAll('SELECT accounts FROM users WHERE IBAN = @TIBAN', {
				['@TIBAN'] = senderIBAN,
			})
			Citizen.Wait(250)
			local sqlAccountTable = json.decode(result[1].accounts)
			if (sqlAccountTable["bank"] ~= nil) then 
				payerID.removeAccountMoney('bank', tonumber(billAmount))
				 -- local yeniPara = result[1].bank + tonumber(billAmount)
				sqlAccountTable["bank"] = sqlAccountTable["bank"] + tonumber(billAmount)
				sqlAccountTable = json.encode(sqlAccountTable)
				MySQL.Async.insert("UPDATE users SET accounts = @yeniPara WHERE IBAN = @TIBAN", { 
					['@TIBAN'] = senderIBAN,
					['@yeniPara'] = sqlAccountTable
				})
			end
		else
			payerID.removeAccountMoney('bank', tonumber(billAmount))
			targetID.addAccountMoney('bank', tonumber(billAmount))
		end

		MySQL.Async.insert("UPDATE billing SET durum = 'Odendi' WHERE neZaman = @neZaman AND label = @label", { 
			['@neZaman'] = tarih,
			['@label'] = label
        })
		obalance = payerID.getAccount('bank').money
		Citizen.Wait(250)
		TriggerClientEvent('currentbalance', _source, obalance)
		TriggerClientEvent('BetterBank:AnlıkSonIslemEkle', _source, "FaturaGiden", tostring(duzenlenmisAmount), tostring(agaSaatKac()), 'Fatura')
		TriggerEvent('BetterBank:SonIslemEkle', payerIBAN, 'FaturaGiden', tostring(duzenlenmisAmount), tostring(agaSaatKac()), 'Fatura')
		TriggerEvent('BetterBank:SonIslemEkle', senderIBAN, 'FaturaGelen', tostring(duzenlenmisAmount), tostring(agaSaatKac()), 'Fatura')
		TriggerClientEvent('BetterBank:FaturaAnlikSil', _source, tarih, label)

	else
		TriggerClientEvent('BetterBank:HataMesaj', _source)
	end
end)

ESX.RegisterServerCallback('Betterbank:getname', function(source, cb)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer ~= nil then
        MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier,
        }, function(result)
            if result[1] ~= nil then
                cb(result[1].firstname, result[1].lastname)
            else
                cb(nil)
            end
        end)
    end
end)

ESX.RegisterServerCallback('BetterBank:GetNameAndIBAN', function(source, cb, target)

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)


	local result = MySQL.Sync.fetchAll('SELECT firstname, lastname, IBAN FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	})

	local firstname = result[1].firstname
	local lastname  = result[1].lastname
	local IBAN      = result[1].IBAN

	local data = {
		firstname = firstname,
		lastname  = lastname,
		IBAN      = IBAN
	}
	cb(data)
end)

ESX.RegisterServerCallback('BetterBank:SonYirmiEklee', function(source, cb)

	local _source = source
	local xPlayer = getPlayerID(_source)

	local resultIBAN = MySQL.Sync.fetchAll('SELECT IBAN FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer
	})

	local result = MySQL.Sync.fetchAll('SELECT * FROM betterbanksave WHERE IBAN = @IBAN ORDER BY neZaman DESC LIMIT 20', {
		['@IBAN'] = resultIBAN[1].IBAN 
	})

	local countResult = MySQL.Sync.fetchAll('SELECT COUNT(IBAN) AS sayi FROM betterbanksave WHERE IBAN = @IBAN', {
		['@IBAN'] = resultIBAN[1].IBAN 
	})

	local sayi = countResult[1].sayi

	sayi = tonumber(sayi)

	if(sayi > Config.MaxSonIslem) then
		sayi = Config.MaxSonIslem
	end

	local islemArray = {}
	local neKadarArray = {}
	local neZamanArray = {}
	local kimdenArray = {}

	local index = sayi
	local array = 0

	while array < index do
		islemArray[array] = result[index - array].islem
		neKadarArray[array] = result[index - array].neKadar
		neZamanArray[array] = result[index - array].neZaman
		kimdenArray[array] = result[index - array].kimden
		array = array + 1
	end
	
	local data = {
		islem = islemArray,
		neKadar = neKadarArray,
		neZaman = neZamanArray,
		kimden = kimdenArray,
		kackeredonsun = sayi
	}
	cb(data)
end)

ESX.RegisterServerCallback('BetterBank:FaturalarEkleServer', function(source, cb)

	local _source = source
	local xPlayer = getPlayerID(_source)

	local resultIBAN = MySQL.Sync.fetchAll('SELECT IBAN FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer
	})

	local result = MySQL.Sync.fetchAll('SELECT * FROM billing WHERE targetIBAN = @IBAN AND durum = "Beklemede" ORDER BY neZaman DESC', {
		['@IBAN'] = resultIBAN[1].IBAN 
	})

	local countResult = MySQL.Sync.fetchAll('SELECT COUNT(targetIBAN) AS sayi FROM billing WHERE targetIBAN = @IBAN AND durum = "Beklemede"', {
		['@IBAN'] = resultIBAN[1].IBAN 
	})

	local sayi = countResult[1].sayi

	local senderIBANArray = {}
	local senderNameArray = {}
	local labelArray = {}
	local amountArray = {}
	local neZamanArray = {}

	local index = 0

	while index < sayi do 
		senderIBANArray[index] = result[sayi - index].senderIBAN
		senderNameArray[index] = result[sayi - index].senderName
		labelArray[index] = result[sayi - index].label
		amountArray[index] = result[sayi - index].amount
		neZamanArray[index] = result[sayi - index].neZaman
		index = index + 1
	end

	local data = {
		senderIBAN = senderIBANArray,
		senderName = senderNameArray,
		label = labelArray,
		amount = amountArray,
		neZaman = neZamanArray,
		kackeredonsun = sayi
	}
	cb(data)

end)


--------------


RegisterServerEvent("BetterBank:onPlayerLoaded")
AddEventHandler("BetterBank:onPlayerLoaded",function(a)
    local b=tonumber(a)
    local c=getPlayerID(b)
    CreateOrGetIBAN(b,c)
end)

function CreateOrGetIBAN(source, cb, target)

	Citizen.Wait(20000)

	local _source = source
	local xPlayer = getPlayerID(_source)


	local result = MySQL.Sync.fetchAll('SELECT IBAN FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer
	})

	if result[1].IBAN == '0' then 
		local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
		local length = 4
		local randomString = 'WR'

		math.randomseed(os.time())

		charTable = {}
		for c in chars:gmatch"." do
			table.insert(charTable, c)
		end

		for i = 1, length do
			randomString = randomString .. charTable[math.random(1, #charTable)]
		end

		MySQL.Async.insert("UPDATE users SET IBAN = @IBAN WHERE identifier = @identifier", { 
            ['@IBAN'] = randomString,
            ['@identifier'] = xPlayer
        })
	end
end

function getIdentifiant(id)
    for _, v in ipairs(id) do
        return v
    end
end

function getPlayerID(source)
    local identifiers = GetPlayerIdentifiers(source)
    local player = getIdentifiant(identifiers)
    return player
end

function GetNameFromIBAN(IBAN)
	local result = MySQL.Sync.fetchAll('SELECT firstname, lastname FROM users WHERE IBAN = @IBAN', {
		['@IBAN'] = IBAN
	})
	local nameAndIBAN = result[1].firstname .." " ..result[1].lastname .." - " ..IBAN
	return nameAndIBAN
end

function agaSaatKac()
	local date_table = os.date("*t")
	local hour, minute = date_table.hour, date_table.min
	return (os.date("%d-%m-%Y ") ..hour ..":" ..minute)
end

--====================================================================================
--  OnLoad
--====================================================================================
AddEventHandler('esx:playerLoaded',function(source)
    TriggerEvent('BetterBank:onPlayerLoaded', source)
end)

--====================================================================================
--  Transfere özel fonksiyonlar
--====================================================================================

function BankParaGonder(source, IBAN, miktar)

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local sourceBalance = xPlayer.getAccount('bank').money
	local TIBAN = IBAN

	local targetIdentifier = GetIdentifierFromIBAN(IBAN)
	local targetID = ESX.GetPlayerFromIdentifier(targetIdentifier)

	if miktar < sourceBalance then
		if targetID == nil then
			local result = MySQL.Sync.fetchAll('SELECT accounts FROM users WHERE IBAN = @TIBAN', {
				['@TIBAN'] = TIBAN,
			})
			
			local sqlAccountTable = json.decode(result[1].accounts)
			if (sqlAccountTable["bank"] ~= nil) then 
				xPlayer.removeAccountMoney('bank', tonumber(miktar))
				sqlAccountTable["bank"] = sqlAccountTable["bank"] + miktar
				sqlAccountTable = json.encode(sqlAccountTable)
				MySQL.Async.insert("UPDATE users SET accounts = @yeniPara WHERE IBAN = @TIBAN", { 
					['@TIBAN'] = TIBAN,
					['@yeniPara'] = sqlAccountTable
				})
				return true
			end
		else
			xPlayer.removeAccountMoney('bank', tonumber(miktar))
			targetID.addAccountMoney('bank', tonumber(miktar))
			return true
		end

	else 

		TriggerClientEvent('BetterBank:HataMesaj', source)
		return false

	end


end

function FaturaOde(IBAN, miktar)
	local TIBAN = IBAN

	local result = MySQL.Sync.fetchAll('SELECT bank FROM users WHERE IBAN = @TIBAN', {
		['@TIBAN'] = TIBAN,
	})

	local yeniPara = result[1].bank + miktar
	MySQL.Async.insert("UPDATE users SET bank = @yeniPara WHERE IBAN = @TIBAN", { 
		['@TIBAN'] = TIBAN,
		['@yeniPara'] = yeniPara
	})
end

function GetIdentifierFromIBAN(IBAN)
	local result = MySQL.Sync.fetchAll('SELECT identifier FROM users WHERE IBAN = @IBAN', {
		['@IBAN'] = IBAN,
	})
	Citizen.Wait(100)
	return result[1].identifier
end

RegisterServerEvent('BetterBank:SonIslemEkle')
AddEventHandler('BetterBank:SonIslemEkle', function(IBAN, islem, neKadar, neZaman, kimden, amount)
	if amount == nil or Config.dbMinFiyat <= amount then
		MySQL.Async.fetchAll("INSERT INTO betterbanksave (IBAN, islem, neKadar, neZaman, kimden) VALUES(@IBAN, @islem, @neKadar, @neZaman, @kimden)",{
			['@IBAN'] = IBAN,
			['@islem'] = islem,
			['@neKadar'] = neKadar,
			['@neZaman'] = neZaman,
			['@kimden'] = kimden
		})
	end
end)