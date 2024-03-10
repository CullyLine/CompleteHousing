local DataService = {}

local httpService = game:GetService("HttpService")

DataService.data = {}
DataService.savedData = {}

game.Players.PlayerAdded:Connect(function(player)
	
	
	-- -- Grab data
	-- local response = httpService:GetAsync(url)
	-- DataService.data[player.Name] = httpService:JSONDecode(response)
	
	-- DataService.savedData[player.Name] = deepCopy(DataService.data[player.Name])
	
	-- -- Place saved furniture
	-- local origin = workspace.Origin.Position
	-- for _, furnitureArgs in pairs(DataService.data[player.Name]["Furniture"]) do
	-- 	local furnitureModel = game.ReplicatedStorage.FurnitureModels:FindFirstChild(furnitureArgs.FurnitureID):Clone()
	-- 	local newCFrame = CFrame.new(Vector3.new(origin.X + furnitureArgs["PositionOffsetX"], origin.Y + furnitureArgs["PositionOffsetY"], origin.Z + furnitureArgs["PositionOffsetZ"]))
	-- * CFrame.Angles(math.rad(furnitureArgs["RotationOffsetX"]), math.rad(furnitureArgs["RotationOffsetY"]), math.rad(furnitureArgs["RotationOffsetZ"]))
	-- 	furnitureModel:SetPrimaryPartCFrame(newCFrame)
	-- 	furnitureModel.Parent = workspace
	-- 	furnitureModel.Primary.SurfaceGui.ImageLabel.ImageTransparency = 1
	-- end
	
	-- Auto-save
	-- task.spawn(function()
	-- 	local i = 0
	-- 	while (task.wait(10)) do
	-- 		DataService.data[player.Name]["Cash"] -= 1
	-- 		local changes = recursiveCompare(DataService.data[player.Name], DataService.savedData[player.Name])
			
	-- 		print(httpService:JSONEncode(changes))
			
	-- 		local json = httpService:JSONEncode(DataService.data[player.Name])
	-- 		local response = httpService:PostAsync(secret.Save, json, Enum.HttpContentType.ApplicationJson, false, {["Secret"] = secret.Secret})
			
	-- 		for _, furnitureTable in pairs(DataService.data[player.Name]["Furniture"]) do
	-- 			furnitureTable.New = false
	-- 		end
			
	-- 		print("Saved!", i)
	-- 		i += 1
			
	-- 		DataService.savedData[player.Name] = deepCopy(DataService.data[player.Name])
	-- 	end
	-- end)
end)

return DataService
