-- [[ 🛠️ ตั้งค่าระบบ ]] --
local ขีดจำกัดความเร็ว = 35         -- ถ้าเกินนี้ถือว่าโกง
local ขีดจำกัดระยะทางต่อวินาที = 40  -- ถ้าวาร์ปเกินระยะนี้ถือว่าโกง

-- [[ 💻 ตัวแปรและบริการ ]] --
local บริการผู้เล่น = game:GetService("Players")
local บริการรัน = game:GetService("RunService")
local บริการGUI = game:GetService("CoreGui")
local บริการวาร์ป = game:GetService("TeleportService")
local บริการHTTP = game:GetService("HttpService")

local ผู้เล่นท้องถิ่น = บริการผู้เล่น.LocalPlayer
local สถานะระบบเปิด = true
local บันทึกตำแหน่ง = {}

-- [[ 1. ระบบมุมกล้อง FIRST PERSON ]] --
ผู้เล่นท้องถิ่น.CameraMode = Enum.CameraMode.LockFirstPerson

local function เปิดการมองเห็นตัวเอง(ตัวละคร)
	local ฮิวมานอยด์ = ตัวละคร:WaitForChild("Humanoid", 5)
	if not ฮิวมานอยด์ then return end
	
	บริการรัน.RenderStepped:Connect(function()
		if ตัวละคร and ตัวละคร.Parent then
			for _, ชิ้นส่วน in ipairs(ตัวละคร:GetChildren()) do
				if ชิ้นส่วน:IsA("BasePart") and ชิ้นส่วน.Name ~= "HumanoidRootPart" then
					ชิ้นส่วน.LocalTransparencyModifier = 0
				end
			end
		end
	end)
end

if ผู้เล่นท้องถิ่น.Character then เปิดการมองเห็นตัวเอง(ผู้เล่นท้องถิ่น.Character) end
ผู้เล่นท้องถิ่น.CharacterAdded:Connect(เปิดการมองเห็นตัวเอง)

-- [[ 2. สร้างเมนูปุ่มกด ]] --
local หน้าจอหลัก = Instance.new("ScreenGui")
หน้าจอหลัก.Name = "กล่องเครื่องมือ"
หน้าจอหลัก.Parent = บริการGUI

local function ใส่ความโค้ง(แม่)
	local มุม = Instance.new("UICorner")
	มุม.CornerRadius = UDim.new(0, 8)
	มุม.Parent = แม่
end

local ปุ่มเรดาร์ = Instance.new("TextButton")
ปุ่มเรดาร์.Size = UDim2.new(0, 160, 0, 40)
ปุ่มเรดาร์.Position = UDim2.new(0.02, 0, 0.1, 0)
ปุ่มเรดาร์.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
ปุ่มเรดาร์.Text = "เรดาร์แฮ็กเกอร์: เปิด"
ปุ่มเรดาร์.TextColor3 = Color3.fromRGB(255, 255, 255)
ปุ่มเรดาร์.Parent = หน้าจอหลัก
ใส่ความโค้ง(ปุ่มเรดาร์)

local ปุ่มย้ายแมพ = Instance.new("TextButton")
ปุ่มย้ายแมพ.Size = UDim2.new(0, 160, 0, 40)
ปุ่มย้ายแมพ.Position = UDim2.new(0.02, 0, 0.16, 0)
ปุ่มย้ายแมพ.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
ปุ่มย้ายแมพ.Text = "⚡ ย้ายเซิร์ฟเวอร์"
ปุ่มย้ายแมพ.TextColor3 = Color3.fromRGB(255, 255, 255)
ปุ่มย้ายแมพ.Parent = หน้าจอหลัก
ใส่ความโค้ง(ปุ่มย้ายแมพ)

-- [[ 3. ระบบป้ายชื่อ ]] --
local function สร้างป้ายบนหัว(ผู้เล่น, ตัวละคร)
	local หัว = ตัวละคร:WaitForChild("Head", 5)
	if not หัว then return end
	
	if หัว:FindFirstChild("RadarGui") then หัว.RadarGui:Destroy() end

	local ป้ายชื่อ = Instance.new("BillboardGui")
	ป้ายชื่อ.Name = "RadarGui"
	ป้ายชื่อ.Size = UDim2.new(0, 200, 0, 50)
	ป้ายชื่อ.StudsOffset = Vector3.new(0, 3, 0)
	ป้ายชื่อ.AlwaysOnTop = true
	ป้ายชื่อ.Enabled = สถานะระบบเปิด
	ป้ายชื่อ.Parent = หัว

	local ชื่อผู้เล่น = Instance.new("TextLabel")
	ชื่อผู้เล่น.Size = UDim2.new(1, 0, 0.5, 0)
	ชื่อผู้เล่น.BackgroundTransparency = 1
	ชื่อผู้เล่น.Text = ผู้เล่น.DisplayName
	ชื่อผู้เล่น.TextColor3 = Color3.fromRGB(255, 255, 255)
	ชื่อผู้เล่น.TextScaled = true
	ชื่อผู้เล่น.Parent = ป้ายชื่อ

	local ชื่ออุปกรณ์ = Instance.new("TextLabel")
	ชื่ออุปกรณ์.Position = UDim2.new(0, 0, 0.5, 0)
	ชื่ออุปกรณ์.Size = UDim2.new(1, 0, 0.5, 0)
	ชื่ออุปกรณ์.BackgroundTransparency = 1
	ชื่ออุปกรณ์.Text = "[ มือเปล่า ]"
	ชื่ออุปกรณ์.TextColor3 = Color3.fromRGB(255, 215, 0)
	ชื่ออุปกรณ์.TextScaled = true
	ชื่ออุปกรณ์.Parent = ป้ายชื่อ

	local function อัปเดตอุปกรณ์(ของที่ถือ)
		if ของที่ถือ:IsA("Tool") then
			ชื่ออุปกรณ์.Text = "ถือ: " .. ของที่ถือ.Name
			ชื่ออุปกรณ์.TextColor3 = Color3.fromRGB(100, 200, 255)
		end
	end

	ตัวละคร.ChildAdded:Connect(อัปเดตอุปกรณ์)
	ตัวละคร.ChildRemoved:Connect(function(ของที่ถือ)
		if ของที่ถือ:IsA("Tool") and not ตัวละคร:FindFirstChildOfClass("Tool") then
			ชื่ออุปกรณ์.Text = "[ มือเปล่า ]"
			ชื่ออุปกรณ์.TextColor3 = Color3.fromRGB(255, 215, 0)
		end
	end)
