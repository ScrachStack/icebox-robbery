if Config.Framework.FrameworkType == 'qb' then
  local QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework.FrameworkType == 'esx' then
  ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework.FrameworkType == 'nd' then
  NDCore = exports["ND_Core"]:GetCoreObject()
end
local isRobberyActive = false

RegisterServerEvent('startRobbery')
AddEventHandler('startRobbery', function()
    local source = source

  
    -- Start the robbery
    isRobberyActive = true
    TriggerClientEvent('robberyStarted', -1, source)

    local playerName = GetPlayerName(source)
    local message = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(255, 0, 0, .9); border-radius: 2px;"><b> [Icebox] '.. playerName ..'</b> <i>has started a robbery.</i></div>'
    TriggerClientEvent('chat:addMessage', -1, { template = message })
end)

RegisterNetEvent('robberyFinished')
AddEventHandler('robberyFinished', function()
    isRobberyActive = false
    TriggerClientEvent('robberyFinished', -1)
end)

AddEventHandler('playerDropped', function()
    local source = source
    if isRobberyActive then
        TriggerClientEvent('robberyFinished')
        isRobberyActive = false
    end
end)




RegisterNetEvent("zaps:bankRobbery")
AddEventHandler("zaps:bankRobbery", function(amount)
  local source = source
  NDCore.Functions.AddMoney(amount, source, "cash", "bank robbbery")
  TriggerClientEvent("chatMessage", source, "You got $" .. amount .. " from the bank robbery!")
  exports.ox_inventory:AddItem(source, Config.Framework.ItemName, 1, nil, nil, function()
  end)
end)


function onload()
print([[
  .___            ___.                 
|   | ____  ____\_ |__   _______  ___
|   |/ ___\/ __ \| __ \ /  _ \  \/  /
|   \  \__\  ___/| \_\ (  <_> >    < 
|___|\___  >___  >___  /\____/__/\_ \
         \/    \/    \/            \/'
[+] - Product Authentication Successful
[+] - Need Support? - https://discord.gg/cfxdev
]])
end

onload()
