local userInputService = game:GetService("UserInputService")

-- FurnitureModels for previewing furniture before placing it.
local furnitureModels = game.ReplicatedStorage:WaitForChild("FurnitureModels")

local mouse = game.Players.LocalPlayer:GetMouse()

-- Furniture placing variables.
local userAttemptPlaceFurnitureRemoteEvent = game.ReplicatedStorage:WaitForChild("UserAttemptPlaceFurnitureRemoteEvent")
local userAttemptDeleteFurnitureRemoteEvent = game.ReplicatedStorage:WaitForChild("UserAttemptDeleteFurnitureRemoteEvent")
local ghost = nil
local userRotation = Vector3.new(0, 0, 0)
local rotationInterval = 15

-- Lock furniture placement to the grid.
local gridLock = true

-- Can furniture collide with other furniture while placing.
local furnitureCollision = true

-- Furniture "Mode" (placing, deleting, etc.)
local furnitureMode = "placing"

-- Furniture highlight object, used to highlight the currently selected piece of furniture, specifically for deleting and moving it.
local currentlySelectedFurniture = nil
local currentlySelectedFurnitureHighlight = script:WaitForChild("CurrentlySelectedFurnitureHighlight")

-- Collision check part, follows the furniture around to check if it collides with other furniture / objects.
local collisionCheckPart = script:WaitForChild("CollisionCheckPart")
collisionCheckPart.Parent = nil

-- Function variables, defined here and then assigned lower in the code so we may use the functions anywhere in the code.
local changeMode = nil

-- UI variables
local screenUI = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("CompleteHousingUI")
local hotbar = screenUI:WaitForChild("Hotbar")
local furnitureScrollingFrame = hotbar:WaitForChild("Furniture")
local templateFurniture = furnitureScrollingFrame:WaitForChild("TemplateFurniture")
templateFurniture.Parent = nil
local options = screenUI:WaitForChild("Options")

task.wait(2)


-- STRUCTURE --------------------------------------------------------------------------------------------------------

-- Create a ghost model of the furniture the player is trying to place.
local function switchGhostModel(furnitureName)
    if (ghost) then
        ghost:Destroy()
        ghost = nil
    end

    ghost = furnitureModels:FindFirstChild(furnitureName):Clone()
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
end

-- Setup the UI hotbar selection frame for all the furniture.
for _, furniture in pairs(furnitureModels:GetChildren()) do
    local newFurniture = templateFurniture:Clone()
    newFurniture.Name = furniture.Name
    newFurniture.Parent = furnitureScrollingFrame

    local viewportFrame = newFurniture:FindFirstChild("ViewportFrame")
    local furnitureModel = furniture:Clone()
    furnitureModel.Parent = viewportFrame
    furnitureModel:SetPrimaryPartCFrame(CFrame.new(Vector3.new(0, 0, 0)))
    local camera = Instance.new("Camera")
    camera.Parent = viewportFrame
    local boundingBox = furnitureModel:GetBoundingBox()
    camera.CFrame = CFrame.new(boundingBox.Position + furnitureModel.PrimaryPart.CFrame.LookVector * -5, boundingBox.Position)
    
    viewportFrame.CurrentCamera = camera

    newFurniture.MouseButton1Click:Connect(function()
        if (furnitureMode ~= "placing") then
            changeMode("placing")
        end
        switchGhostModel(furniture.Name)
    end)
end

local getSize = furnitureScrollingFrame.UIListLayout.AbsoluteContentSize
furnitureScrollingFrame.CanvasSize = UDim2.new(0, getSize.X, 0, getSize.Y)

-- Find the upper most model of a part.
-- Helpful for raycasting, an example in this code is for when the player is trying to delete a piece of furniture.
-- If you raycast, and it hits a part multiple models deep inside the furniture, it will grab the top most model.
-- I had to add this because of a seat part which was many models inside a chair, hovering over it would not highlight the furniture.
-- https://devforum.roblox.com/t/getting-the-last-parent/1298499
local function GetUpperMostModel(Part,TargetedParent)
    TargetedParent = TargetedParent or workspace
    local Parent = Part.Parent
    if (Parent:IsA("Folder")) then
        return Part
    end
    if Parent == game then error("Failed to get model from "..(Part.Name)) end
    return Parent ~= TargetedParent and GetUpperMostModel(Parent,TargetedParent) or Part
end

