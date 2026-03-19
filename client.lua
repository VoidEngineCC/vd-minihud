QBCore = exports['qb-core']:GetCoreObject()
local isHUDVisible = false
local isForcedHidden = false
local currentWeapon = nil
local lastCashUpdate = 0
local cashUpdateDelay = 1000
local isSpawnUIOpen = false
local playerLoaded = false

function CanShowHUD()
    return playerLoaded and not isSpawnUIOpen and not IsNuiFocused()
end

function SendHUData(data)
    if not CanShowHUD() and data.action ~= 'toggleHUD' then
        return
    end
    SendNUIMessage(data)
end


function UpdateMoneyData()
    if not CanShowHUD() then return end
    
    local playerData = QBCore.Functions.GetPlayerData()
    if not playerData then return end
    

    local cashAmount = playerData.money['cash'] or 0
    local bankAmount = playerData.money['bank'] or 0
    
    SendHUData({
        action = 'updateMoney',
        cash = cashAmount,
        bank = bankAmount
    })
end

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    if not CanShowHUD() then return end
    
    SendHUData({
        action = 'updateJob',
        job = job.label .. ' - ' .. job.grade.name
    })
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(gang)
    if not CanShowHUD() then return end
    
    SendHUData({
        action = 'updateGang',
        gang = gang.label .. ' - ' .. gang.grade.name
    })
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    playerLoaded = true
    isSpawnUIOpen = false
    
    local playerData = QBCore.Functions.GetPlayerData()
    local playerId = GetPlayerServerId(PlayerId())
    
    local cashAmount = playerData.money['cash'] or 0
    local bankAmount = playerData.money['bank'] or 0
    
    SendHUData({
        action = 'updateHUD',
        id = playerId,
        cash = cashAmount,
        bank = bankAmount,
        job = playerData.job.label .. ' - ' .. playerData.job.grade.name,
        gang = playerData.gang and (playerData.gang.label .. ' - ' .. playerData.gang.grade.name) or 'None'
    })
    
    SendNUIMessage({
        action = 'toggleHUD',
        show = false
    })
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    playerLoaded = false
    isSpawnUIOpen = true
    SendNUIMessage({
        action = 'toggleHUD',
        show = false
    })
end)

RegisterNetEvent('qb-spawn:client:openUI', function()
    isSpawnUIOpen = true
    SendNUIMessage({
        action = 'toggleHUD',
        show = false
    })
end)

RegisterNetEvent('qb-spawn:client:closeUI', function()
    isSpawnUIOpen = false
    if playerLoaded and isHUDVisible and not isForcedHidden then
        SendNUIMessage({
            action = 'toggleHUD',
            show = true
        })
        UpdateMoneyData()
    end
end)

RegisterNetEvent('qb-multicharacter:client:chooseChar', function()
    isSpawnUIOpen = true
    SendNUIMessage({
        action = 'toggleHUD',
        show = false
    })
end)

RegisterNetEvent('qb-multicharacter:client:closeNUI', function()
    isSpawnUIOpen = false
    if playerLoaded and isHUDVisible and not isForcedHidden then
        SendNUIMessage({
            action = 'toggleHUD',
            show = true
        })
        UpdateMoneyData()
    end
end)

RegisterNetEvent('qb-multicharacter:client:openUI', function()
    isSpawnUIOpen = true
    SendNUIMessage({
        action = 'toggleHUD',
        show = false
    })
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500) 
        
        if not CanShowHUD() then
            goto continue
        end
        
        local playerPed = PlayerPedId()
        local hasWeapon, weaponHash = GetCurrentPedWeapon(playerPed, true)
        
        if hasWeapon and weaponHash ~= `WEAPON_UNARMED` then
            local _, clipAmmo = GetAmmoInClip(playerPed, weaponHash)
            local totalAmmo = GetAmmoInPedWeapon(playerPed, weaponHash)
            
            if clipAmmo and totalAmmo then
                SendHUData({
                    action = 'updateWeapon',
                    armed = true,
                    clip = clipAmmo,
                    ammo = totalAmmo
                })
                
                currentWeapon = weaponHash
            else
                if currentWeapon then
                    SendHUData({
                        action = 'updateWeapon',
                        armed = false
                    })
                    currentWeapon = nil
                end
            end
        else
            if currentWeapon then
                SendHUData({
                    action = 'updateWeapon',
                    armed = false
                })
                currentWeapon = nil
            end
        end
        
        ::continue::
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Citizen.Wait(2000)
        
        if GetResourceState('qb-spawn') == 'started' or GetResourceState('qb-multicharacter') == 'started' then
            isSpawnUIOpen = true
        end
        
        local playerData = QBCore.Functions.GetPlayerData()
        if playerData and playerData.job then
            playerLoaded = true
            isSpawnUIOpen = false
            
            local playerId = GetPlayerServerId(PlayerId())
            
            local cashAmount = playerData.money['cash'] or 0
            local bankAmount = playerData.money['bank'] or 0
            
            SendHUData({
                action = 'updateHUD',
                id = playerId,
                cash = cashAmount,
                bank = bankAmount,
                job = playerData.job.label .. ' - ' .. playerData.job.grade.name,
                gang = playerData.gang and (playerData.gang.label .. ' - ' .. playerData.gang.grade.name) or 'None'
            })
            
            -- Keep HUD hidden by default on resource start
            SendNUIMessage({
                action = 'toggleHUD',
                show = false
            })
        else
            SendNUIMessage({
                action = 'toggleHUD',
                show = false
            })
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(cashUpdateDelay)
        
        if not CanShowHUD() then
            goto continue
        end
        
        local currentTime = GetGameTimer()
        if currentTime - lastCashUpdate >= cashUpdateDelay then
            UpdateMoneyData()
            lastCashUpdate = currentTime
        end
        
        ::continue::
    end
end)

RegisterNetEvent('QBCore:Client:OnMoneyChange', function(moneytype, amount, action, reason)
    Citizen.Wait(100)
    UpdateMoneyData()
end)

RegisterNetEvent('hud:client:OnMoneyChange', function(moneytype, amount, isRemoval)
    Citizen.Wait(100)
    UpdateMoneyData()
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        
        if not CanShowHUD() then
            goto continue
        end
        
        local playerId = GetPlayerServerId(PlayerId())
        SendHUData({
            action = 'updateID',
            id = playerId
        })
        
        ::continue::
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if not playerLoaded or isSpawnUIOpen then
            goto continue
        end
        
        -- Z key (20) to toggle HUD
        if IsControlJustReleased(0, 20) then
            isHUDVisible = not isHUDVisible
            isForcedHidden = not isHUDVisible
            SendNUIMessage({
                action = 'toggleHUD',
                show = isHUDVisible
            })
            
            -- Update money when showing HUD
            if isHUDVisible then
                UpdateMoneyData()
            end
        end
        
        ::continue::
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        
        if IsNuiFocused() and not isSpawnUIOpen and playerLoaded then
            SendNUIMessage({
                action = 'toggleHUD',
                show = false
            })
        elseif not IsNuiFocused() and not isSpawnUIOpen and playerLoaded and isHUDVisible and not isForcedHidden then
            SendNUIMessage({
                action = 'toggleHUD',
                show = true
            })
        end
    end
end)
