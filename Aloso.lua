-- 1. Load Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- 2. Fetch Required Services
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 3. Create Window
local Window = Library.CreateLib("My Script OAKPVP", "DarkTheme")

-- 4. Create Tab and Section
local Tab = Window:NewTab("Main Menu")
local Section = Tab:NewSection("General Functions")

-- 5. Button for Server Hop (Rejoin/Switch Server)
Section:NewButton("Server Hop", "Teleport to a new server", function()
    local success, errorMessage = pcall(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
    
    if not success then
        warn("Failed to teleport: " .. tostring(errorMessage))
    end
end)

-- 6. Example Toggle
Section:NewToggle("Enable Feature", "Toggle description here", function(state)
    if state then
        print("Feature Enabled")
    else
        print("Feature Disabled")
    end
end)
