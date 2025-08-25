local QBCore = exports['qb-core']:GetCoreObject()

-- Push updated jobs to client
local function SyncJobs(Player)
    local src = Player.PlayerData.source
    TriggerClientEvent('EF-MultiJob:Client:SyncJobs', src, Player.PlayerData.metadata['jobs'] or {})
end

-- Ensure metadata on login
AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    local jobs = Player.PlayerData.metadata['jobs']
    if not jobs or next(jobs) == nil then
        jobs = {}
        jobs[Player.PlayerData.job.name] = { grade = Player.PlayerData.job.grade.level or 0 }
        Player.Functions.SetMetaData('jobs', jobs)
    end
    SyncJobs(Player)
end)

-- Whenever qb-core sets a job, add it to metadata
AddEventHandler('QBCore:Server:SetJob', function(Player, job, grade)
    if not Player then return end
    local jobs = Player.PlayerData.metadata['jobs'] or {}
    jobs[job] = { grade = grade or 0 }
    Player.Functions.SetMetaData('jobs', jobs)
    SyncJobs(Player)
end)

-- Set job from UI
RegisterNetEvent("EF-MultiJob:Server:SelectJob", function(job)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not job then return end

    local jobs = Player.PlayerData.metadata['jobs'] or {}
    if not jobs[job] then return end

    Player.Functions.SetJob(job, jobs[job].grade or 0)
    SyncJobs(Player)
end)

-- Remove job (quit)
RegisterNetEvent("EF-MultiJob:Server:RemoveJob", function(job)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not job then return end

    local jobs = Player.PlayerData.metadata['jobs'] or {}
    jobs[job] = nil
    Player.Functions.SetMetaData('jobs', jobs)

    if Player.PlayerData.job and Player.PlayerData.job.name == job then
        Player.Functions.SetJob("unemployed", 0)
    end

    SyncJobs(Player)
end)

-- Toggle duty
RegisterNetEvent("EF-MultiJob:Server:SetDutyStatus", function(status)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or status == nil then return end

    Player.Functions.SetJobDuty(status and true or false)
    SyncJobs(Player)
end)
