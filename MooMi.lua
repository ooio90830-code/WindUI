-- Blockspin Skip Slider + Center Auto Click with Crimson Red GUI
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")
local Title = Instance.new("TextLabel")
local SliderBtn = Instance.new("TextButton")
local ClickBtn = Instance.new("TextButton")
local CounterLabel = Instance.new("TextLabel")

-- Setup GUI Core
ScreenGui.Parent = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "BlockspinHelperGUI"

-- Main Window (เปลี่ยนเป็นพื้นหลังสีแดงเข้มดุดัน)
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(120, 15, 20) -- สีแดงเข้ม (Crimson)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 180)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- เพิ่มเส้นขอบสีแดงสว่างให้ดูมีมิติ
UIStroke.Parent = MainFrame
UIStroke.Color = Color3.fromRGB(220, 40, 50)
UIStroke.Thickness = 2

-- Title
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0, 8)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "BLOCKSPIN HELPER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18

-- Status States
local autoSkipActive = true
local autoClickActive = true
local fishCount = 0

-- 1. Auto Skip Slider Toggle Button
SliderBtn.Parent = MainFrame
SliderBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- เขียว (ON)
SliderBtn.Position = UDim2.new(0.1, 0, 0.25, 0)
SliderBtn.Size = UDim2.new(0.8, 0, 0, 32)
SliderBtn.Font = Enum.Font.SourceSansSemibold
SliderBtn.Text = "Auto Skip Slider: ON"
SliderBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderBtn.TextSize = 14

local SliderCorner = Instance.new("UICorner", SliderBtn)
SliderCorner.CornerRadius = UDim.new(0, 6)

SliderBtn.MouseButton1Click:Connect(function()
    autoSkipActive = not autoSkipActive
    if autoSkipActive then
        SliderBtn.Text = "Auto Skip Slider: ON"
        SliderBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    else
        SliderBtn.Text = "Auto Skip Slider: OFF"
        SliderBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- เทาดำเมื่อกด OFF
    end
end)

-- 2. Auto Click Center Toggle Button
ClickBtn.Parent = MainFrame
ClickBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- เขียว (ON)
ClickBtn.Position = UDim2.new(0.1, 0, 0.48, 0)
ClickBtn.Size = UDim2.new(0.8, 0, 0, 32)
ClickBtn.Font = Enum.Font.SourceSansSemibold
ClickBtn.Text = "Auto Click Center: ON"
ClickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClickBtn.TextSize = 14

local ClickCorner = Instance.new("UICorner", ClickBtn)
ClickCorner.CornerRadius = UDim.new(0, 6)

ClickBtn.MouseButton1Click:Connect(function()
    autoClickActive = not autoClickActive
    if autoClickActive then
        ClickBtn.Text = "Auto Click Center: ON"
        ClickBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    else
        ClickBtn.Text = "Auto Click Center: OFF"
        ClickBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- เทาดำเมื่อกด OFF
    end
end)

-- Counter Label
CounterLabel.Parent = MainFrame
CounterLabel.BackgroundTransparency = 1
CounterLabel.Position = UDim2.new(0, 0, 0.72, 0)
CounterLabel.Size = UDim2.new(1, 0, 0, 25)
CounterLabel.Font = Enum.Font.SourceSans
CounterLabel.Text = "Fish Caught: 0"
CounterLabel.TextColor3 = Color3.fromRGB(255, 200, 200) -- ชมพูอ่อน/ขาวอมแดง สบายตา
CounterLabel.TextSize = 14

----------------------------------------------------
-- SCRIPT LOGIC
----------------------------------------------------
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local CurrentCamera = Workspace.CurrentCamera

local hasClickedForCurrentFish = false

-- Function: Auto Skip
local function autoSkipSlider()
    if not autoSkipActive then return end
    
    local minigameUI = PlayerGui:FindFirstChild("SliderMinigame") -- ชื่อ UI มินิเกมของเกม
    if minigameUI and minigameUI.Enabled then
        local sliderBar = minigameUI:FindFirstChild("Slider")
        if sliderBar then
            game:GetService("ReplicatedStorage").Events.CompleteSlider:FireServer(true)
            hasClickedForCurrentFish = false
        end
    end
end

-- Function: Center Click
local function autoClickOnCatch()
    if not autoClickActive then return end
    
    local catchNotification = PlayerGui:FindFirstChild("FishCaughtUI") -- ชื่อ UI แสดงปลา
    if catchNotification and catchNotification.Enabled then
        if not hasClickedForCurrentFish then
            -- พิกัดกลางหน้าจอ
            local screenSize = CurrentCamera.ViewportSize
            local centerPosition = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
            
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(centerPosition)
            
            hasClickedForCurrentFish = true
            fishCount = fishCount + 1
            CounterLabel.Text = "Fish Caught: " .. tostring(fishCount)
        end
    end
end

-- Loop
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            autoSkipSlider()
            autoClickOnCatch()
        end)
    end
end)
