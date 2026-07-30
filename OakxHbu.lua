-- Global settings
getgenv().AutoHop = false -- Set to true if you want it to hop automatically on load

-- Services
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ooio90830-code/WindUI/b95c3e2b673b50c5ab4a96f3357ab3c49e2cb6ea/MooMi.lua"))()

-- Declare self as a Dibu user (Optional: allows other scanners to detect you)
Players.LocalPlayer:SetAttribute("UsingScript", "Dibu")

--------------------------------------------------
-- CORE FUNCTIONS
--------------------------------------------------

-- 1. Scan current server for Dibu users
local function scanCurrentServer()
    local foundUsers = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        -- Check if player has the Dibu identifier attribute
        if player:GetAttribute("UsingScript") == "Dibu" or player:GetAttribute("DibuActive") == true then
            table.insert(foundUsers, player.Name .. " (@" .. player.DisplayName .. ")")
        end
    end
    
    return foundUsers
end

-- 2. Save found players to a local text file
local function saveResultsToFile(userList)
    if #userList == 0 or not writefile then return end
    
    local fileName = "Dibu_Players_Found.txt"
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local logData = "[" .. timestamp .. " | Server: " .. game.JobId .. "]\n"
    
    for _, name in ipairs(userList) do
        logData = logData .. " - " .. name .. "\n"
    end
    logData = logData .. "-----------------------------------\n"
    
    if isfile and isfile(fileName) then
        appendfile(fileName, logData)
    else
        writefile(fileName, logData)
    end
end

-- 3. Hop to a different server
local function hopToNextServer()
    local placeId = game.PlaceId
    local serversUrl = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/0?sortOrder=Asc&limit=100"
    
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(serversUrl))
    end)
    
    if success and response and response.data then
        for _, server in ipairs(response.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                TeleportService:TeleportToPlaceInstance(placeId, server.id, Players.LocalPlayer)
                return
            end
        end
    end
    
    warn("No suitable server found to hop.")
end

--------------------------------------------------
-- WIND UI INTEGRATION
--------------------------------------------------

-- Create Window (Adjust window creation syntax if your WindUI version differs)
local Window = WindUI:CreateWindow({
    Title = "Dibu Global Scanner",
    Folder = "DibuScanner",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true
})

local MainTab = Window:Tab({ Title = "Scanner Setup" })

-- Add UI Buttons & Toggles
MainTab:Button({
    Title = "Scan Current Server",
    Callback = function()
        local results = scanCurrentServer()
        if #results > 0 then
            saveResultsToFile(results)
            WindUI:Notify({ Title = "Scan Complete", Content = "Found " .. #results .. " Dibu user(s)! Saved to file." })
        else
            WindUI:Notify({ Title = "Scan Complete", Content = "No Dibu users found in this server." })
        end
    end
})

MainTab:Button({
    Title = "Server Hop Now",
    Callback = function()
        WindUI:Notify({ Title = "Teleporting", Content = "Finding a new server..." })
        hopToNextServer()
    end
})

MainTab:Toggle({
    Title = "Auto-Scan & Hop Loop",
    Default = getgenv().AutoHop,
    Callback = function(value)
        getgenv().AutoHop = value
        if value then
            task.spawn(function()
                while getgenv().AutoHop do
                    local results = scanCurrentServer()
                    if #results > 0 then
                        saveResultsToFile(results)
                    end
                    task.wait(3) -- Wait 3 seconds before hopping
                    hopToNextServer()
                    task.wait(5)
                end
            end)
        end
    end
})
