-- เรียกใช้งาน WindUI Library
local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()

-- ส่งการแจ้งเตือนเมื่อรันสคริปต์สำเร็จ
WindUI:Notify({
    Title = "Success",
    Content = "Operation completed successfully",
    Duration = 3
})

-- สร้างหน้าต่างหลัก (Window)
local Window = WindUI:CreateWindow({
    Title = "My Super Hub", -- window title
    Icon = "door-open", -- lucide icon or "rbxassetid://" or URL. optional
    Author = "by .ftgs and .ftgs", -- window subtitle. optional
    Theme = "Dark", -- ตั้งค่าธีมมืด
    Size = UDim2.fromOffset(450, 350),
    Transparent = false,
    Blur = true,
    ToggleKey = Enum.KeyCode.RightShift -- ปุ่มกดเปิด-ปิดเมนู
})

-- เพิ่มระบบ FPS Tag บนหน้าต่าง Window
local FPSTag = Window:Tag({
    Title = "FPS: 0",
    Color = Color3.fromRGB(100, 150, 255),
})

-- บริการพื้นฐานของระบบเกม
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local RunService = game:GetService("RunService")

-- ค่าเริ่มต้นสำหรับคำนวณ FPS
local lastUpdate = tick()
local frameCount = 0

-- ค่าเริ่มต้นของระบบล็อกเป้า
local Settings = {
    AimbotEnabled = false,
    TeamCheck = true,
    AimPart = "Head",
    Sensitivity = 0.5
}

-- สร้างแท็บตามรูปแบบที่กำหนด
local Tab = Window:Tab({
    Title = "Tab Title",
    Icon = "bird", -- optional
})

-- เพิ่มปุ่มเปิด/ปิด Aimbot ในแท็บ
Tab:Toggle({
    Title = "เปิดใช้งาน ล็อกหัว (Aimbot)",
    Callback = function(Value)
        Settings.AimbotEnabled = Value
    end
})

-- เพิ่มปุ่มเปิด/ปิดการเช็กทีมในแท็บ
Tab:Toggle({
    Title = "ไม่ล็อกพวกเดียวกัน (Team Check)",
    Callback = function(Value)
        Settings.TeamCheck = Value
    end
})

-- ข้อความแสดงชื่ออุปกรณ์ที่เป้าหมายกำลังถือ
local DeviceParagraph = Tab:Paragraph({
    Title = "อุปกรณ์ของเป้าหมาย",
    Desc = "รอการล็อกเป้าหมาย..."
})

-- ฟังก์ชันค้นหาผู้เล่นที่ใกล้เป้าเล็งที่สุด
local function GetClosestPlayer()
    local ClosestPlayer = nil
    local ShortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Settings.AimPart) then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then 
                continue 
            end

            local Pos, OnScreen = Camera:WorldToViewportPoint(player.Character[Settings.AimPart].Position)
            if OnScreen then
                local MousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local Distance = (Vector2.new(Pos.X, Pos.Y) - MousePos).Magnitude

                if Distance < ShortestDistance then
                    ClosestPlayer = player
                    ShortestDistance = Distance
                end
            end
        end
    end
    return ClosestPlayer
end

-- ฟังก์ชันตรวจจับอาวุธ/อุปกรณ์
local function GetCurrentEquippedTool(player)
    if player.Character then
        local Tool = player.Character:FindFirstChildOfClass("Tool")
        if Tool then
            return Tool.Name
        end
    end
    return "มือเปล่า (Bare Hands)"
end

-- ลูปการทำงานหลัก (อัปเดตทุกเฟรมเรต)
RunService.RenderStepped:Connect(function()
    -- [1] ระบบคำนวณและอัปเดตค่า FPS
    frameCount = frameCount + 1
    local now = tick()
    
    if now - lastUpdate >= 1 then
        local fps = math.floor(frameCount / (now - lastUpdate))
        FPSTag:SetTitle("FPS: " .. fps)
        
        if fps >= 50 then
            FPSTag:SetColor(Color3.fromRGB(0, 255, 0)) -- Green
        elseif fps >= 30 then
            FPSTag:SetColor(Color3.fromRGB(255, 200, 0)) -- Yellow
        else
            FPSTag:SetColor(Color3.fromRGB(255, 0, 0)) -- Red
        end
        
        frameCount = 0
        lastUpdate = now
    end

    -- [2] ระบบล็อกหัวและดึงชื่ออุปกรณ์
    local Target = GetClosestPlayer()
    
    if Target and Target.Character and Target.Character:FindFirstChild(Settings.AimPart) then
        -- ทำงานเมื่อเปิดใช้ Aimbot
        if Settings.AimbotEnabled then
            local TargetPosition = Target.Character[Settings.AimPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetPosition), Settings.Sensitivity)
        end

        -- อัปเดตข้อมูลอุปกรณ์ขึ้นบนหน้าต่าง WindUI
        local CurrentWeapon = GetCurrentEquippedTool(Target)
        DeviceParagraph:SetDesc("ผู้เล่น: " .. Target.Name .. " | อุปกรณ์: " .. CurrentWeapon)
    else
        -- หากไม่มีเป้าหมายให้เคลียร์ข้อความ
        DeviceParagraph:SetDesc("ไม่มีเป้าหมายในระยะเล็ง")
    end
end)
