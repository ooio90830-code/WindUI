local UserInputService = game:GetService("UserInputService")

-- Table to store coordinate history
local recordedPoints = {}

-- Function to record coordinates
local function onInputBegan(input, gameProcessed)
    -- Ignore inputs that hit UI elements (like buttons or chat)
    if gameProcessed then return end

    -- Check for mobile touch or primary mouse click
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local position = input.Position
        
        -- Append X and Y screen coordinates
        table.insert(recordedPoints, {
            x = position.X,
            y = position.Y
        })
        
        print(string.format("Recorded point: X = %.1f, Y = %.1f (Total: %d)", position.X, position.Y, #recordedPoints))
    end
end

-- Connect the listener
UserInputService.InputBegan:Connect(onInputBegan)
