local FurnitureService = {}

local dataService = require(script.Parent.DataService)
local furnitureModels = script.Parent:WaitForChild("FurnitureModels")

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
