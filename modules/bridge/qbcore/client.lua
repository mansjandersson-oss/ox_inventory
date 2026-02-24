RegisterNetEvent('QBCore:Client:OnPlayerUnload', client.onLogout)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(playerData)
    if not PlayerData.loaded then return end

    local groups = { [playerData.job.name] = playerData.job.grade.level }
    client.setPlayerData('groups', groups)
end)

---@diagnostic disable-next-line: duplicate-set-field
function client.setPlayerStatus(_)
    -- QBCore does not have a built-in status API
end
