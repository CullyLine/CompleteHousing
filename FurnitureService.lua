local FurnitureService = {}

-- Default data service for saving / loading data using profile service.
local furnitureDefaultDataService = require(script:WaitForChild("FurnitureDefaultDataService"))

-- Move furniture models to ReplicatedStorage so the player can see the furniture while trying to place one.
local furnitureModels = script:WaitForChild("FurnitureModels")
furnitureModels.Parent = game.ReplicatedStorage

local userAttemptPlaceFurnitureRemoteEvent = Instance.new("RemoteEvent", game.ReplicatedStorage)
userAttemptPlaceFurnitureRemoteEvent.Name = "UserAttemptPlaceFurnitureRemoteEvent"
local userAttemptDeleteFurnitureRemoteEvent = Instance.new("RemoteEvent", game.ReplicatedStorage)
userAttemptDeleteFurnitureRemoteEvent.Name = "UserAttemptDeleteFurnitureRemoteEvent"

-- Create a folder in the workspace to store all the placed furniture.
local furnitureFolder = Instance.new("Folder", workspace)
furnitureFolder.Name = "Furniture"

-- Set up all the furniture models for use with CompleteHousing.
for _, furnitureModel in pairs(furnitureModels:GetChildren()) do
	-- Put the furniture inside a new Model, copy the part "Primary" which works as both a selection box and a primary part.
	-- Set the primary part to the part "Primary" and set the CFrame of the primary part to the bounding box position, with the y value set to the bottom of the model.
	-- This is so that the furniture is placed on the ground.
	local newModel = Instance.new("Model") 
	newModel.Name = furnitureModel.Name
	furnitureModel.Parent = newModel
	newModel.Parent = furnitureModels
	local primaryPart = script:WaitForChild("FurnitureObject").Primary:Clone()
	primaryPart.Parent = newModel
	newModel.PrimaryPart = primaryPart
	local orientation, size = furnitureModel:GetBoundingBox()
	primaryPart.CFrame = CFrame.new(orientation.Position.X, orientation.Position.Y - size.Y / 2, orientation.Position.Z)
    
    -- Set the selection box to be transparent.
    primaryPart.SurfaceGui.ImageLabel.ImageTransparency = 1
end

-- FurnitureObject module script which, when an instance of it is created, contains information about a placed piece of furniture.
local furnitureObjectModule = require(script:WaitForChild("FurnitureObject"))

-- Move FurnitureLocal local script to StarterPlayerScripts, and add it to any players already in the game.
-- This handles all the local functionality for placing and deleting furniture.
for _, player in pairs(game.Players:GetPlayers()) do
	script.FurnitureLocal:Clone().Parent = player:WaitForChild("PlayerScripts")
end
script.FurnitureLocal.Parent = game.StarterPlayer.StarterPlayerScripts


---- STRUCTURE ----------------------------------------------------------------
-- User is trying to place a new piece of this furniture at a certain CFrame.
FurnitureService.userPlaceFurniture = function(player : Player, furnitureModelName : string, cframe : CFrame)
	local extraArgs = {
		cframe = cframe,
		player = player,
	}

	-- Create an object for this furniture, and a model for it in the workspace.
	-- Generate a new GUID for the object, and other necessary data.
	local furnitureObject = furnitureObjectModule.new(furnitureModelName, extraArgs)


end

userAttemptPlaceFurnitureRemoteEvent.OnServerEvent:Connect(function(player, furnitureArgs)
	local furnitureModelName = furnitureArgs["FurnitureModelName"]

	local positionOffsetX = furnitureArgs["PositionOffsetX"]
	local positionOffsetY = furnitureArgs["PositionOffsetY"]
	local positionOffsetZ = furnitureArgs["PositionOffsetZ"]

	local rotationOffsetY = furnitureArgs["RotationOffsetY"]

	local origin = workspace.Origin.Position

	local cframe = CFrame.new(Vector3.new(origin.X + positionOffsetX, origin.Y + positionOffsetY, origin.Z + positionOffsetZ))

	-- Apply rotation
	cframe = cframe * CFrame.Angles(0, math.rad(rotationOffsetY), 0)

	FurnitureService.userPlaceFurniture(player, furnitureModelName, cframe)
end)

-- User is trying to delete the selected piece of furniture.
FurnitureService.userDeleteFurniture = function(player : Player, furnitureGUID : string)
	-- Find the furniture object with the given GUID, and delete it from the workspace.
	-- Also, delete the object from the player's data.

	local userFurnitureFolder = furnitureFolder:FindFirstChild(player.Name)
	local furnitureObject = nil

	--- XXX todo: this is a bad way to do this, we should use a dictionary instead of a loop
	for _, furnitureModel in pairs(userFurnitureFolder:GetChildren()) do
		if (furnitureModel:GetAttribute("GUID") == furnitureGUID) then
			furnitureObject = furnitureModel
		end
	end

	if (not furnitureObject) then
		warn("Furniture with GUID " .. furnitureGUID .. " not found in player " .. player.Name .. "'s furniture folder.")
		return
	end

	furnitureObject:Destroy()
end 

userAttemptDeleteFurnitureRemoteEvent.OnServerEvent:Connect(function(player, furnitureGUID)
	FurnitureService.userDeleteFurniture(player, furnitureGUID)
end)

return FurnitureService
