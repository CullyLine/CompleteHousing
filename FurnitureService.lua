-- VERSION: 0.2.0
local FurnitureService = {}

-- Default data service for saving / loading data using profile service.
local furnitureDefaultDataService = require(script:WaitForChild("FurnitureDefaultDataService"))

-- Move furniture models to ReplicatedStorage so the player can see the furniture while trying to place one.
local furnitureModels = script:WaitForChild("FurnitureModels")
furnitureModels.Parent = game.ReplicatedStorage

-- Region3 areas for each player, used for checking if a piece of furniture is being placed in a valid area.
local buildRegions = {} -- [player.Name] = Region3

local userAttemptPlaceFurnitureRemoteEvent = Instance.new("RemoteEvent", game.ReplicatedStorage)
userAttemptPlaceFurnitureRemoteEvent.Name = "UserAttemptPlaceFurnitureRemoteEvent"
local userAttemptDeleteFurnitureRemoteEvent = Instance.new("RemoteEvent", game.ReplicatedStorage)
userAttemptDeleteFurnitureRemoteEvent.Name = "UserAttemptDeleteFurnitureRemoteEvent"
local userAttemptLoadFurnitureRemoteEvent = Instance.new("RemoteEvent", game.ReplicatedStorage)
userAttemptLoadFurnitureRemoteEvent.Name = "UserAttemptLoadFurnitureRemoteEvent"

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
	primaryPart.Size = Vector3.new(size.X, primaryPart.Size.Y, size.Z)
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

-- Do the same above but for the UI.
for _, player in pairs(game.Players:GetPlayers()) do
	script.CompleteHousingUI:Clone().Parent = player:WaitForChild("PlayerGui")
end
script.CompleteHousingUI.Parent = game:GetService("StarterGui")


---- STRUCTURE ----------------------------------------------------------------
-- User is trying to place a new piece of this furniture at a certain CFrame.
userAttemptPlaceFurnitureRemoteEvent.OnServerEvent:Connect(function(player, furnitureArgs)
	-- Gather info about the furniture the player is trying to place. --
	local furnitureModelName = furnitureArgs["FurnitureModelName"]

	local positionOffsetX = furnitureArgs["PositionOffsetX"]
	local positionOffsetY = furnitureArgs["PositionOffsetY"]
	local positionOffsetZ = furnitureArgs["PositionOffsetZ"]
	local rotationOffsetY = furnitureArgs["RotationOffsetY"]

	local origin = workspace.Origin.Position

	local cframe = CFrame.new(Vector3.new(origin.X + positionOffsetX, origin.Y + positionOffsetY, origin.Z + positionOffsetZ)) 

	local canBuild = FurnitureService.canPlayerBuild(player, cframe.Position)
	if (not canBuild) then
		print("Player can't place furniture here!")
		return
	end

	-- Apply rotation
	cframe = cframe * CFrame.Angles(0, math.rad(rotationOffsetY), 0)

	local extraArgs = {
		cframe = cframe,
		player = player,
	}

	-- Create an object for this furniture, and a model for it in the workspace. --
	-- Generate a new GUID for the object, and other necessary data.
	local furnitureObject = furnitureObjectModule.new(furnitureModelName, extraArgs)

	-- Save the furniture object to the player's data. --
	local profile = furnitureDefaultDataService.GetProfile(player)
	
	-- Convert the angles to degrees before saving it. (0 - 360 degrees) It's easier for me to understand.
	local anglesX, anglesY, anglesZ = furnitureObject.ModelInstance.PrimaryPart.CFrame:ToEulerAnglesXYZ()
	anglesX = math.deg(anglesX)
	anglesY = math.deg(anglesY)
	anglesZ = math.deg(anglesZ)
	profile["Furniture"][furnitureObject.GUID] = {
		FurnitureModelName = furnitureObject.FurnitureModelName,
		PositionOffsetX = furnitureObject.ModelInstance.PrimaryPart.Position.X - workspace.Origin.Position.X,
		PositionOffsetY = furnitureObject.ModelInstance.PrimaryPart.Position.Y - workspace.Origin.Position.Y,
		PositionOffsetZ = furnitureObject.ModelInstance.PrimaryPart.Position.Z - workspace.Origin.Position.Z,
		RotationOffsetY = anglesY,
	}
end)

-- Load player's saved furniture.
local function attemptLoad(player)
	-- Gather the player's saved furniture data.
	local profile = furnitureDefaultDataService.GetProfile(player)
	local furnitureData = profile["Furniture"]

	-- For each piece of furniture in the player's data, create a new object for it.
	-- This will place the furniture in the correct position in the workspace.
	for guid, furniture in pairs(furnitureData) do
		local cframe = CFrame.new(
			Vector3.new(
				workspace.Origin.Position.X + furniture.PositionOffsetX,
				workspace.Origin.Position.Y + furniture.PositionOffsetY,
				workspace.Origin.Position.Z + furniture.PositionOffsetZ
			)
		)

		-- Apply rotation
		cframe = cframe * CFrame.Angles(0, math.rad(furniture.RotationOffsetY), 0)

		local extraArgs = {
			cframe = cframe,
			player = player,
			Load = true,
			GUID = guid,
		}

		local furnitureObject = furnitureObjectModule.new(furniture.FurnitureModelName, extraArgs)
	end
end

userAttemptLoadFurnitureRemoteEvent.OnServerEvent:Connect(function(player)
	attemptLoad(player)
end)

-- User is trying to delete the selected piece of furniture.
userAttemptDeleteFurnitureRemoteEvent.OnServerEvent:Connect(function(player, furnitureGUID)
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
end)

-- Change region of where a player is allowed to build.
FurnitureService.changePlayerBuildRegion = function(player, region : Region3)
	buildRegions[player.Name] = region

	-- Update this players value objects to reflect the new build region.
	-- This is for visuals on the client side.
	local playerData = player:WaitForChild("Data")
	local buildRegionOriginValueObject = playerData:WaitForChild("BuildRegionOrigin")
	local buildRegionSizeValueObject = playerData:WaitForChild("BuildRegionSize")
	buildRegionOriginValueObject.Value = region.CFrame.Position
	buildRegionSizeValueObject.Value = region.Size
end

-- Check if a player is allowed to build at a certain position.
FurnitureService.canPlayerBuild = function(player, position : Vector3)
	local region : Region3 = buildRegions[player.Name]
	if (region == nil) then
		return false
	end

	local inBounds = false
	local size = region.Size
	local origin = region.CFrame.Position
	local halfSize = size / 2

	if (position.X >= origin.X - halfSize.X and position.X <= origin.X + halfSize.X) then
		if (position.Y >= origin.Y - halfSize.Y and position.Y <= origin.Y + halfSize.Y) then
			if (position.Z >= origin.Z - halfSize.Z and position.Z <= origin.Z + halfSize.Z) then
				inBounds = true
			end
		end
	end

	return inBounds
end

task.wait(2)
FurnitureService.changePlayerBuildRegion(game.Players:GetChildren()[1], Region3.new(workspace.Origin.Position - Vector3.new(50, 50, 50), workspace.Origin.Position + Vector3.new(50, 50, 50)))

return FurnitureService
