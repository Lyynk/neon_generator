local cooldowns = {}
local Config = require 'config'

local function getLastGen(license)
    local lastGen = MySQL.scalar.await('SELECT `lastGen` FROM `generator` WHERE `license` = ? LIMIT 1', {
        license
    })
    return lastGen
end

local function getCooldownOver(lastGen)
    local now = os.time()
    return now - lastGen >= 86400
end

local function setCooldown(license)
    local now = os.time()
    MySQL.insert.await('INSERT INTO `generator` (`license`, `lastGen`) VALUES (?, ?) ON DUPLICATE KEY UPDATE `lastGen` = ?', {
        license, now, now
    })
    cooldowns[license] = now
end

RegisterNetEvent('neon:dailyReward', function()
    local src = source
    local now = os.time()
    local player = exports.qbx_core:GetPlayer(src)
    local playerGang = player?.PlayerData?.gang?.name
    local playerLicense = player?.PlayerData?.license
    local cooldownOver

    if not src then return end
    if not playerGang or playerGang == 'none' then
        TriggerClientEvent('neon:notify', src, "You're not in a gang!", "error")
        return
    end

    if cooldowns[playerLicense] then
        local lastGen = cooldowns[playerLicense]
        cooldownOver = getCooldownOver(lastGen)
    end

    if not cooldowns[playerLicense] then
        local lastGen = getLastGen(playerLicense)
        if lastGen then
            cooldownOver = getCooldownOver(lastGen)
            cooldowns[playerLicense] = lastGen
        end
    end

    if cooldownOver == false then
        local remaining = 86400 - (now - cooldowns[playerLicense])
        local hours = math.floor(remaining / 3600)
        local mins = math.floor((remaining % 3600) / 60)
        TriggerClientEvent('neon:notify', src, ("Come back in %dh %dm!"):format(hours, mins), "error")
        return
    end

    local item = Config.Items[math.random(#Config.Items)]
    if exports.ox_inventory:CanCarryItem(src, item, 1) then
        exports.ox_inventory:AddItem(src, item, 1)
        setCooldown(playerLicense)
    end
    TriggerClientEvent('neon:notify', src, "You received: " .. item, "success")
end)
