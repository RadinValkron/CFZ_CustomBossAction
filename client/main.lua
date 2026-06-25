ESX = nil
local currentJob, currentGrade = nil, nil
local LastPosition = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end
    Citizen.Wait(1000)
    local playerData = ESX.GetPlayerData()
    currentJob = playerData.job.name
    currentGrade = playerData.job.grade_name
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    currentJob = job.name
    currentGrade = job.grade_name or job.grade_label or tostring(job.grade)
end)

-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(0)
--         local ped = PlayerPedId()
--         local coords = GetEntityCoords(ped)

--         for job, data in pairs(Config.JobManagement) do
--             local dist = #(coords - data.marker)
--             if dist < 15 then
--                 DrawMarker(2, data.marker.x, data.marker.y, data.marker.z + 0.1, 0, 0, 0, 0, 0, 0, 0.4, 0.4, 0.4, 0, 150,
--                     255, 150, 0, 0, 0, 1)
--                 if dist < data.markerDist then
--                     ESX.ShowHelpNotification("برای باز کردن منوی مدیریت ~INPUT_CONTEXT~ را بزنید")
--                     if IsControlJustReleased(0, 38) then
--                         if currentJob == job and hasPermission(job, currentGrade) then
--                             OpenJobMenu(job)
--                         else
--                         end
--                     end
--                 end
--             end
--         end
--     end
-- end)

---multi

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local jobData = Config.JobManagement[currentJob]

        if jobData and jobData.markers then  -- چک می‌کنیم که markers وجود داشته باشه
            local isNearAnyMarker = false

            for _, markerData in ipairs(jobData.markers) do
                local markerPos = markerData.pos
                local markerDist = markerData.dist or 1.5  -- فاصله پیش‌فرض اگر مشخص نشده بود

                local dist = #(coords - markerPos)

                if dist < 15.0 then
                    isNearAnyMarker = true

                    -- رسم مارکر (فقط یکی کافیه، ولی می‌تونیم برای هر کدوم جدا رسم کنیم)
                    DrawMarker(2, markerPos.x, markerPos.y, markerPos.z + 0.9 - 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.58, 0.58, 0.38, 255, 255, 255, 255, false, true, 2, false, false, false, false)

                    if dist < markerDist then
                        ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ To Open Boss Action")

                        if IsControlJustReleased(0, 38) then  -- E key
                            if hasPermission(currentJob, currentGrade) then
                                OpenJobMenu(currentJob)
                            end
                        end
                    end
                end
            end

            -- اگر نزدیک هیچ مارکری نبود، منتظر بمون تا فریم بعدی (بهینه‌سازی کوچک)
            if not isNearAnyMarker then
                Citizen.Wait(500)
            end
        else
            Citizen.Wait(1000) -- اگر شغل مدیریت نداره، کمتر چک کن
        end
    end
end)


-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(0)
--         local ped = PlayerPedId()
--         local coords = GetEntityCoords(ped)
--         local jobData = Config.JobManagement[currentJob]
--         if jobData then
--             local dist = #(coords - jobData.marker)
--             if dist < 15 then
--                 -- DrawMarker(2, jobData.marker.x, jobData.marker.y, jobData.marker.z + 0.1, 0, 0, 0, 0, 0, 0, 0.4, 0.4, 0.4, 0, 150, 255, 150, 0, 0, 0, 1)
--                 DrawMarker(2, jobData.marker.x, jobData.marker.y, jobData.marker.z+0.9 - 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.58, 0.58, 0.38, 255, 255, 255, 255, false, true, 2, false, false, false, false)
--                 if dist < jobData.markerDist then
--                     -- ESX.ShowHelpNotification("برای باز کردن منوی مدیریت ~INPUT_CONTEXT~ را بزنید")
--                     ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ To Open Boss Action")

--                     if IsControlJustReleased(0, 38) then
--                         if hasPermission(currentJob, currentGrade) then
--                             OpenJobMenu(currentJob)
--                         -- else
--                         --     ESX.ShowNotification("شما دسترسی لازم را ندارید")
--                         end
--                     end
--                 end
--             end
--         end
--     end
-- end)


