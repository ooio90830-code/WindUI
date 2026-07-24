-- 1. Load Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- 2. Fetch Required Services
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 3. Function to find and join a server with few players
local function teleportToLowServer()
    local placeId = game.PlaceId
    local currentJobId = game.JobId
    local apiUrl = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"

    local success, response = pcall(function()
        return game:HttpGet(apiUrl)
    end)

    if success and response then
        local decoded = HttpService:JSONDecode(response)
        if decoded and decoded.data then
            for _, server in ipairs(decoded.data) do
                -- Find a server that isn't the current one and has available slots
                if server.id ~= currentJobId and server.playing < server.maxPlayers and server.playing > 0 then
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
                    return
                end
            end
        end
    end

    -- Fallback to standard teleport if no specific server is found
    TeleportService:Teleport(placeId, LocalPlayer)
end

-- 4. Create UI Window
local Window = Library.CreateLib("My Script OAKPVP", "DarkTheme")
local Tab = Window:NewTab("Main Menu")
local Section = Tab:NewSection("General Functions")

-- 5. Button for Low Player Server Hop
Section:NewButton("Server Hop (Low Players)", "Teleport to a server with few players", function()
    teleportToLowServer()
end)

-- 6. Example Toggle
Section:NewToggle("Enable Feature", "Toggle description here", function(state)
    if state then
        print("Feature Enabled")
    else
        print("Feature Disabled")
    end
end)
