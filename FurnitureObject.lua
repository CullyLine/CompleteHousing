local FurnitureObject = {}
FurnitureObject.__index = FurnitureObject

local furnitureModels = game.ReplicatedStorage:WaitForChild("FurnitureModels")
local furnitureFolder = workspace:WaitForChild("Furniture")

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

	-- Create a copy of the furniture model from ReplicatedStorage.
	self.ModelInstance = furnitureModels:FindFirstChild(FurnitureModelName):Clone()

	-- Find the user's folder in the workspace's furniture folder, or create it if it doesn't exist.
	local userFurnitureFolder = furnitureFolder:FindFirstChild(extraArgs.player.Name)
	if (not userFurnitureFolder) then
		userFurnitureFolder = Instance.new("Folder")
		userFurnitureFolder.Name = extraArgs.player.Name 
		userFurnitureFolder.Parent = furnitureFolder
	end
	
	-- Parent the new placed furniture to the user's folder in the furniture folder.
    self.ModelInstance.Parent = userFurnitureFolder

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

	-- Set the guid attribute, so we can uniquely idenity this piece of furniture.
	self.ModelInstance:SetAttribute("GUID", self.GUID)

	return self
end

-- Add your methods and properties here


return FurnitureObject