function hasPermission(job, grade)
    for _, g in pairs(Config.JobManagement[job].allowedGrades) do
        if g == grade then return true end
    end
    return false
end

function OpenJobMenu(job)
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'job_management', {
        title = 'مدیریت ' .. job,
        align = 'top-right',
        elements = {
            { label = '💰 مدیریت حساب سازمان', value = 'account' },
            { label = '👥 استخدام بازیکن', value = 'hire' },
            { label = '📋 لیست کارمندان', value = 'employees' },
            { label = '⚙️ مدیریت رنک‌ها', value = 'manage_grades' }
        }
    }, function(data, menu)
        if data.current.value == 'account' then
            OpenSocietyAccount(job)
        elseif data.current.value == 'hire' then
            OpenHireMenu(job)
        elseif data.current.value == 'employees' then
            OpenEmployeesMenu(job)
        elseif data.current.value == 'manage_grades' then
            OpenManageGradesMenu(job)
        end
    end, function(data, menu)
        menu.close()
    end)
end

function OpenSocietyAccount(job)
    ESX.TriggerServerCallback('jobmenu:getSocietyMoney', function(money)
        ESX.UI.Menu.CloseAll()

        local elements = {
            { label = '💵 موجودی: $' .. ESX.Math.GroupDigits(money), value = 'none' },
            { label = '➕ واریز پول', value = 'deposit' },
            { label = '➖ برداشت پول', value = 'withdraw' },
            { label = '🔄 بروزرسانی', value = 'refresh' }
        }

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'society_account', {
            title = '💰 حساب سازمانی (' .. job .. ')',
            align = 'center',
            elements = elements
        }, function(data, menu)
            if data.current.value == 'deposit' then
                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'deposit_amount', {
                    title = 'مبلغ واریز'
                }, function(data2, menu2)
                    local amount = tonumber(data2.value)
                    if amount and amount > 0 then
                        TriggerServerEvent('jobmenu:deposit', job, amount)
                        menu2.close()
                        Citizen.Wait(500)
                        OpenSocietyAccount(job)
                    else
                        ESX.ShowNotification('مبلغ نامعتبر است.')
                    end
                end)
            elseif data.current.value == 'withdraw' then
                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'withdraw_amount', {
                    title = 'مبلغ برداشت'
                }, function(data2, menu2)
                    local amount = tonumber(data2.value)
                    if amount and amount > 0 then
                        TriggerServerEvent('jobmenu:withdraw', job, amount)
                        menu2.close()
                        Citizen.Wait(500)
                        OpenSocietyAccount(job) 
                    else
                        ESX.ShowNotification('مبلغ نامعتبر است.')
                    end
                end)
            elseif data.current.value == 'refresh' then
                OpenSocietyAccount(job)
            end
        end, function(data, menu)
            menu.close()
        end)
    end, job)
end


function OpenHireMenu(job)
    ESX.TriggerServerCallback('jobmenu:getPlayersWithoutJob', function(players)
        local elements = {}
        for _, p in pairs(players) do
            table.insert(elements, { label = p.name, playerId = p.id })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'hire_players', {
            title = '👥 لیست افراد بدون شغل',
            align = 'center',
            elements = elements
        }, function(data, menu)
            TriggerServerEvent('jobmenu:hirePlayer', data.current.playerId, job)
            menu.close()
        end)
    end)
end

