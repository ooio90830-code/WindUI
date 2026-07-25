-- 1. Load Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- 2. Fetch Required Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 3. Function to find players with a Fishing Rod
local function findFishingPlayers()
    local foundCount = 0
    print("--- Scanning for Fishing Players ---")
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local isFishing = false
            local toolName = ""

            -- Check items equipped in Character
            if player.Character then
                for _, item in ipairs(player.Character:GetChildren()) do
                    if item:IsA("Tool") and (string.find(string.lower(item.Name), "rod") or string.find(string.lower(item.Name), "fish")) then
                        isFishing = true
                        toolName = item.Name
                        break
                    end
                end
            end

            -- Check items in Backpack
            if not isFishing and player:FindFirstChild("Backpack") then
                for _, item in ipairs(player.Backpack:GetChildren()) do
                    if item:IsA("Tool") and (string.find(string.lower(item.Name), "rod") or string.find(string.lower(item.Name), "fish")) then
                        isFishing = true
                        toolName = item.Name
                        break
                    end
                end
            end

            if isFishing then
                foundCount = foundCount + 1
                print("Found: " .. player.DisplayName .. " (@" .. player.Name .. ") with tool: " .. toolName)
            end
        end
    end

    if foundCount == 0 then
        print("No fishing players found in this server.")
    end
end

-- 4. Create UI Window
local Window = Library.CreateLib("My Script OAKPVP", "DarkTheme")
local Tab = Window:NewTab("Main Menu")
local Section = Tab:NewSection("Player Tracker")

-- 5. Button to Scan Fishing Players
Section:NewButton("Scan Fishing Players", "Check current server for players with fishing rods", function()
    findFishingPlayers()
end)
