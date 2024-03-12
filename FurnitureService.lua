local FurnitureService = {}

local furnitureObjectModule = require(script:WaitForChild("FurnitureObject"))

-- User is trying to place a new piece of this furniture at a certain CFrame.
FurnitureService.userPlaceFurniture = function(player : Player, furnitureModelName : string, cframe : CFrame)
	local extraArgs = {
		Load = false,
		cframe = cframe
	}

	-- Create an object for this furniture, and a model for it in the workspace.
	-- Generate a new GUID for the object, and other necessary data.
	local furnitureObject = furnitureObjectModule.new(furnitureModelName, extraArgs)


end

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
