-- =================================================================
-- OAK HUB INTEGRATED CUSTOM GUI (ROBLOX LUA)
-- =================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- 1. Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OakHubCustomUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- 2. Create Main Frame (Main Window)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 220)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- 3. Title Bar (Draggable Header Bar)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 10)
TitleBarCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0.7, 0, 1, 0)
TitleText.Position = UDim2.new(0.05, 0, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "OAK Hub Loader"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextSize = 16
TitleText.Parent = TitleBar

-- Minimize/Collapse Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 25)
MinBtn.Position = UDim2.new(1, -35, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 14
MinBtn.Parent = TitleBar

local MinBtnCorner = Instance.new("UICorner")
MinBtnCorner.CornerRadius = UDim.new(0, 5)
MinBtnCorner.Parent = MinBtn

-- Container Frame for Inner Content
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -45)
ContentFrame.Position = UDim2.new(0, 10, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- 4. Button to Execute OAK Hub
local LoadOakBtn = Instance.new("TextButton")
LoadOakBtn.Size = UDim2.new(1, 0, 0, 35)
LoadOakBtn.Position = UDim2.new(0, 0, 0, 5)
LoadOakBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
LoadOakBtn.Text = "🚀 Exec OAK Hub"
LoadOakBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadOakBtn.Font = Enum.Font.SourceSansBold
LoadOakBtn.TextSize = 15
LoadOakBtn.Parent = ContentFrame

local LoadOakCorner = Instance.new("UICorner")
LoadOakCorner.CornerRadius = UDim.new(0, 6)
LoadOakCorner.Parent = LoadOakBtn

-- 5. Button to Toggle WalkSpeed
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(1, 0, 0, 35)
SpeedBtn.Position = UDim2.new(0, 0, 0, 48)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
SpeedBtn.Text = "⚡ WalkSpeed: Normal"
SpeedBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedBtn.Font = Enum.Font.SourceSans
SpeedBtn.TextSize = 14
SpeedBtn.Parent = ContentFrame

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedBtn

-- =================================================================
-- LOGIC & SCRIPT CONTROLS
-- =================================================================

-- Window Dragging System
local dragging, dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Window Minimize System
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    ContentFrame.Visible = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 280, 0, 35)
        MinBtn.Text = "▢"
    else
        MainFrame.Size = UDim2.new(0, 280, 0, 220)
        MinBtn.Text = "—"
    end
end)

-- Execute OAK Hub Button Listener
LoadOakBtn.MouseButton1Click:Connect(function()
    LoadOakBtn.Text = "Loading..."
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/OAK-Hub/OAK-Hub/main/loader.lua"))()
    end)
    task.wait(1)
    LoadOakBtn.Text = "✅ OAK Hub Loaded"
    LoadOakBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
end)

-- WalkSpeed Toggle Listener
local fastSpeed = false
SpeedBtn.MouseButton1Click:Connect(function()
    fastSpeed = not fastSpeed
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if fastSpeed then
            hum.WalkSpeed = 50
            SpeedBtn.Text = "⚡ WalkSpeed: Fast (50)"
            SpeedBtn.TextColor3 = Color3.fromRGB(46, 204, 113)
        else
            hum.WalkSpeed = 16
            SpeedBtn.Text = "⚡ WalkSpeed: Normal"
            SpeedBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
end)
