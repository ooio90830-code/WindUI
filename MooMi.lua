-- ===================================================
-- 1. SETTINGS & CONFIGURATION
-- ===================================================
_G.AutoFarm = false -- Global toggle (Default OFF)

-- 🖼️ โลโก้ MooMi x Hub ของคุณ
local LOGO_ASSET_ID = "rbxassetid://107147775533355" 

local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Coordinates Configuration
local FISHING_ZONES = {
    ["LegendaryZone"] = Vector3.new(450, 0, -800),
    ["EpicZone"]      = Vector3.new(200, 0, -500),
    ["NormalZone"]    = Vector3.new(100, 0, -200)
}

local TARGET_SPOT   = FISHING_ZONES["LegendaryZone"]
local SELL_NPC_POS  = Vector3.new(350, 5, -120)
local BAIT_SHOP_POS = Vector3.new(280, 5, -150)

local TRASH_RARITIES = {
    ["Common"]   = true,
    ["Uncommon"] = true,
    ["Green"]    = true,
    ["Grey"]     = true
}

-- ===================================================
-- 2. GUI CREATION (MooMi xHub with Logo & Profile)
-- ===================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MooMixHubGui"
ScreenGui.ResetOnSpawn = false

pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Window Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 320)
MainFrame.Position = UDim2.new(0.5, -160, 0.3, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Header Bar
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

-- Logo Image in Header
local HeaderLogo = Instance.new("ImageLabel")
HeaderLogo.Size = UDim2.new(0, 30, 0, 30)
HeaderLogo.Position = UDim2.new(0, 8, 0, 5)
HeaderLogo.BackgroundTransparency = 1
HeaderLogo.Image = LOGO_ASSET_ID
HeaderLogo.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 45, 0, 0)
Title.Text = "MooMi x Hub"
Title.TextColor3 = Color3.fromRGB(0, 210, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

-- Minimize Button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 26, 0, 24)
MinimizeBtn.Position = UDim2.new(1, -32, 0, 8)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 18
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Parent = Header

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 5)
BtnCorner.Parent = MinimizeBtn

-- Container Frame
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -20, 1, -50)
Container.Position = UDim2.new(0, 10, 0, 45)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

-- ===================================================
-- LOGO BANNER SECTION
-- ===================================================
local LogoBanner = Instance.new("ImageLabel")
LogoBanner.Name = "LogoBanner"
LogoBanner.Size = UDim2.new(1, 0, 0, 90)
LogoBanner.Position = UDim2.new(0, 0, 0, 0)
LogoBanner.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
LogoBanner.BorderSizePixel = 0
LogoBanner.Image = LOGO_ASSET_ID
LogoBanner.ScaleType = Enum.ScaleType.Fit
LogoBanner.Parent = Container

local BannerCorner = Instance.new("UICorner")
BannerCorner.CornerRadius = UDim.new(0, 8)
BannerCorner.Parent = LogoBanner

-- ===================================================
-- PROFILE SECTION
-- ===================================================
local ProfileFrame = Instance.new("Frame")
ProfileFrame.Name = "ProfileFrame"
ProfileFrame.Size = UDim2.new(1, 0, 0, 45)
ProfileFrame.Position = UDim2.new(0, 0, 0, 98)
ProfileFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ProfileFrame.BorderSizePixel = 0
ProfileFrame.Parent = Container

local ProfileCorner = Instance.new("UICorner")
ProfileCorner.CornerRadius = UDim.new(0, 8)
ProfileCorner.Parent = ProfileFrame

-- Avatar Image
local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Size = UDim2.new(0, 35, 0, 35)
AvatarImage.Position = UDim2.new(0, 5, 0, 5)
AvatarImage.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
AvatarImage.BorderSizePixel = 0
AvatarImage.Parent = ProfileFrame

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = AvatarImage

-- Fetch Player Headshot
task.spawn(function()
    local content, isReady = Players:GetUserThumbnailAsync(
        LocalPlayer.UserId, 
        Enum.ThumbnailType.HeadShot, 
        Enum.ThumbnailSize.Size100x100
    )
    if isReady then
        AvatarImage.Image = content
    end
end)

-- Player Names Label
local NameLabel = Instance.new("TextLabel")
NameLabel.Size = UDim2.new(1, -50, 1, 0)
NameLabel.Position = UDim2.new(0, 48, 0, 0)
NameLabel.Text = LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")"
NameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
NameLabel.TextSize = 12
NameLabel.Font = Enum.Font.SourceSansBold
NameLabel.TextXAlignment = Enum.TextXAlignment.Left
NameLabel.BackgroundTransparency = 1
NameLabel.Parent = ProfileFrame

-- ===================================================
-- CONTROLS SECTION
-- ===================================================
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, 0, 0, 38)
ToggleBtn.Position = UDim2.new(0, 0, 0, 150)
ToggleBtn.Text = "AUTO FARM: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = Container

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleBtn

-- Status Text Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 70)
StatusLabel.Position = UDim2.new(0, 0, 0, 195)
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextWrapped = true
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = Container