function OpenEmployeesMenu(job)
    ESX.TriggerServerCallback('jobmenu:getEmployees', function(employees)
        local elements = {}
        for _, e in pairs(employees) do
            table.insert(elements, { label = e.name .. ' | ' .. e.grade_label, value = e })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'employee_list', {
            title = '👥 کارمندان ' .. job,
            align = 'center',
            elements = elements
        }, function(data, menu)
            local emp = data.current.value
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_employee', {
                title = emp.name,
                align = 'center',
                elements = {
                    { label = '📈 تغییر رنک', value = 'change_grade' },
                    { label = '❌ اخراج', value = 'fire' }
                }
            }, function(d, m)
                if d.current.value == 'change_grade' then
                    ESX.TriggerServerCallback('jobmenu:getGrades', function(grades)
                        local gradeElements = {}
                        for _, g in ipairs(grades) do
                            table.insert(gradeElements,
                                { label = g.label .. ' (grade: ' .. g.grade .. ')', value = g.grade })
                        end

                        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'choose_grade', {
                            title = 'انتخاب رنک جدید',
                            align = 'center',
                            elements = gradeElements
                        }, function(gdata, gmenu)
                            TriggerServerEvent('jobmenu:setGrade', emp.identifier, job, gdata.current.value)
                            ESX.ShowNotification('✅ رنک ' .. emp.name .. ' تغییر کرد به ' .. gdata.current.label)
                            gmenu.close()
                            menu.close()
                            OpenEmployeesMenu(job)
                        end, function(gdata, gmenu)
                            gmenu.close()
                        end)
                    end, job)
                elseif d.current.value == 'fire' then
                    TriggerServerEvent('jobmenu:firePlayer', emp.identifier)
                    m.close()
                    menu.close()
                    OpenEmployeesMenu(job)
                end
            end, function(d, m)
                m.close()
            end)
        end, function(data, menu)
            menu.close()
        end)
    end, job)
end

local invis = false
function FastTravel(coords, heading)
    local playerPed = PlayerPedId()



    DoScreenFadeOut(tonumber(800))



    while not IsScreenFadedOut() do
        Citizen.Wait(tonumber(500))
    end


    ESX.Game.Teleport(playerPed, coords, function()
        local otherPlayerPed = GetPlayerPed(GetPlayerFromServerId(serverId))
        DoScreenFadeIn(tonumber(800))

        if heading then
            SetEntityHeading(playerPed, tonumber(heading))
        end

        if not invis then
            FreezeEntityPosition(playerPed, true)
            NetworkSetEntityInvisibleToNetwork(playerPed, true)
            SetEntityNoCollisionEntity(otherPlayerPed, playerPed, true)
            invis = true
        else
            FreezeEntityPosition(playerPed, false)
            NetworkSetEntityInvisibleToNetwork(playerPed, false)
            SetEntityNoCollisionEntity(otherPlayerPed, playerPed, false)
        end
    end)
end

-- function OpenOutfitM(society, grade)
--     print(society, grade)
--     ESX.TriggerServerCallback('jobmenu:getPlayerSkin', function(myskin)
--         print(myskin)
--         ESX.TriggerServerCallback('jobmenu:GetJobGradeClothe', function(skinjob)
--             FastTravel(Config.TpCoords, Config.heading)
--             if skinjob ~= nil then
--                 TriggerEvent('skinchanger:loadClothes', Config.MaleDefault, skinjob)
--             else
--                 TriggerEvent('skinchanger:loadSkin', Config.MaleDefault)
--             end
--             Citizen.Wait(tonumber(1000))
--             TriggerEvent("esx_skin:openSaveableMenu", source)
--             local WaitForSave = true
--             while WaitForSave do
--                 if ESX.UI.Menu.IsOpen('default', 'esx_skin', 'skin') then
--                     Citizen.Wait(tonumber(1000))
--                 else
--                     TriggerEvent('skinchanger:getSkin', function(skin)
--                         ESX.TriggerServerCallback('jobmenu:setUniform', function()
--                         end, society, tonumber(grade), 'male', skin)
--                     end)
--                     WaitForSave = false
--                     FastTravel(vector3(tonumber(LastPosition.x), tonumber(LastPosition.y),
--                         tonumber(LastPosition.z)))
--                     TriggerEvent('skinchanger:loadSkin', myskin)
--                     Citizen.Wait(tonumber(100))
--                     TriggerServerEvent('esx_skin:save', myskin)
--                 end
--                 Citizen.Wait(tonumber(1000))
--             end
--         end, tonumber(grade), 'male', society)
--     end)
-- end

