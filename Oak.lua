local function main()
    -- 1. Load Library
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

    -- 2. Services
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local StarterGui = game:GetService("StarterGui")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- Variables Control
    local autoScanEnabled = false

    -- 3. Target Items
    local targetItems = {
        "gold fish",
        "goldfish",
        "golden fish",
        "ปลาทอง",
        "sunken rod",
        "aurora rod",
        "destiny rod",
        "mythic rod"
    }

    -- 4. Notification Helper
    local function sendNotification(title, text, duration)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = duration or 5
            })
        end)
    end

    -- 5. Auto Re-execute Helper
    local function setTeleportQueue()
        local queueFunc = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
        if queueFunc then
            queueFunc([[
                repeat task.wait() until game:IsLoaded()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
            ]])
        end
    end

    -- 6. Server Hop Function
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

    -- 7. Target Scanner Function
    local function scanTarget()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local items = {}
                
                if player:FindFirstChild("Backpack") then
                    for _, item in ipairs(player.Backpack:GetChildren()) do table.insert(items, item) end
                end
                for _, item in ipairs(player.Character:GetChildren()) do table.insert(items, item) end

                for _, item in ipairs(items) do
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
            end
        end
        return nil, nil
    end

    -- 8. UI Window Setup
    local Window = Library.CreateLib("My Script OAKPVP", "DarkTheme")

    ---------------------------------------------------------
    -- TAB 1: Manual Control (สแกน/ย้ายเซิร์ฟแบบกดมือ)
    ---------------------------------------------------------
    local MainTab = Window:NewTab("Main Scanner")
    local MainSection = MainTab:NewSection("Manual Finder")
    local statusLabel = MainSection:NewLabel("Status: Idle")

    MainSection:NewButton("Scan Current Server", "สแกนหาไอเทมในเซิร์ฟเวอร์นี้ทันที", function()
        statusLabel:UpdateLabel("Status: Scanning...")
        local playerName, itemName = scanTarget()
        if playerName then
            statusLabel:UpdateLabel("Found: " .. playerName)
            sendNotification("🐠 พบเป้าหมาย!", "ผู้เล่น: " .. playerName .. "\nถือ/มี: " .. itemName, 10)
        else
            statusLabel:UpdateLabel("Status: Not Found")
            sendNotification("Scan Result", "ไม่พบเป้าหมายในเซิร์ฟเวอร์นี้", 3)
        end
    end)

    MainSection:NewButton("Hop Server Now", "ย้ายเซิร์ฟเวอร์ทันที", function()
        statusLabel:UpdateLabel("Status: Hopping...")
        hopToNextServer()
    end)

    ---------------------------------------------------------
    -- TAB 2: Auto Loop Function (สแกน + Auto Hop อัตโนมัติ)
    ---------------------------------------------------------
    local AutoTab = Window:NewTab("Auto Finder")
    local AutoSection = AutoTab:NewSection("Auto Hop & Detector")
    local autoStatusLabel = AutoSection:NewLabel("Auto Status: Disabled")

    AutoSection:NewToggle("Enable Auto Hop Search", "เปิดการทำงานสแกนอัตโนมัติ หากไม่เจอจะ Hop ทันที", function(state)
        autoScanEnabled = state
        if autoScanEnabled then
            autoStatusLabel:UpdateLabel("Auto Status: Running...")
            task.spawn(function()
                task.wait(2)
                if not autoScanEnabled then return end
                
                local playerName, itemName = scanTarget()
                if playerName then
                    autoStatusLabel:UpdateLabel("Found: " .. playerName)
                    sendNotification("🐠 พบเป้าหมาย!", "ผู้เล่น: " .. playerName .. "\nถือ/มี: " .. itemName, 15)
                else
                    autoStatusLabel:UpdateLabel("Not found. Hopping in 2s...")
                    sendNotification("Auto Hop", "ไม่พบเป้าหมาย กำลังย้ายเซิร์ฟเวอร์...", 3)
                    task.wait(2)
                    if autoScanEnabled then
                        hopToNextServer()
                    end
                end
            end)
        else
            autoStatusLabel:UpdateLabel("Auto Status: Disabled")
        end
    end)
end

-- Start Execution
main()
