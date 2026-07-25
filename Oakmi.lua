local function main()
    -- 1. Load Library
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

    -- 2. Services
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- 3. Configuration & Target Items
    local topRodNames = {
        "sunken rod",
        "aurora rod",
        "destiny rod",
        "mythic rod",
        "rod"
    }

    -- 4. Auto Re-execute Helper
    local function setTeleportQueue()
        local queueFunc = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
        if queueFunc then
            -- Replace URL below with your raw script URL if hosted online
            queueFunc([[
                repeat task.wait() until game:IsLoaded()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
            ]])
        end
    end

    -- 5. Hop to Lowest Ping Server
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
                    print("[Auto-Hop] Joining Best Ping Server ID: " .. bestServer.id .. " | Ping: " .. tostring(lowestPing))
                    TeleportService:TeleportToPlaceInstance(placeId, bestServer.id, LocalPlayer)
                    return
                end
            end
        end

        TeleportService:Teleport(placeId, LocalPlayer)
    end

    -- 6. Target Scanner (Underground Y < 0 & Top Rod)
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

    -- 7. UI Setup
    local Window = Library.CreateLib("My Script OAKPVP", "DarkTheme")
    local Tab = Window:NewTab("Main Menu")
    local Section = Tab:NewSection("Auto Search & Ping Hop")

    Section:NewButton("Scan Current Server", "Scan current server manually", function()
        local target, rod, depth = scanTarget()
        if target then
            print("[FOUND] Player: " .. target.DisplayName .. " | Rod: " .. rod .. " | Y: " .. depth)
        else
            print("[NOT FOUND] No underground target in this server.")
        end
    end)

    Section:NewButton("Hop Next Low Ping Server", "Manually hop to best ping server", function()
        hopToNextServer()
    end)

    -- 8. Automatic Search Execution Loop
    task.spawn(function()
        print("[Auto-Search] Initializing scan in 5 seconds...")
        task.wait(5)

        local target, rod, depth = scanTarget()
        if target then
            print("[SUCCESS] Found Target: " .. target.DisplayName .. " (@" .. target.Name .. ") | Rod: " .. rod .. " | Depth Y: " .. depth)
            -- Stop hopping when target is found
        else
            print("[NOT FOUND] Target not found in current server. Hopping to next server...")
            hopToNextServer()
        end
    end)
end

-- Start Execution
main()