-- function OpenOutfitF(society, grade)
--     ESX.TriggerServerCallback('jobmenu:getPlayerSkin', function(myskin)
--         ESX.TriggerServerCallback('jobmenu:GetJobGradeClothe', function(skinjob)
--             FastTravel(Config.TpCoords, Config.heading)
--             if skinjob ~= nil then
--                 TriggerEvent('skinchanger:loadClothes', Config.FemaleDefault, skinjob)
--             else
--                 TriggerEvent('skinchanger:loadSkin', Config.FemaleDefault)
--             end
--             Citizen.Wait(tonumber(1000))
--             TriggerEvent("esx_skin:openSaveableMenu", source)
--             local WaitForSave = true
--             while WaitForSave do
--                 if ESX.UI.Menu.IsOpen('default', 'esx_skin', 'skin') then
--                     Citizen.Wait(tonumber(1000))
--                 else
--                     TriggerEvent('skinchanger:getSkin', function(skin)
--                         ESX.TriggerServerCallback('jobmenu:setUniform', function()
--                         end, society, tonumber(grade), 'female', skin)
--                     end)
--                     WaitForSave = false
--                     FastTravel(vector3(LastPosition.x, LastPosition.y, LastPosition.z))
--                     TriggerEvent('skinchanger:loadSkin', myskin)
--                     Citizen.Wait(tonumber(100))
--                     TriggerServerEvent('esx_skin:save', myskin)
--                 end
--                 Citizen.Wait(tonumber(1000))
--             end
--         end, tonumber(grade), 'female', society)
--     end)
-- end

