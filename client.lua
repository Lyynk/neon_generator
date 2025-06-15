local Config = require 'config'
local zones = {}

local function createZones()
    local zone = exports.ox_target:addSphereZone({
        coords = Config.Target.coords,
        radius = 1.5,
        debug = false,
        options = {
            {
                name = 'daily_reward',
                icon = Config.Target.icon,
                label = Config.Target.label,
                onSelect = function()
                    local gang = QBX.PlayerData.gang.name
                    if not gang or gang == 'none' then
                        lib.notify({ description = "You're not in a gang!", type = 'error' })
                        return
                    end
                    TriggerServerEvent('neon:dailyReward')
                end,
                canInteract = function()
                    local gang = QBX.PlayerData.gang.name
                    if not gang or gang == 'none' then
                        return false
                    end
                    return true
                end
            }
        }
    })
    zones[zone] = true
end

local function destroyZones()
    for zone in pairs(zones) do
        exports.ox_target:removeZone(zone)
    end
    zones = {}
end

RegisterNetEvent('neon:notify', function(msg, type)
    lib.notify({ description = msg, type = type or 'info' })
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        createZones()
    end
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    createZones()
end)

RegisterNetEvent('qbx_core:client:playerLoggedOut', function()
    destroyZones()
end)
