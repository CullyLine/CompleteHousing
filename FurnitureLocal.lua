local userInputService = game:GetService("UserInputService")

-- FurnitureModels for previewing furniture before placing it.
local furnitureModels = game.ReplicatedStorage:WaitForChild("FurnitureModels")

local ghost = nil

local mouse = game.Players.LocalPlayer:GetMouse()

local userAttemptPlaceFurnitureRemoteEvent = game.ReplicatedStorage:WaitForChild("UserAttemptPlaceFurnitureRemoteEvent")

local userRotation = Vector3.new(0, 0, 0)
local rotationInterval = 15

task.wait(2)

-- Create a ghost model of the furniture the player is trying to place.
ghost = furnitureModels:FindFirstChild("BrownChair"):Clone()
ghost.Parent = workspace
ghost.PrimaryPart.SurfaceGui.ImageLabel.ImageTransparency = 0
for _, p in pairs(ghost:GetDescendants()) do
    if (p.Name == "Primary") then
        continue
    end

    if (p:IsA("MeshPart")) then
        p.Transparency = 0.5
    end
end

-- Move the "ghost" or preview furniture to the position of the mouse each frame.
game:GetService("RunService").RenderStepped:Connect(function(dt)
    local mouse = game.Players.LocalPlayer:GetMouse()

    -- Ignore the ghost model when raycasting.
    mouse.TargetFilter = ghost
    if (not mouse.Target) then
        return
    end
    
    -- Lock the ghost model to the grid.
    local gridPos = Vector3.new(math.round(mouse.Hit.X), mouse.Hit.Y, math.round(mouse.Hit.Z))

    -- Move the ghost furniture to the new position.
    ghost:SetPrimaryPartCFrame(CFrame.new(gridPos) * CFrame.Angles(0, math.rad(userRotation.Y), 0))
end)

-- User is trying to place the furniture.
local function attemptPlaceFurniture()
    if (not ghost) then
        return
    end

    -- Put all the info of the ghost object into a dictionary named "furnitureArgs".
    -- The position offset is the difference between the ghost's position and the origin of the player plot's origin,
    -- this is to make sure the furniture is placed in the correct position, no matter where the player's plot is.
    -- Send all of this info about what piece of furniture the players wants to place, and where,
    -- to the server, where we can check if the player is allowed to place the furniture in the desired location.
    -- If the player is allowed to place the furniture, we can then place the furniture in the desired location, but on the server,
    -- so it replicates / is shown to all players in the game.
    local furnitureArgs = {}
    local origin = workspace.Origin.Position
    furnitureArgs["PositionOffsetX"] = ghost.PrimaryPart.Position.X - origin.X
    furnitureArgs["PositionOffsetY"] = ghost.PrimaryPart.Position.Y - origin.Y
    furnitureArgs["PositionOffsetZ"] = ghost.PrimaryPart.Position.Z - origin.Z
    furnitureArgs["RotationOffsetX"] = 0
    furnitureArgs["RotationOffsetY"] = userRotation.Y
    furnitureArgs["RotationOffsetZ"] = 0
    furnitureArgs["FurnitureModelName"] = ghost.Name

    userAttemptPlaceFurnitureRemoteEvent:FireServer(furnitureArgs)
end

-- Player clicked while moving the ghost furniture.
mouse.Button1Up:Connect(function()
    attemptPlaceFurniture()
end)

-- Player is trying to rotate the furniture.
-- Pass true to rotate the furniture to the right, and false to rotate the furniture to the left.
local function rotateFurniture(direction)
    -- Calculate how far to rotate the furniture based off the direction.
    local rotation = 0
    rotation = rotationInterval
    if (direction == true) then
        rotation = -rotation
    elseif (direction == false) then

    else
        error("Direction param must be true to rotate right, and false to rotate left.")
        return
    end

    userRotation += Vector3.new(0, rotation, 0)
end

-- Player pressed E or Q to rotate the furniture.
userInputService.InputEnded:Connect(function(input: InputObject, processed)
    if (processed) then
        return
    end

    if (input.KeyCode == Enum.KeyCode.E) then
        rotateFurniture(true)
    elseif (input.KeyCode == Enum.KeyCode.Q) then
        rotateFurniture(false)
    end
end)

-- Player used scroll wheel to rotate the furniture.
userInputService.InputChanged:Connect(function(input: InputObject)
    if (input.UserInputType == Enum.UserInputType.MouseWheel) then
        if (input.Position.Z > 0) then
            rotateFurniture(true)
        else
            rotateFurniture(false)
        end
    end
end)