function OpenOutfitM(society, grade)
    LastPosition = GetEntityCoords(PlayerPedId())

    ESX.TriggerServerCallback('jobmenu:getPlayerSkin', function(currentSkin)
        ESX.TriggerServerCallback('jobmenu:GetJobGradeClothe', function(jobSkin)
            -- تلپورت به مکان تنظیم لباس
            FastTravel(Config.TpCoords, Config.heading)

            -- لود اسکین پایه مردانه + لباس شغلی موجود (اگر باشه)
            local baseSkin = Config.MaleDefault
            if jobSkin then
                TriggerEvent('skinchanger:loadClothes', baseSkin, jobSkin)
            else
                TriggerEvent('skinchanger:loadSkin', baseSkin)
            end

            Citizen.Wait(1000)

            -- باز کردن منوی محدود فقط به لباس‌ها (دقیقاً مثل esx_society)
            TriggerEvent('esx_skin:openRestrictedMenu', function(data, menu)
                menu.close()

                -- منوی تأیید ذخیره
                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'uniform_confirm', {
                    title    = 'آیا از ذخیره این لباس مطمئن هستید؟',
                    align    = 'top-right',
                    elements = {
                        { label = 'بله',  value = 'yes' },
                        { label = 'خیر', value = 'no' }
                    }
                }, function(data2, menu2)
                    menu2.close()

                    if data2.current.value == 'yes' then
                        TriggerEvent('skinchanger:getSkin', function(skin)
                            -- فقط کامپوننت‌های مربوط به لباس رو نگه می‌داریم
                            for k, _ in pairs(skin) do
                                if not (
                                    k == "tshirt_1" or k == "tshirt_2" or
                                    k == "torso_1" or k == "torso_2" or
                                    k == "decals_1" or k == "decals_2" or
                                    k == "arms" or
                                    k == "mask_1" or k == "mask_2" or
                                    k == "pants_1" or k == "pants_2" or
                                    k == "shoes_1" or k == "shoes_2" or
                                    k == "chain_1" or k == "chain_2" or
                                    k == "helmet_1" or k == "helmet_2" or
                                    k == "glasses_1" or k == "glasses_2" or
                                    k == "bags_1" or k == "bags_2" or
                                    k == "bproof_1" or k == "bproof_2"
                                ) then
                                    skin[k] = nil
                                end
                            end

                            -- ذخیره لباس جدید در دیتابیس
                            ESX.TriggerServerCallback('jobmenu:setUniform', function() end, society, grade, 'male', skin)
                            ESX.ShowNotification('لباس مردانه رنک ذخیره شد.')
                        end)
                    end

                    -- برگشت به موقعیت قبلی و لود اسکین اصلی
                    FastTravel(vector3(LastPosition.x, LastPosition.y, LastPosition.z))
                    if currentSkin then
                        TriggerEvent('skinchanger:loadSkin', currentSkin)
                        Citizen.Wait(100)
                        TriggerServerEvent('esx_skin:save', currentSkin)
                    end
                end, function(data2, menu2)
                    menu2.close()
                    -- اگر خیر زد، برگرده بدون ذخیره
                    FastTravel(vector3(LastPosition.x, LastPosition.y, LastPosition.z))
                    if currentSkin then
                        TriggerEvent('skinchanger:loadSkin', currentSkin)
                    end
                end,
                { -- لیست کامپوننت‌های مجاز
                    "tshirt_1", "tshirt_2", "torso_1", "torso_2", "decals_1", "decals_2", "arms",
                    "mask_1", "mask_2", "pants_1", "pants_2", "shoes_1", "shoes_2",
                    "chain_1", "chain_2", "helmet_1", "helmet_2", "glasses_1", "glasses_2",
                    "bags_1", "bags_2", "bproof_1", "bproof_2"
                })
            end, function(data, menu)
                -- اگر منو رو بست بدون ذخیره
                menu.close()
                FastTravel(vector3(LastPosition.x, LastPosition.y, LastPosition.z))
                if currentSkin then
                    TriggerEvent('skinchanger:loadSkin', currentSkin)
                end
            end,
            { -- دوباره لیست کامپوننت‌ها برای restricted menu
                "tshirt_1", "tshirt_2", "torso_1", "torso_2", "decals_1", "decals_2", "arms",
                "mask_1", "mask_2", "pants_1", "pants_2", "shoes_1", "shoes_2",
                "chain_1", "chain_2", "helmet_1", "helmet_2", "glasses_1", "glasses_2",
                "bags_1", "bags_2", "bproof_1", "bproof_2"
            })
        end, grade, 'male', society)
    end)
end

