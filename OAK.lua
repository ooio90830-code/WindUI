local function main()
    -- 1. Load Library
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

    -- 2. Services
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local TextChatService = game:GetService("TextChatService")
    local StarterGui = game:GetService("StarterGui")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- 3. Configuration & Target Items
    local webhookUrl = "" -- Insert your Discord Webhook URL here (optional)
    
    local topRodNames = {
        "sunken rod",
        "aurora rod",
        "destiny rod",
        "mythic rod",
        "rod"
    }

    -- 4. Notification Functions
    -- 4.1 In-Game Screen Notification
    local function sendInGameNotification(title, text, duration)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title or "Notification",
                Text = text or "",
                Duration = duration or 5
            })
        end)
    end

    -- 4.2 Discord Webhook Notification
    local function sendDiscordAlert(playerName, rodName, depth)
        if webhookUrl == "" or not webhookUrl then return end
        
        local requestFunc = syn and syn.request or http_request or request or (http and http.request)
        if not requestFunc then return end

        local payload = HttpService:JSONEncode({
            username = "OAKPVP Detector",
            embeds = {{
                title = "🎯 Target Detected!",
                color = 65280, -- Green
                fields = {
                    { name = "Player", value = playerName, inline = true },
                    { name = "Item / Rod", value = rodName, inline = true },
                    { name = "Depth (Y)", value = tostring(depth), inline = true }
                },
                timestamp = DateTime.now():ToIsoDate()
            }}
        })

        pcall(function()
            requestFunc({
                Url = webhookUrl,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = payload
            })
        end)
    end

    -- 4.3 In-Game Public Chat Announcement
    local function announceLegendaryCatch(playerName, fishOrRodName)
        local message = "🎉 [ANNOUNCEMENT] Found Player: " .. playerName .. " holding item: " .. fishOrRodName .. "! 🎉"
        
        local generalChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if generalChannel then
            pcall(function()
                generalChannel:SendAsync(message)
            end)
        else
            print(message)
        end
    end

    -- 4.4 Master Notification Function
    local function notifyAll(playerName, rodName, depth)
        -- 1. Public chat announcement
        announceLegendaryCatch(playerName, rodName)
        
        -- 2. In-game popup notification
        sendInGameNotification("🎉 Target Found!", playerName .. " holding " .. rodName .. " (Y: " .. depth .. ")", 8)
        
        -- 3. Send Discord alert
        sendDiscordAlert(playerName, rodName, depth)
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

    -- 6. Hop to Lowest Ping Server
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
                    print("[Auto-Hop] Joining Server ID: " .. bestServer.id .. " | Ping: " .. tostring(lowestPing))
                    TeleportService:TeleportToPlaceInstance(placeId, bestServer.id, LocalPlayer)
                    return
                end
            end
        end

        TeleportService:Teleport(placeId, LocalPlayer)
    end

    -- 7. Target Scanner (Underground Y < 0 & Top Rod)
    local function scanTarget()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local posY = player.Character.HumanoidRootPart.Position.Y

                -- Check if player is underground
                if posY < 0 then
                    local items = {}
                    if player:FindFirstChild("Backpack") then
                        for _, item in ipairs(player.Backpack:GetChildren()) do table.insert(items, item) end
                    end
                    for _, item in ipairs(player.Character:GetChildren()) do table.insert(items, item) end

                    for _, item in ipairs(items) do
                        if item:IsA("Tool") then
                            local itemName = string.lower(item.Name)
                            for _, rodName in ipairs(topRodNames) do
                                if string.find(itemName, rodName) then
                                    return player, item.Name, math.floor(posY)
                                end
                            end
                        end
                    end
                end
            end
        end
        return nil
    end

    -- 8. UI Setup
    local Window = Library.CreateLib("My Script OAKPVP", "DarkTheme")
    local Tab = Window:NewTab("Main Menu")
    local Section = Tab:NewSection("Auto Search & Announcer")

    Section:NewButton("Scan Current Server", "Scan current server manually", function()
        local target, rod, depth = scanTarget()
        if target then
            print("[FOUND] Player: " .. target.DisplayName .. " | Rod: " .. rod .. " | Y: " .. depth)
            notifyAll(target.DisplayName, rod, depth)
        else
            sendInGameNotification("Scan Results", "No target found in this server.", 3)
            print("[NOT FOUND] No underground target in this server.")
        end
    end)

    Section:NewButton("Hop Next Low Ping Server", "Manually hop to best ping server", function()
        hopToNextServer()
    end)

    -- 9. Automatic Search Execution Loop
    task.spawn(function()
        print("[Auto-Search] Initializing scan in 5 seconds...")
        sendInGameNotification("Auto Search", "Starting initial scan in 5 seconds...", 3)
        task.wait(5)

        local target, rod, depth = scanTarget()
        if target then
            print("[SUCCESS] Found Target: " .. target.DisplayName .. " (@" .. target.Name .. ") | Rod: " .. rod .. " | Depth Y: " .. depth)
            notifyAll(target.DisplayName, rod, depth)
        else
            print("[NOT FOUND] Target not found in current server. Hopping to next server...")
            sendInGameNotification("Auto Search", "Target not found. Switching server...", 3)
            task.wait(1)
            hopToNextServer()
        end
    end)
end

-- Start Execution
main()
