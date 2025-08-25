local QBCore = exports['qb-core']:GetCoreObject()
local showing = false

-- Build UI data from jobs
local function BuildJobsUi(jobs, current, onduty)
    local jobsForUi = {}
    for jobName, j in pairs(jobs or {}) do
        local shared = QBCore.Shared.Jobs[jobName]
        if shared then
            local grade = shared.grades[tostring(j.grade)] or {}
            local label = shared.label or jobName
            local gradeLabel = grade.name or ('Grade ' .. tostring(j.grade))
            local salary = Config.SalaryJobs[jobName] and (grade.payment or 0) or 0

            jobsForUi[#jobsForUi+1] = {
                job = jobName,
                label = label,
                grade = gradeLabel,
                gradeNum = j.grade,
                salary = salary,
                onDuty = (current == jobName) and onduty or false,
                isActive = (current == jobName),
                isSalary = Config.SalaryJobs[jobName] and true or false
            }
        end
    end
    return jobsForUi
end

-- Open UI
local function openJobs()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if not PlayerData then return end
    local jobs = PlayerData.metadata and PlayerData.metadata.jobs or {}
    local current = PlayerData.job and PlayerData.job.name or 'unemployed'
    local onduty  = PlayerData.job and PlayerData.job.onduty or false

    SendNUIMessage({
        action = 'showJobs',
        jobs = BuildJobsUi(jobs, current, onduty)
    })
    SetNuiFocus(true, true)
    showing = true
end

local function closeJobs()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hide' })
    showing = false
end

-- NUI Callbacks
RegisterNUICallback('toggleDuty', function(data, cb)
    TriggerServerEvent('EF-MultiJob:Server:SetDutyStatus', not QBCore.Functions.GetPlayerData().job.onduty)
    cb(1)
end)

RegisterNUICallback('selectJob', function(data, cb)
    if data and data.job then
        TriggerServerEvent('EF-MultiJob:Server:SelectJob', data.job)
    end
    cb(1)
end)

RegisterNUICallback('removeJob', function(data, cb)
    if data and data.job then
        TriggerServerEvent('EF-MultiJob:Server:RemoveJob', data.job)
    end
    cb(1)
end)

RegisterNUICallback('close', function(_, cb)
    closeJobs()
    cb(1)
end)

-- Commands & Key
RegisterCommand(Config.OpenCommand, function()
    if showing then closeJobs() else openJobs() end
end)
RegisterKeyMapping(Config.OpenCommand, 'Open Job Menu', 'keyboard', Config.OpenKey)

-- Auto-sync jobs
RegisterNetEvent('EF-MultiJob:Client:SyncJobs', function(jobs)
    local PlayerData = QBCore.Functions.GetPlayerData()
    local current = PlayerData.job and PlayerData.job.name or 'unemployed'
    local onduty  = PlayerData.job and PlayerData.job.onduty or false

    SendNUIMessage({
        action = 'update',
        jobs = BuildJobsUi(jobs, current, onduty)
    })
end)