local function logStatus(text)
    StatusLabel.Text = "Status: " .. text
    print("[MooMi x Hub] " .. text)
end

-- ===================================================
-- 3. GUI INTERACTION LOGIC
-- ===================================================
local dragging, dragInput, dragStart, startPos

Header.InputBegan:Connect(function(input)
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

Header.InputChanged:Connect(function(input)
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

-- Minimize Logic
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame:TweenSize(UDim2.new(0, 320, 0, 40), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
        MinimizeBtn.Text = "+"
        Container.Visible = false
    else
        MainFrame:TweenSize(UDim2.new(0, 320, 0, 320), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
        MinimizeBtn.Text = "-"
        task.wait(0.15)
        Container.Visible = true
    end
end)

-- Toggle Button Logic
ToggleBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    if _G.AutoFarm then
        ToggleBtn.Text = "AUTO FARM: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
        logStatus("Starting Auto Farm loop...")
    else
        ToggleBtn.Text = "AUTO FARM: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        logStatus("Stopped.")
    end
end)

-- ===================================================
-- 4. MOVEMENT & NAVIGATION FUNCTIONS
-- ===================================================
local function walkTo(targetPosition)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true
    })

    path:ComputeAsync(rootPart.Position, targetPosition)

    if path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for _, waypoint in ipairs(waypoints) do
            if not _G.AutoFarm then break end

            if waypoint.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end

            humanoid:MoveTo(waypoint.Position)
            humanoid.MoveToFinished:Wait()
        end
    end
end

local function gotoFishingSpot()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if rootPart then
        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.zero
        rootPart.CFrame = CFrame.new(TARGET_SPOT.X, 0, TARGET_SPOT.Z)
    end
end

local function riseToSurface()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if rootPart then
        rootPart.CFrame = CFrame.new(rootPart.Position.X, 5, rootPart.Position.Z)
        task.wait(0.5)
    end
end

-- ===================================================
-- 5. INVENTORY & BAIT MANAGEMENT
-- ===================================================
local function getBaitCount()
    local count = 0
    local backpack = LocalPlayer:FindFirstChild("Backpack")

    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item.Name:match("Bait") or item.Name:match("Worm") then
                local amount = item:GetAttribute("Amount") or 1
                count = count + amount
            end
        end
    end
    return count
end

local function checkAndBuyBait()
    if getBaitCount() < 5 then
        logStatus("Bait low. Navigating to Bait Shop...")
        riseToSurface()
        walkTo(BAIT_SHOP_POS)
        
        logStatus("Buying bait...")
        -- ReplicatedStorage:WaitForChild("Events"):WaitForChild("BuyBait"):FireServer("WormBait", 100)
        task.wait(1)

        logStatus("Returning to fishing spot...")
        walkTo(Vector3.new(TARGET_SPOT.X, 5, TARGET_SPOT.Z))
    end
end

local function clearTrashFish()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character

    local items = {}
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do table.insert(items, item) end
    end
    if character then
        for _, item in ipairs(character:GetChildren()) do
            if item:IsA("Tool") then table.insert(items, item) end
        end
    end

    for _, item in ipairs(items) do
        local rarity = item:GetAttribute("Rarity") or (item:FindFirstChild("Rarity") and item.Rarity.Value)
        
        if rarity and TRASH_RARITIES[rarity] then
            logStatus("Discarding: " .. item.Name)
            item:Destroy()
            task.wait(0.1)
        end
    end
end

local function isInventoryFull()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        return #backpack:GetChildren() >= 20
    end
    return false
end

local function doFish()
    -- ReplicatedStorage:WaitForChild("Events"):WaitForChild("FishRemote"):FireServer()
    task.wait(1.5)
end

-- ===================================================
-- 6. MAIN FARMING LOOP
-- ===================================================
task.spawn(function()
    logStatus("MooMi x Hub Loaded. Toggle ON to start.")

    while true do
        if _G.AutoFarm then
            local success, err = pcall(function()
                checkAndBuyBait()

                logStatus("Teleporting to spot...")
                gotoFishingSpot()
                task.wait(0.5)

                while _G.AutoFarm and not isInventoryFull() do
                    logStatus("Fishing...")
                    doFish()
                    clearTrashFish()
                    task.wait(0.1)
                end

                if _G.AutoFarm and isInventoryFull() then
                    logStatus("Inventory full! Going to Sell NPC...")
                    riseToSurface()
                    walkTo(SELL_NPC_POS)

                    logStatus("Selling fish...")
                    -- ReplicatedStorage:WaitForChild("Events"):WaitForChild("SellFish"):FireServer()
                    task.wait(1)

                    logStatus("Walking back...")
                    walkTo(Vector3.new(TARGET_SPOT.X, 5, TARGET_SPOT.Z))
                end
            end)

            if not success then
                warn("[MooMi x Hub Error]: " .. tostring(err))
                logStatus("Error: Check Console (F9)")
            end
        end

        task.wait(0.5)
    end
end)
