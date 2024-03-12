local FurnitureObject = {}
FurnitureObject.__index = FurnitureObject

local furnitureModels = script.Parent.FurnitureModels

function FurnitureObject.new(FurnitureModelName, extraArgs)
    local self = setmetatable({}, FurnitureObject)
    
    -- Model which is cloned to create the furniture in the workspace.
    self.OriginalModel = nil

    -- Instance of the model in the workspace.
    self.ModelInstance = nil

    -- Name of the furniture model.
    self.FurnitureModelName = FurnitureModelName

    -- Unique identifier for this piece of furniture.
    self.GUID = nil

    -- Create the furniture model in the workspace.
    self.ModelInstance = furnitureModels:FindFirstChild(FurnitureModelName):Clone()
    self.ModelInstance.Parent = workspace

    -- Set the selection box to be transparent.
    self.ModelInstance.Primary.SurfaceGui.ImageLabel.ImageTransparency = 1

    -- Set the primary part's CFrame to the one provided in the extraArgs.
    self.ModelInstance:SetPrimaryPartCFrame(extraArgs.CFrame)

    -- extraArgs.Load is true if we are loading an existing piece of furniture saved in the player's data, 
    -- and false or nil if we are creating a new one, because the player is trying to place a new piece of furniture.
    if (extraArgs.Load) then
        -- This is an existing piece of furniture, so we need to load its data from the extraArgs.
        self.GUID = extraArgs.GUID
    else
        -- This is a new piece of furniture, so we need to generate a new GUID for it.
        self.GUID = game:GetService("HttpService"):GenerateGUID(false)    
    end



    return self
end

-- Add your methods and properties here


return FurnitureObject