function OpenOutfitF(society, grade)
    LastPosition = GetEntityCoords(PlayerPedId())

    ESX.TriggerServerCallback('jobmenu:getPlayerSkin', function(currentSkin)
        ESX.TriggerServerCallback('jobmenu:GetJobGradeClothe', function(jobSkin)
            FastTravel(Config.TpCoords, Config.heading)

            local baseSkin = Config.FemaleDefault
            if jobSkin then
                TriggerEvent('skinchanger:loadClothes', baseSkin, jobSkin)
            else
                TriggerEvent('skinchanger:loadSkin', baseSkin)
            end

            Citizen.Wait(1000)

            TriggerEvent('esx_skin:openRestrictedMenu', function(data, menu)
                menu.close()

                -- <<< اضافه شده: فریز کردن بازیکن موقع باز شدن منوی تأیید >>>
                FreezeEntityPosition(PlayerPedId(), true)

                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'uniform_confirm', {
                    title    = 'آیا از ذخیره این لباس مطمئن هستید؟',
                    align    = 'top-right',
                    elements = {
                        { label = 'بله',  value = 'yes' },
                        { label = 'خیر', value = 'no' }
                    }
                }, function(data2, menu2)
                    menu2.close()

                    -- <<< آنفریز بعد از انتخاب "بله" >>>
                    FreezeEntityPosition(PlayerPedId(), false)

                    if data2.current.value == 'yes' then
                        TriggerEvent('skinchanger:getSkin', function(skin)
                            for k, _ in pairs(skin) do
                                if not (
                                    k == "tshirt_1" or k == "tshirt_2" or
                                    k == "torso_1" or k == "torso_2" or
                                    k == "decals_1" or k == "decals_2" or
                                    k == "arms" or
                                    k == "mask_1" or k == "mask_2" or
                                    k == "pants_1" or k == "pants_2" or
                                    k == "shoes_1" or k == "shoes_2" or
                                    k == "chain_1" or k == "chain_2" or
                                    k == "helmet_1" or k == "helmet_2" or
                                    k == "glasses_1" or k == "glasses_2" or
                                    k == "bags_1" or k == "bags_2" or
                                    k == "bproof_1" or k == "bproof_2"
                                ) then
                                    skin[k] = nil
                                end
                            end

                            ESX.TriggerServerCallback('jobmenu:setUniform', function() end, society, grade, 'female', skin)
                            ESX.ShowNotification('لباس زنانه رنک ذخیره شد.')
                        end)
                    end

                    FastTravel(vector3(LastPosition.x, LastPosition.y, LastPosition.z))
                    if currentSkin then
                        TriggerEvent('skinchanger:loadSkin', currentSkin)
                        Citizen.Wait(100)
                        TriggerServerEvent('esx_skin:save', currentSkin)
                    end
                end, function(data2, menu2)
                    menu2.close()

                    -- <<< آنفریز بعد از انتخاب "خیر" >>>
                    FreezeEntityPosition(PlayerPedId(), false)

                    FastTravel(vector3(LastPosition.x, LastPosition.y, LastPosition.z))
                    if currentSkin then
                        TriggerEvent('skinchanger:loadSkin', currentSkin)
                    end
                end,
                {
                    "tshirt_1", "tshirt_2", "torso_1", "torso_2", "decals_1", "decals_2", "arms",
                    "mask_1", "mask_2", "pants_1", "pants_2", "shoes_1", "shoes_2",
                    "chain_1", "chain_2", "helmet_1", "helmet_2", "glasses_1", "glasses_2",
                    "bags_1", "bags_2", "bproof_1", "bproof_2"
                })
            end, function(data, menu)
                menu.close()
                FastTravel(vector3(LastPosition.x, LastPosition.y, LastPosition.z))
                if currentSkin then
                    TriggerEvent('skinchanger:loadSkin', currentSkin)
                end
            end,
            {
                "tshirt_1", "tshirt_2", "torso_1", "torso_2", "decals_1", "decals_2", "arms",
                "mask_1", "mask_2", "pants_1", "pants_2", "shoes_1", "shoes_2",
                "chain_1", "chain_2", "helmet_1", "helmet_2", "glasses_1", "glasses_2",
                "bags_1", "bags_2", "bproof_1", "bproof_2"
            })
        end, grade, 'female', society)
    end)
end

