local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Magnet settings (5 standard blocks = 20 studs)
local MAGNET_RADIUS = 20 
-- Pull velocity speed (higher = faster pull)
local PULL_SPEED = 65 

-- Main function to detect and pull nearby items
local function magnetLoop()
	local character = LocalPlayer.Character
	if not character then return end
	
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	-- Scan all descendants in Workspace for dropped items
	for _, object in ipairs(workspace:GetDescendants()) do
		-- Target unanchored BaseParts that do not belong to the player
		if object:IsA("BasePart") and not object:IsDescendantOf(character) and not object.Anchored then
			
			-- Calculate 3D distance between player and the item
			local distance = (object.Position - rootPart.Position).Magnitude

			-- If the item is within 5 blocks range (20 studs)
			if distance <= MAGNET_RADIUS then
				-- Temporarily disable collision to prevent clipping on the floor
				object.CanCollide = false
				
				-- Smoothly interpolate item CFrame towards the player's root part
				object.CFrame = object.CFrame:Lerp(rootPart.CFrame, 0.3)
				
				-- Apply directional velocity pushing the item straight to the player
				object.AssemblyLinearVelocity = (rootPart.Position - object.Position).Unit * PULL_SPEED
			end
		end
	end
end

-- Run silently in the background on every frame heartbeat
RunService.Heartbeat:Connect(function()
	pcall(magnetLoop)
end)
