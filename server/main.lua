ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('jobmenu:getSocietyMoney', function(src, cb, job)
    local society = 'society_' .. job
    MySQL.Async.fetchScalar('SELECT money FROM addon_account_data WHERE account_name = @acc', {
        ['@acc'] = society
    }, function(money)
        cb(money or 0)
    end)
end)

RegisterNetEvent('jobmenu:deposit')
AddEventHandler('jobmenu:deposit', function(job, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.money >= amount then
        xPlayer.removeMoney(amount)
        local society = 'society_' .. job
        MySQL.Async.execute('UPDATE addon_account_data SET money = money + @amt WHERE account_name = @acc', {
            ['@amt'] = amount,
            ['@acc'] = society
        })
        TriggerClientEvent('esx:showNotification', source, '💰 مبلغ واریز شد.')
    else
        TriggerClientEvent('esx:showNotification', source, '❌ پول کافی ندارید.')
    end
end)

RegisterNetEvent('jobmenu:withdraw')
AddEventHandler('jobmenu:withdraw', function(job, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local society = 'society_' .. job
    MySQL.Async.fetchScalar('SELECT money FROM addon_account_data WHERE account_name = @acc', {
        ['@acc'] = society
    }, function(money)
        if money >= amount then
            xPlayer.addMoney(amount)
            MySQL.Async.execute('UPDATE addon_account_data SET money = money - @amt WHERE account_name = @acc', {
                ['@amt'] = amount,
                ['@acc'] = society
            })
            TriggerClientEvent('esx:showNotification', source, '💵 پول برداشت شد.')
        else
            TriggerClientEvent('esx:showNotification', source, '❌ پول کافی در حساب نیست.')
        end
    end)
end)

ESX.RegisterServerCallback('jobmenu:getPlayersWithoutJob', function(src, cb)
    local players = ESX.GetPlayers()
    local list = {}
    for _, id in pairs(players) do
        local xPlayer = ESX.GetPlayerFromId(id)
        if xPlayer and xPlayer.job.name == 'nojob' then
            table.insert(list, { id = id, name = xPlayer.name })
        end
    end
    cb(list)
end)

function SendToDiscord(title, description, color)
    local data = {
        username = "Society Logs",
        embeds = {{
            title = title,
            description = description,
            color = color,
        }}
    }

    PerformHttpRequest(Config.Webhook_JobLogs, function(err, text, headers) end,
        "POST", json.encode(data), { ["Content-Type"] = "application/json" })
end


RegisterNetEvent('jobmenu:hirePlayer')
AddEventHandler('jobmenu:hirePlayer', function(targetId, job)
    local src = source
    local xTarget = ESX.GetPlayerFromId(targetId)
    local xSrc = ESX.GetPlayerFromId(src)

    if not xTarget or not xSrc then return end

    local jobLimit = Config.JobLimits and Config.JobLimits[job]

    local function hirePlayer()
        xTarget.setJob(job, 0)

        SendToDiscord(
            "👔 استخدام",
            string.format(
                "مدیر %s بازیکن %s [Steam: %s] را در شغل %s با درجه 0 استخدام کرد.\n%s",
                xSrc.name,
                xTarget.name,
                xTarget.identifier,
                job,
                os.date("%Y-%m-%d %H:%M:%S")
            ),
            3066993
        )

        TriggerClientEvent('esx:showNotification', targetId, 'شما در شغل ' .. job .. ' استخدام شدید.')
        TriggerClientEvent('esx:showNotification', src, 'بازیکن با موفقیت استخدام شد.')
    end

    if jobLimit then
        MySQL.Async.fetchScalar('SELECT COUNT(*) FROM users WHERE job = @job', { ['@job'] = job }, function(count)
            if count >= jobLimit then
                TriggerClientEvent('esx:showNotification', src, 'اسلات شغل پر است!')
                return
            end
            hirePlayer()
        end)
    else
        hirePlayer()
    end
end)

ESX.RegisterServerCallback('jobmenu:getEmployees', function(src, cb, job)

    MySQL.Async.fetchAll('SELECT grade, label, name FROM job_grades WHERE job_name = @job', {
        ['@job'] = job
    }, function(grades)

        local gradeList = {}
        for _, g in ipairs(grades or {}) do
            gradeList[tonumber(g.grade)] = { label = g.label, name = g.name }
        end

        MySQL.Async.fetchAll('SELECT playerName, job_grade, identifier FROM users WHERE job = @job',
            { ['@job'] = job }, function(result)

                local employees = {}

                for _, v in ipairs(result or {}) do
                    local gradeInfo = gradeList[tonumber(v.job_grade)] or { label = 'نامشخص' }

                    table.insert(employees, {
                        name = v.playerName or 'نامشخص',
                        grade_label = gradeInfo.label,
                        identifier = v.identifier
                    })
                end

                cb(employees)
            end)
    end)
end)

RegisterNetEvent('jobmenu:setGrade')
AddEventHandler('jobmenu:setGrade', function(identifier, job, grade)

    local xSrc = ESX.GetPlayerFromId(source)
    if not xSrc then return end

    MySQL.Async.fetchScalar('SELECT job_grade FROM users WHERE identifier = @id', {
        ['@id'] = identifier
    }, function(oldGrade)

        MySQL.Async.execute('UPDATE users SET job = @job, job_grade = @grade WHERE identifier = @id', {
            ['@job'] = job,
            ['@grade'] = grade,
            ['@id'] = identifier
        })

        for _, playerId in ipairs(ESX.GetPlayers()) do
            local xP = ESX.GetPlayerFromId(playerId)

            if xP and xP.identifier == identifier then

                SendToDiscord(
                    "📈 ارتقاء",
                    string.format(
                        "مدیر %s بازیکن %s [Steam: %s] را در شغل %s از درجه %s به درجه %s ارتقاء داد.\n%s",
                        xSrc.name,
                        xP.name,
                        xP.identifier,
                        job,
                        oldGrade,
                        grade,
                        os.date("%Y-%m-%d %H:%M:%S")
                    ),
                    3447003
                )

                xP.setJob(job, tonumber(grade))
                TriggerClientEvent("esx:showNotification", playerId, "رنک شما تغییر کرد.")
                break
            end
        end
    end)
end)

RegisterNetEvent('jobmenu:firePlayer')
AddEventHandler('jobmenu:firePlayer', function(identifier)

    local xSrc = ESX.GetPlayerFromId(source)
    if not xSrc then return end

    MySQL.Async.fetchAll('SELECT job, job_grade, playerName FROM users WHERE identifier = @id', {
        ['@id'] = identifier
    }, function(data)

        if data[1] then

            SendToDiscord(
                "❌ اخراج",
                string.format(
                    "مدیر %s بازیکن %s [Steam: %s] را از شغل %s با درجه %s اخراج کرد.\n%s",
                    xSrc.name,
                    data[1].playerName,
                    identifier,
                    data[1].job,
                    data[1].job_grade,
                    os.date("%Y-%m-%d %H:%M:%S")
                ),
                15158332 
            )
        end

        MySQL.Async.execute('UPDATE users SET job = "nojob", job_grade = 0 WHERE identifier = @id',
            { ['@id'] = identifier })

        for _, playerId in ipairs(ESX.GetPlayers()) do
            local xP = ESX.GetPlayerFromId(playerId)
            if xP and xP.identifier == identifier then
                xP.setJob("nojob", 0)
                TriggerClientEvent("esx:showNotification", playerId, "شما از شغل خود اخراج شدید.")
                break
            end
        end
    end)
end)

ESX.RegisterServerCallback('jobmenu:getGrades', function(src, cb, job)
    MySQL.Async.fetchAll('SELECT grade, label FROM job_grades WHERE job_name = @job ORDER BY grade ASC',
        { ['@job'] = job },
        function(result)
            cb(result or {})
        end)
end)

RegisterNetEvent('jobmenu:updateGrade')
AddEventHandler('jobmenu:updateGrade', function(job, grade, updates)
    local setQuery, params = {}, {}
    for k, v in pairs(updates) do
        table.insert(setQuery, k .. " = @" .. k)
        params['@' .. k] = v
    end
    params['@job'] = job
    params['@grade'] = grade

    MySQL.Async.execute(
        'UPDATE job_grades SET ' .. table.concat(setQuery, ', ') .. ' WHERE job_name = @job AND grade = @grade', params)
end)


ESX.RegisterServerCallback('jobmenu:setUniform', function(source, cb, job, rank, gender, model)
    if gender == 'male' then
        MySQL.Async.execute(
            'UPDATE job_grades SET skin_male = @skin_male WHERE job_name = @job_name AND grade = @grade', {
                ['@skin_male'] = json.encode(model),
                ['@job_name']  = job,
                ['@grade']     = rank
            }, function(rowsChanged)
                cb()
            end)
    elseif gender == 'female' then
        MySQL.Async.execute(
            'UPDATE job_grades SET skin_female = @skin_female WHERE job_name = @job_name AND grade = @grade', {
                ['@skin_female'] = json.encode(model),
                ['@job_name']    = job,
                ['@grade']       = rank
            }, function(rowsChanged)
                cb()
            end)
    end
end)

ESX.RegisterServerCallback('jobmenu:getPlayerSkin', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier',
        {
            ['@identifier'] = xPlayer.identifier
        },
        function(users)
            local user = users[1]
            local skin = nil
            if user.skin ~= nil then
                skin = json.decode(user.skin)
            end
            cb(skin)
        end)
end)

ESX.RegisterServerCallback("jobmenu:GetJobGradeClothe", function(source, cb, grade, sex, society)
    MySQL.Async.fetchAll('SELECT * FROM job_grades WHERE job_name = @job_name',
        {
            ['@job_name'] = society,

        }, function(data)
            if data ~= nil then
                for k, v in pairs(data) do
                    if v.grade == grade then
                        if sex == 'male' then
                            cb(json.decode(v.skin_male))
                            break
                        else
                            cb(json.decode(v.skin_female))
                            break
                        end
                    end
                end
            end
        end)
end)
