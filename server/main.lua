local ESX = nil
-- ESX
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- TriggerServerEvent('raketering:handout_sheet', orderSheet, GetPlayerServerId(player))

RegisterServerEvent('raketering:handout_sheet')
AddEventHandler('raketering:handout_sheet', function(sheet, targetID)
  local _source = ESX.GetPlayerFromId(targetID).source

  TriggerClientEvent('raketering:show_sheet', _source, sheet)
end)