end

-- [[ 4. ระบบตรวจจับการโกง ]] --
task.spawn(function()
	while true do
		task.wait(1)
		if not สถานะระบบเปิด then continue end

		for _, ผู้เล่น in ipairs(บริการผู้เล่น:GetPlayers()) do
			local ตัวละคร = ผู้เล่น.Character
			local Root = ตัวละคร and ตัวละคร:FindFirstChild("HumanoidRootPart")
			local ฮิวมานอยด์ = ตัวละคร and ตัวละคร:FindFirstChild("Humanoid")
			local หัว = ตัวละคร and ตัวละคร:FindFirstChild("Head")
			
			if Root and ฮิวมานอยด์ and หัว then
				local ป้าย = หัว:FindFirstChild("RadarGui")
				if not ป้าย then
					สร้างป้ายบนหัว(ผู้เล่น, ตัวละคร)
					ป้าย = หัว:FindFirstChild("RadarGui")
				end

				if บันทึกตำแหน่ง[ผู้เล่น.UserId] then
					local ระยะทาง = (Root.Position - บันทึกตำแหน่ง[ผู้เล่น.UserId]).Magnitude
					if ฮิวมานอยด์.WalkSpeed > ขีดจำกัดความเร็ว or ระยะทาง > ขีดจำกัดระยะทางต่อวินาที then
						local ป้ายชื่อ = ป้าย:FindFirstChildOfClass("TextLabel")
						local ป้ายอุปกรณ์ = ป้าย:FindFirstChild("TextLabel", true) -- ค้นหา label ตัวที่สอง
						-- ปรับแต่งให้เห็นว่าเป็นแฮ็กเกอร์
						if ป้าย then
							for _, label in ipairs(ป้าย:GetChildren()) do
								if label:IsA("TextLabel") then
									label.Text = "🚨 HACKER DETECTED 🚨"
									label.TextColor3 = Color3.fromRGB(255, 0, 0)
								end
							end
						end
					end
				end
				บันทึกตำแหน่ง[ผู้เล่น.UserId] = Root.Position
			end
		end
	end
end)

-- [[ 5. ปุ่มกดคำสั่ง ]] --
ปุ่มเรดาร์.MouseButton1Click:Connect(function()
	สถานะระบบเปิด = not สถานะระบบเปิด
	ปุ่มเรดาร์.Text = สถานะระบบเปิด and "เรดาร์แฮ็กเกอร์: เปิด" or "เรดาร์แฮ็กเกอร์: ปิด"
	ปุ่มเรดาร์.BackgroundColor3 = สถานะระบบเปิด and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(170, 0, 0)
end)

ปุ่มย้ายแมพ.MouseButton1Click:Connect(function()
	local ไอดีเกม = game.PlaceId
	local url = "https://games.roblox.com/v1/games/" .. ไอดีเกม .. "/servers/Public?sortOrder=Asc&limit=100"
	local สำเร็จ, ข้อมูล = pcall(function() return บริการHTTP:JSONDecode(game:HttpGet(url)) end)
	
	if สำเร็จ and ข้อมูล and ข้อมูล.data then
		for _, เซิร์ฟเวอร์ in ipairs(ข้อมูล.data) do
			if เซิร์ฟเวอร์.playing < เซิร์ฟเวอร์.maxPlayers and เซิร์ฟเวอร์.id ~= game.JobId then
				บริการวาร์ป:TeleportToPlaceInstance(ไอดีเกม, เซิร์ฟเวอร์.id, ผู้เล่นท้องถิ่น)
				return
			end
		end
	end
	บริการวาร์ป:Teleport(ไอดีเกม, ผู้เล่นท้องถิ่น)
end)
Tab:Slider({
    Title = "Speed",
    Value = { Min = 1, Max = 10, Default = 5 },
    Step = 1, -- integer steps
    Callback = function(value)
        print("Speed:", value)
    end
})