-- Move the "ghost" or preview furniture to the position of the mouse each frame.
game:GetService("RunService").RenderStepped:Connect(function(dt)
    -- Reset these variables each frame.
    currentlySelectedFurniture = nil
    currentlySelectedFurnitureHighlight.Adornee = nil
    --collisionCheckPart.Parent = nil

    -- If player is currently placing furniture, run all this code each frame.
    if (furnitureMode == "placing") then
        if (not ghost) then
            return
        end

         -- Ignore the ghost model when raycasting.
        mouse.TargetFilter = ghost
        if (not mouse.Target) then
            return
        end
        
        -- Lock the ghost model to the grid.
        local gridPos = nil
        if (gridLock) then
            gridPos = Vector3.new(math.round(mouse.Hit.X), mouse.Hit.Y, math.round(mouse.Hit.Z))
        else
            gridPos = Vector3.new(mouse.Hit.X, mouse.Hit.Y, mouse.Hit.Z)
        end

        -- Move the ghost furniture to the new position.
        ghost:SetPrimaryPartCFrame(CFrame.new(gridPos) * CFrame.Angles(0, math.rad(userRotation.Y), 0))

        if (furnitureCollision) then
             -- Move the collision check part.
            -- Set the size to the bounding box size of the ghost model.
            local bbcframe, bbsize = ghost:GetBoundingBox()
            collisionCheckPart.Size = bbsize
            collisionCheckPart.CFrame = bbcframe
            collisionCheckPart.Parent = workspace

            -- Check for collisions using GetPartsInPart
            local overlapParams = OverlapParams.new()
            overlapParams.FilterDescendantsInstances = {ghost, workspace.Baseplate}
            overlapParams.MaxParts = 1
            local parts = workspace:GetPartsInPart(collisionCheckPart, overlapParams)
            if (#parts > 0) then
                --print("Colliding")
            end
        end
    elseif (furnitureMode == "deleting") then
        -- If the player is currently deleting furniture, run all this code each frame.
        -- Raycast to see if the player is looking at a piece of furniture.
        local unitRay = workspace.CurrentCamera:ScreenPointToRay(mouse.X, mouse.Y)
        local raycast : RaycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 100)
        if (raycast and raycast.Instance) then
            -- Grab the upper most model of this part which was hit, more info in the function "GetUpperMostModel".
            -- "FindFirstAncestor" sometimes does not work, so we have to use this function to get the top most model, leaving as an example.
            --local upperParent = raycast.Instance:FindFirstAncestorWhichIsA("Model")
            local upperMostModel = GetUpperMostModel(raycast.Instance)
            if (upperMostModel) then
                -- Check to see if it has a GUID
                if (not upperMostModel:GetAttribute("GUID")) then
                    return
                end

                currentlySelectedFurniture = upperMostModel
                currentlySelectedFurnitureHighlight.Adornee = upperMostModel
            end
        end
    end
   
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

-- User is trying to delete the currently selected furniture.
local function attemptDeleteFurniture()
    if (currentlySelectedFurniture) then
        userAttemptDeleteFurnitureRemoteEvent:FireServer(currentlySelectedFurniture:GetAttribute("GUID"))
    end
end

-- Player left clicked with a PC mouse.
mouse.Button1Up:Connect(function()
    if (furnitureMode == "placing") then
        -- Place furniture on PC.
        attemptPlaceFurniture()
    elseif (furnitureMode == "deleting") then
        -- Delete furniture on PC.
        attemptDeleteFurniture()
    end
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

-- Handle all the input (keybinds).
userInputService.InputEnded:Connect(function(input: InputObject, processed)
    if (processed) then
        return
    end

    if (input.KeyCode == Enum.KeyCode.E) then
        -- Rotate right on keyboard.
        rotateFurniture(true)
    elseif (input.KeyCode == Enum.KeyCode.Q) then
        -- Rotate left on keyboard.
        rotateFurniture(false)
    elseif (input.KeyCode == Enum.KeyCode.F) then
        -- Switch furniture mode on keyboard.
        changeMode("deleting")
    elseif (input.KeyCode == Enum.KeyCode.G) then
        -- Switch furniture mode on keyboard.
        --changeMode("placing")
    end
end)

-- Player used scroll wheel on a PC mouse to rotate the furniture.
userInputService.InputChanged:Connect(function(input: InputObject)
    -- Commented out, scroll wheel also zooms in / out the camera.
    -- if (input.UserInputType == Enum.UserInputType.MouseWheel) then
    --     if (input.Position.Z > 0) then
    --         rotateFurniture(true)
    --     else
    --         rotateFurniture(false)
    --     end
    -- end
end)

-- Change to a new furniture edit mode ("placing", "deleting", "moving")
changeMode = function(newMode)
    if (newMode == "placing") then

    elseif (newMode == "deleting") then
        if (ghost) then
            ghost:Destroy()
        end


    end

    furnitureMode = newMode
end

options:WaitForChild("Gridlock").MouseButton1Click:Connect(function()
    if (not gridLock) then
        gridLock = true
        options.Gridlock.Image = "rbxassetid://16964591433"
    else
        gridLock = false
        options.Gridlock.Image = "rbxassetid://16964589061"
    end
end)