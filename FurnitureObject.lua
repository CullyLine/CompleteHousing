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
	local newFurnitureModel = furnitureModels:FindFirstChild(FurnitureModelName):Clone()

	-- Set the selection box to be transparent.
	--self.ModelInstance.Primary.SurfaceGui.ImageLabel.ImageTransparency = 1

	-- Put the furniture inside a new Model, copy the part "Primary" which works as both a selection box and a primary part.
	-- Set the primary part to the part "Primary" and set the CFrame of the primary part to the bounding box position, with the y value set to the bottom of the model.
	-- This is so that the furniture is placed on the ground.
	local newModel = Instance.new("Model") 
	newModel.Name = "Furniture"
	newFurnitureModel.Parent = newModel
	newModel.Parent = workspace
	local primaryPart = script.Primary:Clone()
	primaryPart.Parent = newModel
	newModel.PrimaryPart = primaryPart
	local orientation, size = newFurnitureModel:GetBoundingBox()
	primaryPart.CFrame = CFrame.new(orientation.Position.X, orientation.Position.Y - size.Y / 2, orientation.Position.Z)

	self.ModelInstance = newModel

	-- Set the primary part's CFrame to the one provided in the extraArgs.
	self.ModelInstance:SetPrimaryPartCFrame(extraArgs.cframe)

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