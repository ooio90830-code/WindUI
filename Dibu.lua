-- ========================================================
--   DUBI HUB - BLOCK SPIN NPC AUTO WALK & UNDERGROUND FARM
-- ========================================================

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local CurrentCamera = Workspace.CurrentCamera

-- Configuration & States
local Flags = {
    AutoFarm = true,
    UndergroundMode = true,
    FishCaught = 0
}

-- NPC Sell Position in Block Spin
local SELL_NPC_POS = Vector3.new(350, 5, -120)

local farmSpotCFrame = nil 
local safetyPlatform = nil
local isSelling = false
local hasClickedCurrentFish = false

-- --------------------------------------------------------
-- 1. GUI Simple Red Mode
-- --------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DubiHub_BlockSpinWalk"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") or PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 310)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(110, 12, 18)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(230, 45, 55)
UIStroke.Thickness = 2

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "🔴 DUBI HUB | BLOCK SPIN"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Parent = MainFrame

local function CreateToggle(text, posY, flagKey)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.88, 0, 0, 32)
    Btn.Position = UDim2.new(0.06, 0, posY, 0)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 12
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Parent = MainFrame

    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local function RenderState()
        if Flags[flagKey] then
            Btn.BackgroundColor3 = Color3.fromRGB(40, 180, 95)
            Btn.Text = text .. " : [ ON ]"
        else
            Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            Btn.Text = text .. " : [ OFF ]"
        end
    end

    RenderState()

    Btn.MouseButton1Click:Connect(function()
        Flags[flagKey] = not Flags[flagKey]
        RenderState()
    end)

    return Btn
end

CreateToggle("Auto Farm", 0.18, "AutoFarm")
CreateToggle("Underground Mode (1 Block)", 0.32, "UndergroundMode")

-- Save Fishing Spot Button
local SetSpotBtn = Instance.new("TextButton")
SetSpotBtn.Size = UDim2.new(0.88, 0, 0, 32)
SetSpotBtn.Position = UDim2.new(0.06, 0, 0.46, 0)
SetSpotBtn.BackgroundColor3 = Color3.fromRGB(180, 80, 20)
SetSpotBtn.Font = Enum.Font.GothamSemibold
SetSpotBtn.Text = "📌 Save Spot (Stand at target location)"
SetSpotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SetSpotBtn.TextSize = 11
SetSpotBtn.Parent = MainFrame

Instance.new("UICorner", SetSpotBtn).CornerRadius = UDim.new(0, 6)

SetSpotBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        farmSpotCFrame = char.HumanoidRootPart.CFrame
        SetSpotBtn.Text = "✅ Spot Saved Successfully!"
        task.wait(1.5)
        SetSpotBtn.Text = "📌 Save Spot (Stand at target location)"
    end
end)

local CounterLabel = Instance.new("TextLabel")
CounterLabel.Size = UDim2.new(1, 0, 0, 25)
CounterLabel.Position = UDim2.new(0, 0, 0.85, 0)
CounterLabel.BackgroundTransparency = 1
CounterLabel.Font = Enum.Font.Gotham
CounterLabel.Text = "🎣 Fish Caught: 0"
CounterLabel.TextColor3 = Color3.fromRGB(255, 210, 210)
CounterLabel.TextSize = 13
CounterLabel.Parent = MainFrame

-- Hide GUI using Left Control
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- --------------------------------------------------------
-- 2. MOVEMENT & NPC WALK LOGIC
-- --------------------------------------------------------

local function UpdatePlatform(pos)
    if not safetyPlatform or not safetyPlatform.Parent then
        safetyPlatform = Instance.new("Part")
        safetyPlatform.Size = Vector3.new(6, 1, 6)
        safetyPlatform.Anchored = true
        safetyPlatform.Transparency = 1
        safetyPlatform.Parent = Workspace
    end
    safetyPlatform.CFrame = CFrame.new(pos - Vector3.new(0, 3.5, 0))
end

