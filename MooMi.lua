local function main()
    -- 1. Load WindUI Library
    local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ooio90830-code/WindUI/9fcc4764be4ab0a4d0348f0b1b87727b9479b50b/Oak.lua"))()

    -- 2. Services
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- Variables Control
    local autoScanEnabled = false

    -- 3. Target Items (รวม Ultimate Fishing Rod, ปลาทอง และเบ็ดระดับสูง)
    local targetItems = {
        "ultimate fishing rod",
        "gold fish",
        "goldfish",
        "golden fish",
        "ปลาทอง",
        "sunken rod",
        "aurora rod",
        "destiny rod",
        "mythic rod"
    }

    -- 4. Auto Re-execute Helper
    local function setTeleportQueue()
        local queueFunc = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
        if queueFunc then
            queueFunc([[
                repeat task.wait() until game:IsLoaded()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/ooio90830-code/WindUI/9fcc4764be4ab0a4d0348f0b1b87727b9479b50b/Oak.lua"))()
            ]])
        end
    end

    -- 5. Server Hop Function
    local function hopToNextServer()
        setTeleportQueue()

        local placeId = game.PlaceId
        local currentJobId = game.JobId
        local apiUrl = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"

        local success, response = pcall(function()
            return game:HttpGet(apiUrl)
        end)

        if success and response then
            local decoded = HttpService:JSONDecode(response)
            if decoded and decoded.data then
                local bestServer = nil
                local lowestPing = 9999

                for _, server in ipairs(decoded.data) do
                    if server.id ~= currentJobId and server.playing < server.maxPlayers and server.playing > 0 then
                        local ping = server.ping or 999
                        if ping < lowestPing then
                            lowestPing = ping
                            bestServer = server
                        end
                    end
                end

                if bestServer then
                    TeleportService:TeleportToPlaceInstance(placeId, bestServer.id, LocalPlayer)
                    return
                end
            end
        end

        TeleportService:Teleport(placeId, LocalPlayer)
    end

    -- 6. Target Scanner Function
    local function scanTarget()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local backpack = player:FindFirstChild("Backpack")
                local character = player.Character

                local function checkItems(container)
                    if not container then return nil, nil end
                    for _, item in ipairs(container:GetChildren()) do
                        if item:IsA("Tool") then
                            local itemName = string.lower(item.Name)
                            for _, targetName in ipairs(targetItems) do
                                if string.find(itemName, targetName) then
                                    local pName = player.DisplayName .. " (@" .. player.Name .. ")"
                                    return pName, item.Name
                                end
                            end
                        end
                    end
                    return nil, nil
                end

                local pName, itemName = checkItems(backpack)
                if not pName then
                    pName, itemName = checkItems(character)
                end

                if pName then
                    return pName, itemName
                end
            end
        end
        return nil, nil
    end

    -- 7. UI Setup (WindUI)
    local Window = WindUI:CreateWindow({
        Title = "My Script OAKPVP",
        Icon = "rbxassetid://4483345998",
        Author = "Developer",
        Folder = "FishingConfig"
    })

    ---------------------------------------------------------
    -- FUNCTION 1: Manual Scanner (กดสแกน / ย้ายเซิร์ฟเอง)
    ---------------------------------------------------------
    local MainTab = Window:Tab({ Title = "Manual Scanner", Icon = "home" })

    MainTab:Button({
        Title = "Scan Current Server",
        Desc = "สแกนหาผู้เล่นที่มีเป้าหมายในเซิร์ฟเวอร์นี้ทันที",
        Callback = function()
            local playerName, itemName = scanTarget()
            if playerName then
                WindUI:Notify({
                    Title = "Found Target!",
                    Content = playerName .. " มีไอเทม: " .. itemName,
                    Duration = 6
                })
            else
                WindUI:Notify({
                    Title = "Not Found",
                    Content = "ไม่พบผู้เล่นที่มีไอเทมเป้าหมายในเซิร์ฟเวอร์นี้",
                    Duration = 3
                })
            end
        end
    })

    MainTab:Button({
        Title = "Hop Server Now",
        Desc = "ย้ายไปเซิร์ฟเวอร์ใหม่ที่ Ping ต่ำทันที",
        Callback = function()
            WindUI:Notify({
                Title = "Server Hop",
                Content = "กำลังค้นหาและย้ายเซิร์ฟเวอร์...",
                Duration = 3
            })
            hopToNextServer()
        end
    })

    ---------------------------------------------------------
    -- FUNCTION 2: Auto Hop Finder (สแกน + Auto Hop อัตโนมัติ)
    ---------------------------------------------------------
    local AutoTab = Window:Tab({ Title = "Auto Finder", Icon = "refresh-cw" })

    AutoTab:Toggle({
        Title = "Enable Auto Hop Search",
        Desc = "เปิดสแกนอัตโนมัติ หากไม่พบเป้าหมายจะทำการ Hop เซิร์ฟเวอร์ทันที",
        Value = false,
        Callback = function(state)
            autoScanEnabled = state
            if autoScanEnabled then
                WindUI:Notify({
                    Title = "Auto Finder Started",
                    Content = "กำลังเริ่มระบบค้นหาอัตโนมัติ...",
                    Duration = 3
                })

                task.spawn(function()
                    task.wait(2)
                    if not autoScanEnabled then return end

                    local playerName, itemName = scanTarget()
                    if playerName then
                        WindUI:Notify({
                            Title = "🎯 FOUND TARGET!",
                            Content = playerName .. " ถือ/มี: " .. itemName,
                            Duration = 15
                        })
                    else
                        WindUI:Notify({
                            Title = "Target Not Found",
                            Content = "ไม่พบเป้าหมาย กำลังย้ายเซิร์ฟเวอร์ใน 2 วินาที...",
                            Duration = 3
                        })
                        task.wait(2)
                        if autoScanEnabled then
                            hopToNextServer()
                        end
                    end
                end)
            else
                WindUI:Notify({
                    Title = "Auto Finder Stopped",
                    Content = "ปิดการทำงาน Auto Hop เรียบร้อยแล้ว",
                    Duration = 3
                })
            end
        end
    })
end

-- Run Script
main()
