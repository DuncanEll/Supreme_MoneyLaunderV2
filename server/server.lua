local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('supreme_moneylaunder:GetCash')
AddEventHandler('supreme_moneylaunder:GetCash', function(price)
	local xPlayer  = QBCore.Functions.GetPlayer(source)
    local rolls = xPlayer.Functions.GetItemByName(Config.MoneyType)
	if rolls ~= nil then 
	if exports.ox_inventory:GetItem(source, Config.MoneyType, nil, true) >= price then
			xPlayer.Functions.AddItem(Config.WashedMoney,price)
			xPlayer.Functions.RemoveItem(Config.MoneyType, price)
		else
			TriggerClientEvent('QBCore:Notify', source, 'You do not have enough rolls of notes for this', "success")
		end
	else
		TriggerClientEvent('QBCore:Notify', source, 'You do not have enough rolls of notes for this', "success")
	end
end)	
-- --
