IsRobbing = false
local blip = nil

function CreateStoreBlip(x, y, z, sprite, color, name)
    blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
end


Citizen.CreateThread(function()
    local storeBlipConfig = Config.Framework.StoreBlip

    CreateStoreBlip(storeBlipConfig.x, storeBlipConfig.y, storeBlipConfig.z, storeBlipConfig.sprite, storeBlipConfig.color, storeBlipConfig.name)
end)


local markerX = -1256.96
local markerY = -812.98
local markerZ = 17.84

function DisplayRobNotification()
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName("Press ~INPUT_CONTEXT~ to rob")
    EndTextCommandDisplayHelp(0, false, true, -1)
end
function DisplaySmashGlass()
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName("Press ~INPUT_CONTEXT~ to Break the case.")
    EndTextCommandDisplayHelp(0, false, true, -1)
end

function DisplayEmptyCaseNotification()
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName("Looted.")
    EndTextCommandDisplayHelp(0, false, true, -1)
end
 Citizen.CreateThread(function()
    while true do
       Citizen.Wait(0)
      local playerPed = PlayerPedId()
      local playerCoords = GetEntityCoords(playerPed)
       local distance = #(playerCoords - vector3(markerX,markerY,markerZ))
      if distance < 5 then
         if not IsRobbing then  
         DisplayRobNotification()
         if IsControlJustReleased(0, 38) then 
 IsRobbing = true
 TriggerServerEvent('startRobbery')
        end
      end
    end
    end
  end)

RegisterNetEvent('robberyInProgress')
AddEventHandler('robberyInProgress', function()
    -- Notify the player that a robbery is already in progress
    TriggerEvent('chatMessage', '^1Robbery in progress')
end)



Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        if IsRobbing then -- Check if the player is currently robbing
            local isAnyCaseAvailable = false

            for index, case in ipairs(Config.Framework.JewelCases) do
                local caseCoords = vector3(case.x, case.y, case.z)
                local distance = #(playerCoords - caseCoords)

                if distance < 1.5 then
                    if not case.looted then 
                        DisplaySmashGlass()
                        if IsControlJustReleased(0, 38) then
                            TriggerEvent("mythic_progbar:client:progress", {
                                name = "unique_action_name",
                                duration = 10000,
                                label = "Smashing Glass",
                                useWhileDead = false,
                                canCancel = true,
                                controlDisables = {
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = false,
                                },
                                animation = {
                                    animDict = "missheist_jewel",
                                    anim = "smash_case",
                                },
                            
                            }, function(status)
                                if not status then
                                    GiveJewelItem(index)
                                end
                            end)
                          
                        end
                    end

                    isAnyCaseAvailable = true
                end
            end

            if not isAnyCaseAvailable then
                -- No more cases available for looting
          --      DisplayEmptyCaseNotification()
            end
        end
    end
end)

-- Function to give the player a jewel item
function GiveJewelItem(index)
    local case = Config.Framework.JewelCases[index]
    case.looted = true

    -- Trigger the server event to add the item and handle bank robbery
    TriggerServerEvent('zaps:bankRobbery', 1000)
end

RegisterCommand('heist', function()
    --All 4 tables are required in order to proprer syncronize the scaleform.
    local _initialText = { --first slide. Consists of 3 text lines.
        missionTextLabel = "~y~ICEBOX HEIST~s~", 
        passFailTextLabel = "PASSED.",
        messageLabel = "0",
    }
    local _table = { --second slide. You can add as many "stats" as you want. They will appear from botton to top, so keep that in mind.
        {stat = "Total Payout", value = "~g~$~s~50000"},
        --{stat = "value3", value = "~g~$~s~50000"},
        --{stat = "value2", value = "~b~1999~s~"},
        --{stat = "value1", value = "TEST"},
    }
    local _money = { --third slide. Incremental money. It will start from startMoney and increment to finishMoney. top and bottom text appear above/below the money string.
        startMoney = 0,
        finishMoney = 0,
        topText = "0",
        bottomText = "0",
        rightHandStat = "0",
        rightHandStatIcon = 0, --0 or 1 = checked, 2 = X, 3 = no icon
    }
    local _xp = { --fourth and final slide. XP Bar slide. Will start with currentRank and a xp bar filled with (xpBeforeGain - minLevelXP) and will add xpGained. If you rank up, it goes to "Level Up" slide.
        xpGained = 0,
        xpBeforeGain = 0,
        minLevelXP = 0,
        maxLevelXP = 0,
        currentRank = 0,
        nextRank = 0,
        rankTextSmall = "0",
        rankTextBig = "0",
    }
    TriggerEvent("cS.HeistFinale", _initialText, _table, _money, _xp, 10, true)
end)



RegisterNetEvent('robberyFinished')
AddEventHandler('robberyFinished', function()
    -- Reset the robbery state
    IsRobbing = false
    isLooting = false

    -- Add any additional reset logic or actions you need
    commandString = 'heist'
    TriggerEvent("chatMessage", "^1Robbery finished.")
    ExecuteCommand(
	commandString
)



end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Check the player's distance every 1 second (adjust as needed)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        if IsRobbing and #(playerCoords - vector3(-1238.2, -802.29, 17.84)) > 50 then
            TriggerEvent('robberyFinished')
        end
    end
end)