-- Move Character to Target Position
local function SimpleWalkTo(targetPos)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local humanoid = char.Humanoid
        humanoid:MoveTo(targetPos)
        humanoid.MoveToFinished:Wait() -- Wait until arrival
    end
end

-- Surface -> Walk to NPC -> Sell -> Return to Spot
local function WalkToSellAndBack()
    isSelling = true
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then 
        isSelling = false
        return 
    end

    local hrp = char.HumanoidRootPart
    
    -- 1. Teleport back above ground first
    if farmSpotCFrame then
        hrp.CFrame = farmSpotCFrame
    else
        hrp.CFrame = hrp.CFrame * CFrame.new(0, 4, 0)
    end
    task.wait(0.5)

    -- 2. Walk to NPC Location
    SimpleWalkTo(SELL_NPC_POS)
    task.wait(0.5)

    -- 3. Fire Sell Event
    local sellRemote = ReplicatedStorage:FindFirstChild("SellFish", true) 
                    or ReplicatedStorage:FindFirstChild("SellAll", true)
                    or ReplicatedStorage:FindFirstChild("SellItems", true)

    if sellRemote and sellRemote:IsA("RemoteEvent") then
        sellRemote:FireServer()
    end
    task.wait(1)

    -- 4. Walk back to original fishing spot
    if farmSpotCFrame then
        SimpleWalkTo(farmSpotCFrame.Position)
    end

    isSelling = false
end

-- --------------------------------------------------------
-- 3. MAIN LOOP
-- --------------------------------------------------------
task.spawn(function()
    while task.wait(0.2) do
        if Flags.AutoFarm and not isSelling then
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local hrp = char.HumanoidRootPart

                -- 1. Underground Mode (4 studs down)
                if Flags.UndergroundMode then
                    local targetCFrame = farmSpotCFrame or hrp.CFrame
                    local undergroundPos = targetCFrame * CFrame.new(0, -4, 0)
                    hrp.CFrame = undergroundPos
                    UpdatePlatform(undergroundPos.Position)
                end

                -- 2. Equip Rod
                if not char:FindFirstChildOfClass("Tool") then
                    local bp = LocalPlayer:FindFirstChild("Backpack")
                    if bp and bp:FindFirstChildOfClass("Tool") then
                        bp:FindFirstChildOfClass("Tool").Parent = char
                    end
                end

                -- 3. Cast Rod
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    local cast = tool:FindFirstChild("Click") or tool:FindFirstChild("Cast")
                    if cast then cast:FireServer() end
                end

                -- 4. Skip Slider Minigame
                for _, uiName in ipairs({"SliderMinigame", "FishingUI", "Minigame"}) do
                    local ui = PlayerGui:FindFirstChild(uiName)
                    if ui and (ui.Enabled or ui.Visible) then
                        local remote = ReplicatedStorage:FindFirstChild("CompleteSlider", true)
                        if remote then remote:FireServer(true) end
                        hasClickedCurrentFish = false
                    end
                end

                -- 5. Click Center to Catch Fish
                for _, uiName in ipairs({"FishCaughtUI", "RewardUI", "CatchUI"}) do
                    local ui = PlayerGui:FindFirstChild(uiName)
                    if ui and (ui.Enabled or ui.Visible) then
                        if not hasClickedCurrentFish then
                            local vp = CurrentCamera.ViewportSize
                            VirtualUser:CaptureController()
                            VirtualUser:ClickButton1(Vector2.new(vp.X / 2, vp.Y / 2))
                            
                            hasClickedCurrentFish = true
                            Flags.FishCaught = Flags.FishCaught + 1
                            CounterLabel.Text = "🎣 Fish Caught: " .. tostring(Flags.FishCaught)

                            -- Trigger Auto Sell Walk every 15 fish caught
                            if Flags.FishCaught % 15 == 0 then
                                task.spawn(WalkToSellAndBack)
                            end
                        end
                    end
                end
            end)
        end
    end
end)
