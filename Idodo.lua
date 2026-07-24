-- 1. Load Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- 2. Fetch Required Services
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 3. Function: Server Hop (Low Players)
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
                if server.id ~= currentJobId and server.playing < server.maxPlayers and server.playing > 0 then
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
                    return
                end
            end
        end
    end
    TeleportService:Teleport(placeId, LocalPlayer)
end

-- 4. Create UI Window (สามารถคลิกค้างที่แถบชื่อเพื่อลากหน้าต่างได้)
local Window = Library.CreateLib("My Script OAKPVP", "DarkTheme")
local Tab = Window:NewTab("Main Menu")
local Section = Tab:NewSection("General Functions")

-- 5. Button for Low Player Server Hop
Section:NewButton("Server Hop (Low Players)", "Teleport to a server with few players", function()
    teleportToLowServer()
end)

Section:NewToggle("Enable Feature", "Toggle description here", function(state)
    if state then print("Feature Enabled") else print("Feature Disabled") end
end)

-- 6. เพิ่ม Section ใหม่เพื่อทดสอบการเลื่อน (Scroll)
local ScrollSection = Tab:NewSection("Scroll Test (เลื่อนเมาส์ลง)")

-- ใช้ Loop เพื่อสร้างปุ่ม 20 อัน ระบบจะทำ Scrollbar ให้อัตโนมัติ
for i = 1, 20 do
    ScrollSection:NewButton("Dummy Button " .. i, "This button is for scroll testing", function()
        print("Clicked button number " .. i)
    end)
end
