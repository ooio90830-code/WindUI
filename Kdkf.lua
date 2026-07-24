-- 1. Load Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- 2. Fetch Required Services
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 3. Function to find and join a server with the lowest ping
local function teleportToBestPingServer()
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
                -- Check if server is valid, has space, and is not the current server
                if server.id ~= currentJobId and server.playing < server.maxPlayers then
                    -- Compare ping values if available
                    if server.ping and server.ping < lowestPing then
                        lowestPing = server.ping
                        bestServer = server
                    end
                end
            end

            -- Teleport to the lowest ping server found
            if bestServer then
                TeleportService:TeleportToPlaceInstance(placeId, bestServer.id, LocalPlayer)
                return
            end
        end
    end

    -- Fallback to standard teleport if no specific server is found
    TeleportService:Teleport(placeId, LocalPlayer)
end

-- 4. Create UI Window
local Window = Library.CreateLib("My Script OAKPVP", "DarkTheme")
local Tab = Window:NewTab("Main Menu")
local Section = Tab:NewSection("Server Options")

-- 5. Button for Low Ping Server Hop
Section:NewButton("Server Hop (Best Ping)", "Teleport to a server with the lowest ping", function()
    teleportToBestPingServer()
end)

-- 6. Example Toggle
Section:NewToggle("Enable Feature", "Toggle description here", function(state)
    if state then
        print("Feature Enabled")
    else
        print("Feature Disabled")
    end
end)
