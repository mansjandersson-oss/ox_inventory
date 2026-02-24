local QBCore = exports['qb-core']:GetCoreObject()
local Inventory = require 'modules.inventory.server'

AddEventHandler('QBCore:Server:PlayerDropped', server.playerDropped)

AddEventHandler('QBCore:Server:SetJob', function(source, job, lastJob)
    local inventory = Inventory(source)
    if not inventory then return end
    if lastJob then
        inventory.player.groups[lastJob.name] = nil
    end
    inventory.player.groups[job.name] = job.grade.level
end)

local function setupPlayer(player)
    local playerData = player.PlayerData
    playerData.identifier = playerData.citizenid
    playerData.name = ('%s %s'):format(playerData.charinfo.firstname, playerData.charinfo.lastname)
    server.setPlayerInventory(playerData, playerData.inventory)

    local accounts = Inventory.GetAccountItemCounts(playerData.source)
    if not accounts then return end
    for account in pairs(accounts) do
        local playerAccount = account == 'money' and 'cash' or account
        Inventory.SetItem(playerData.source, account, playerData.money[playerAccount] or 0)
    end
end

AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
    setupPlayer(player)
end)

SetTimeout(500, function()
    local players = QBCore.Functions.GetQBPlayers()
    for _, player in pairs(players) do
        setupPlayer(player)
    end
end)

server.accounts = {
    money = 0,
}

function server.UseItem(source, itemName, data)
    local cb = QBCore.Functions.CanUseItem(itemName)
    return cb and cb(source, data)
end

---@diagnostic disable-next-line: duplicate-set-field
function server.setPlayerData(player)
    return {
        source = player.source,
        name = player.name or ('%s %s'):format(player.charinfo.firstname, player.charinfo.lastname),
        groups = { [player.job.name] = player.job.grade.level },
        sex = player.charinfo.gender,
        dateofbirth = player.charinfo.birthdate,
    }
end

---@diagnostic disable-next-line: duplicate-set-field
function server.syncInventory(inv)
    local accounts = Inventory.GetAccountItemCounts(inv)
    if not accounts then return end

    local player = QBCore.Functions.GetPlayer(inv.id)
    if not player then return end

    player.Functions.SetPlayerData('items', inv.items)

    for account, amount in pairs(accounts) do
        local playerAccount = account == 'money' and 'cash' or account
        if player.Functions.GetMoney(playerAccount) ~= amount then
            player.Functions.SetMoney(playerAccount, amount)
        end
    end
end

---@diagnostic disable-next-line: duplicate-set-field
function server.hasLicense(inv, license)
    local player = QBCore.Functions.GetPlayer(inv.id)
    return player and player.PlayerData.metadata.licences[license]
end

---@diagnostic disable-next-line: duplicate-set-field
function server.buyLicense(inv, license)
    local player = QBCore.Functions.GetPlayer(inv.id)
    if not player then return end

    if player.PlayerData.metadata.licences[license.name] then
        return false, 'already_have'
    elseif Inventory.GetItemCount(inv, 'money') < license.price then
        return false, 'can_not_afford'
    end

    Inventory.RemoveItem(inv, 'money', license.price)
    player.PlayerData.metadata.licences[license.name] = true
    player.Functions.SetMetaData('licences', player.PlayerData.metadata.licences)

    return true, 'have_purchased'
end

---@diagnostic disable-next-line: duplicate-set-field
function server.isPlayerBoss(playerId, group)
    local player = QBCore.Functions.GetPlayer(playerId)
    if not player then return end
    return player.PlayerData.job.name == group and player.PlayerData.job.isboss
end