-- function OpenManageGradesMenu(job)
--     LastPosition = GetEntityCoords(PlayerPedId())
--     ESX.TriggerServerCallback('jobmenu:getGrades', function(grades)
--         local elements = {}
--         for _, g in ipairs(grades) do
--             table.insert(elements, {
--                 label = g.label .. " (Grade: " .. g.grade .. ")",
--                 value = g
--             })
--         end

--         ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_grades', {
--             title = 'مدیریت رنک‌های ' .. job,
--             align = 'top-right',
--             elements = elements
--         }, function(data, menu)
--             local grade = data.current.value
--             ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'edit_grade', {
--                 title = 'ویرایش رنک ' .. grade.label,
--                 align = 'top-right',
--                 elements = {
--                     { label = '✏️ تغییر نام رنک', value = 'label' },
--                     { label = '💰 تغییر حقوق', value = 'salary' },
--                     -- { label = '👗 تغییر لباس مردانه', value = 'skin_male' },
--                     -- { label = '👚 تغییر لباس زنانه', value = 'skin_female' }
--                 }
--             }, function(d, m)
--                 if d.current.value == 'salary' then
--                     ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'edit_salary', {
--                         title = 'حقوق جدید'
--                     }, function(dialogData, dialogMenu)
--                         local newSalary = tonumber(dialogData.value)
--                         if newSalary then
--                             TriggerServerEvent('jobmenu:updateGrade', job, grade.grade, { salary = newSalary })
--                             ESX.ShowNotification('حقوق به روز شد.')
--                         end
--                         dialogMenu.close()
--                         OpenManageGradesMenu(job)
--                     end)
--                 elseif d.current.value == 'skin_male' then
--                     OpenOutfitM(job, grade.grade)
--                 elseif d.current.value == 'skin_female' then
--                     OpenOutfitF(job, grade.grade)
--                 elseif d.current.value == 'label' then
--                     ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'edit_label', {
--                         title = 'نام جدید رنک'
--                     }, function(dialogData, dialogMenu)
--                         local newLabel = dialogData.value
--                         if newLabel and newLabel ~= '' then
--                             TriggerServerEvent('jobmenu:updateGrade', job, grade.grade, { label = newLabel })
--                             ESX.ShowNotification('نام رنک به روز شد.')
--                         end
--                         dialogMenu.close()
--                         OpenManageGradesMenu(job)
--                     end)
--                 end
--             end, function(d, m) m.close() end)
--         end, function(data, menu) menu.close() end)
--     end, job)
-- end


function OpenManageGradesMenu(job)
    LastPosition = GetEntityCoords(PlayerPedId())
    ESX.TriggerServerCallback('jobmenu:getGrades', function(grades)
        local elements = {}
        for _, g in ipairs(grades) do
            table.insert(elements, {
                label = g.label .. " (Grade: " .. g.grade .. ")",
                value = g
            })
        end
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_grades', {
            title = 'مدیریت رنک‌های ' .. job,
            align = 'top-right',
            elements = elements
        }, function(data, menu)
            local grade = data.current.value

            -- ساخت المنت‌های منوی ویرایش
            local editElements = {
                { label = '✏️ تغییر نام رنک', value = 'label' },
                { label = '💰 تغییر حقوق', value = 'salary' },
            }

            -- چک کردن اینکه آیا این شغل اجازه تنظیم لباس داره یا نه
            local jobConfig = Config.JobManagement[job]
            if jobConfig and jobConfig.allowUniform then
                table.insert(editElements, { label = '👗 تغییر لباس مردانه', value = 'skin_male' })
                table.insert(editElements, { label = '👚 تغییر لباس زنانه', value = 'skin_female' })
            end

            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'edit_grade', {
                title = 'ویرایش رنک ' .. grade.label,
                align = 'top-right',
                elements = editElements
            }, function(d, m)
                if d.current.value == 'salary' then
                    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'edit_salary', {
                        title = 'حقوق جدید'
                    }, function(dialogData, dialogMenu)
                        local newSalary = tonumber(dialogData.value)
                        if newSalary then
                            TriggerServerEvent('jobmenu:updateGrade', job, grade.grade, { salary = newSalary })
                            ESX.ShowNotification('حقوق به روز شد.')
                        end
                        dialogMenu.close()
                        OpenManageGradesMenu(job)
                    end)
                elseif d.current.value == 'label' then
                    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'edit_label', {
                        title = 'نام جدید رنک'
                    }, function(dialogData, dialogMenu)
                        local newLabel = dialogData.value
                        if newLabel and newLabel ~= '' then
                            TriggerServerEvent('jobmenu:updateGrade', job, grade.grade, { label = newLabel })
                            ESX.ShowNotification('نام رنک به روز شد.')
                        end
                        dialogMenu.close()
                        OpenManageGradesMenu(job)
                    end)
                elseif d.current.value == 'skin_male' then
                    OpenOutfitM(job, grade.grade)
                elseif d.current.value == 'skin_female' then
                    OpenOutfitF(job, grade.grade)
                end
            end, function(d, m) m.close() end)
        end, function(data, menu) menu.close() end)
    end, job)
end