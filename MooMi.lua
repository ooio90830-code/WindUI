local function initScript()
    -- 1. Load Library
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

    -- 2. Fetch Required Services
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- 3. Rod Tier Ranking Table (Customize tier names based on your game)
    local rodTiers = {
        ["mythic rod"] = 5,
        ["legendary rod"] = 4,
        ["gold rod"] = 3,
        ["silver rod"] = 2,
        ["rod"] = 1
    }

    -- 4. Function: Teleport to Best Ping Server
    local function hopToBestPingServer()
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
                    print("[Teleport] Connecting to Server ID: " .. bestServer.id .. " | Ping: " .. tostring(lowestPing))
                    TeleportService:TeleportToPlaceInstance(placeId, bestServer.id, LocalPlayer)
                    return
                end
            end
        end

        TeleportService:Teleport(placeId, LocalPlayer)
    end

    -- 5. Function: Scan Underground Players with Top Tier Rods
    local function scanUndergroundRodPlayers()
        local bestPlayer = nil
        local highestRodScore = -1
        local undergroundCount = 0

        print("--- [Scanning Underground & Rod Players] ---")

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                -- Check if player position is underground (Y axis < 0)
                local positionY = player.Character.HumanoidRootPart.Position.Y
                local isUnderground = positionY < 0 

                if isUnderground then
                    undergroundCount = undergroundCount + 1
                    local playerRodScore = 0
                    local foundRodName = "None"

                    -- Gather items from both Backpack and Character
                    local items = {}
                    if player:FindFirstChild("Backpack") then
                        for _, item in ipairs(player.Backpack:GetChildren()) do table.insert(items, item) end
                    end
                    for _, item in ipairs(player.Character:GetChildren()) do table.insert(items, item) end

                    for _, item in ipairs(items) do
                        if item:IsA("Tool") then
                            local itemNameLower = string.lower(item.Name)
                            if string.find(itemNameLower, "rod") then
                                -- Calculate rod score based on tier mapping
                                local score = 1
                                for rodKey, tierValue in pairs(rodTiers) do
                                    if string.find(itemNameLower, rodKey) then
                                        score = math.max(score, tierValue)
                                    end
                                end
                                
                                if score > playerRodScore then
                                    playerRodScore = score
                                    foundRodName = item.Name
                                end
                            end
                        end
                    end

                    -- Select player with the highest tier rod underground
                    if playerRodScore > highestRodScore then
                        highestRodScore = playerRodScore
                        bestPlayer = {
                            Player = player,
                            RodName = foundRodName,
                            PosY = math.floor(positionY)
                        }
                    end
                end
            end
        end

        -- Print Results
        print("[Underground Count] Players underground: " .. tostring(undergroundCount))
        if bestPlayer then
            print("[Top Underground Fisher] " .. bestPlayer.Player.DisplayName .. " (@" .. bestPlayer.Player.Name .. ") | Rod: " .. bestPlayer.RodName .. " | Depth Y: " .. tostring(bestPlayer.PosY))
        else
            print("[Scan Result] No underground fishing players found.")
        end

        return bestPlayer, undergroundCount
    end

    -- 6. Create UI Window & Controls
    local Window = Library.CreateLib("My Script OAKPVP", "DarkTheme")
    local Tab = Window:NewTab("Main Menu")
    local Section = Tab:NewSection("Underground & Rod Scanner")

    Section:NewButton("Hop Best Ping Server", "Teleport to the server with lowest ping", function()
        hopToBestPingServer()
    end)

    Section:NewButton("Scan Underground Fishers", "Find players underground with top tier rods", function()
        scanUndergroundRodPlayers()
    end)

    -- 7. Automatic Execution on Server Join
    task.spawn(function()
        task.wait(5)
        local bestTarget, count = scanUndergroundRodPlayers()
        
        -- Uncomment line below if you want automatic server hopping when no valid targets are found:
        -- if not bestTarget then hopToBestPingServer() end
    end)
end

-- Run Script
initScript()
