-- Don't edit this file
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local neededGameBuild = 2060
local currentGameBuild = GetConvarInt('sv_enforceGameBuild', 1604)

Citizen.CreateThread(function()
    if (currentGameBuild < neededGameBuild) then
        print('^3['..GetCurrentResourceName()..']^0: You need to use ^3' .. neededGameBuild .. '^0 game build (or above) to use this resource.')
    end
end)

ESX.RegisterServerCallback('insidetrack:getbalance', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local Chips = xPlayer.getInventoryItem(Config.Item).count
    local minAmount = 500
    if Chips  ~= 0 then
        if Chips >= minAmount then
            Chips = Chips
        else
            
            return TriggerClientEvent('insidetrack:closeBetsNotEnough',source)
        end
    else
        return TriggerClientEvent('insidetrack:closeBetsZeroChips',source)
    end
    cb(Chips)
end)


RegisterServerEvent("insidetrack:placebet", function(bet)
    local xPlayer = ESX.GetPlayerFromId(source)
    local Chips = xPlayer.getInventoryItem(Config.Item).count
        if Chips >= bet then
            xPlayer.removeInventoryItem(Config.Item,bet)
            xPlayer.showNotification("You placed "..bet.." casino chips bet")
        else
            return TriggerClientEvent('insidetrack:closeBetsNotEnough',source)
        end
end) 

RegisterServerEvent('insidetrack:winchips', function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer ~= nil then
        xPlayer.showNotification("You won the race and "..amount.." chips")
	    xPlayer.addInventoryItem(Config.Item, amount)
    end
end)

