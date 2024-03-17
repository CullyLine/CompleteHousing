local FurnitureService = {}

-- Move furniture models to ReplicatedStorage so the player can see the furniture while trying to place one.
local furnitureModels = script:WaitForChild("FurnitureModels")
furnitureModels.Parent = game.ReplicatedStorage

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

-- User is trying to place a new piece of this furniture at a certain CFrame.
FurnitureService.userPlaceFurniture = function(player : Player, furnitureModelName : string, cframe : CFrame)
	local extraArgs = {
		cframe = cframe
	}

	-- Create an object for this furniture, and a model for it in the workspace.
	-- Generate a new GUID for the object, and other necessary data.
	local furnitureObject = furnitureObjectModule.new(furnitureModelName, extraArgs)


end

-- game.ReplicatedStorage.DevRemoteEvent.OnServerEvent:Connect(function(player, furnitureModelName, cframe)
-- 	FurnitureService.userPlaceFurniture(player, furnitureModelName, cframe)
-- end)

game.ReplicatedStorage.DevRemoteEvent.OnServerEvent:Connect(function(player, furnitureArgs)
	local furnitureModelName = furnitureArgs["FurnitureModelName"]

	local positionOffsetX = furnitureArgs["PositionOffsetX"]
	local positionOffsetY = furnitureArgs["PositionOffsetY"]
	local positionOffsetZ = furnitureArgs["PositionOffsetZ"]

	local origin = workspace.Origin.Position

	local cframe = CFrame.new(Vector3.new(origin.X + positionOffsetX, origin.Y + positionOffsetY, origin.Z + positionOffsetZ))

	FurnitureService.userPlaceFurniture(player, furnitureModelName, cframe)
end)

-- User is trying to delete the selected piece of furniture.
FurnitureService.userDeleteFurniture = function(player : Player, furnitureGUID : string)
	-- Find the furniture object with the given GUID, and delete it from the workspace.
	-- Also, delete the object from the player's data.


end

-- FurnitureService.placeFurniture = function(player : Player, furnitureArgs)
-- 	local furnitureModel = furnitureModels:FindFirstChild(furnitureArgs["FurnitureID"]):Clone()
-- 	furnitureModel.Parent = workspace
-- 	local origin = workspace.Origin.Position
-- 	furnitureModel:SetPrimaryPartCFrame(
-- 		CFrame.new(Vector3.new(origin.X + furnitureArgs["PositionOffsetX"], origin.Y + furnitureArgs["PositionOffsetY"], origin.Z + furnitureArgs["PositionOffsetZ"]))
-- 		* CFrame.Angles(math.rad(furnitureArgs["RotationOffsetX"]), math.rad(furnitureArgs["RotationOffsetY"]), math.rad(furnitureArgs["RotationOffsetZ"]))
-- 	)
-- 	furnitureModel.Primary.SurfaceGui.ImageLabel.ImageTransparency = 1
-- 	furnitureArgs["New"] = false
-- 	if (not furnitureArgs["GUID"]) then
-- 		furnitureArgs["UserID"] = player.UserId
-- 		furnitureArgs["GUID"] = game:GetService("HttpService"):GenerateGUID(false)
-- 		furnitureArgs["New"] = true
-- 		table.insert(dataService.data[player.Name]["Furniture"], furnitureArgs)
-- 	end
-- 	print(game:GetService("HttpService"):JSONEncode(dataService.data[player.Name]))
-- end

-- local placeFurnitureRemoteEvent = replicatedStorage:WaitForChild("PlaceFurnitureRemoteEvent", math.huge)
-- placeFurnitureRemoteEvent.OnServerEvent:Connect(function(player, furnitureArgs)
-- 	FurnitureService.placeFurniture(player, furnitureArgs)
-- end)

return FurnitureService
