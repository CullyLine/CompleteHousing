-- FurnitureModels for previewing furniture before placing it.
local furnitureModels = game.ReplicatedStorage:WaitForChild("FurnitureModels")







-- local runService = game:GetService("RunService")
-- local userInputService = game:GetService("UserInputService")

-- local curFurnitureID = 1
-- local maxFurniture = #game.ReplicatedStorage.FurnitureModels:GetChildren()
-- local lastFurnitureID = maxFurniture
-- local nextFurnitureID = curFurnitureID + 1

-- local ghost = game.ReplicatedStorage.FurnitureModels:FindFirstChild(curFurnitureID):Clone()
-- ghost.Parent = workspace

-- local mouse = game.Players.LocalPlayer:GetMouse()
-- mouse.TargetFilter = ghost

-- local userRotation = Vector3.new(0, 0, 0)

-- local tweenService = game:GetService("TweenService")
-- local transitionTime = .3
-- local transitioning = false
-- local furnitureUI = game.Players.LocalPlayer.PlayerGui:WaitForChild("FurnitureUI").Frame.Frame


-- local function createViewportObject(model, viewportFrame : ViewportFrame)
-- 	local viewport = model:Clone()
-- 	local existingModel = viewportFrame:FindFirstChildWhichIsA("Model")
-- 	if (existingModel) then existingModel:Destroy() end
-- 	local bbCFrame, bbSize = viewport:GetBoundingBox()
-- 	viewport:SetPrimaryPartCFrame(CFrame.new(Vector3.new(0, -bbSize.Y/2, 10)))
-- 	bbCFrame, bbSize = viewport:GetBoundingBox()
-- 	local existingCamera = viewportFrame:FindFirstChildWhichIsA("Camera")
-- 	if (not existingCamera) then 
-- 		local camera = game.Workspace.CurrentCamera:Clone()
-- 		camera.CFrame = CFrame.new(Vector3.new(0, 0, 0), bbCFrame.Position)
-- 		viewportFrame.CurrentCamera = camera
-- 		camera.Parent = viewportFrame
-- 	end
	
-- 	viewport.Parent = viewportFrame
-- end

-- createViewportObject(ghost, furnitureUI.Current.ViewportFrame)
-- createViewportObject(game.ReplicatedStorage.FurnitureModels:FindFirstChild(nextFurnitureID), furnitureUI.Next.ViewportFrame)
-- createViewportObject(game.ReplicatedStorage.FurnitureModels:FindFirstChild(lastFurnitureID), furnitureUI.Last.ViewportFrame)

-- runService.RenderStepped:Connect(function(dt)
-- 	if (not ghost) then
-- 		return
-- 	end
	
-- 	if (not mouse.Target) then
-- 		return
-- 	end
	
-- 	local gridPos = Vector3.new(math.round(mouse.Hit.X), -7, math.round(mouse.Hit.Z))
-- 	local angles = CFrame.Angles(0, math.rad(userRotation.Y), 0)
-- 	ghost:SetPrimaryPartCFrame(CFrame.new(gridPos) * angles)
-- end) 

-- mouse.Button1Up:Connect(function()
-- 	if (not ghost) then
-- 		return
-- 	end
	
-- 	local furnitureArgs = {}
-- 	local origin = workspace.Origin.Position
-- 	furnitureArgs["PositionOffsetX"] = ghost.PrimaryPart.Position.X - origin.X
-- 	furnitureArgs["PositionOffsetY"] = ghost.PrimaryPart.Position.Y - origin.Y
-- 	furnitureArgs["PositionOffsetZ"] = ghost.PrimaryPart.Position.Z - origin.Z
-- 	furnitureArgs["RotationOffsetX"] = userRotation.X
-- 	furnitureArgs["RotationOffsetY"] = userRotation.Y
-- 	furnitureArgs["RotationOffsetZ"] = userRotation.Z
-- 	furnitureArgs["FurnitureID"] = ghost.Name
-- 	game.ReplicatedStorage.PlaceFurnitureRemoteEvent:FireServer(furnitureArgs)
-- end)

-- userInputService.InputEnded:Connect(function(input: InputObject, processed)
-- 	if (processed) then
-- 		return
-- 	end
	
-- 	if (input.KeyCode == Enum.KeyCode.E) then
-- 		userRotation += Vector3.new(0, 15, 0)
-- 	elseif (input.KeyCode == Enum.KeyCode.Q) then
-- 		userRotation += Vector3.new(0, -15, 0)
-- 	elseif (input.KeyCode == Enum.KeyCode.F) then
-- 		if (transitioning) then return end
-- 		if (ghost) then ghost:Destroy() ghost = nil end
		
-- 		transitioning = true
		
-- 		lastFurnitureID = curFurnitureID
		
-- 		curFurnitureID += 1
-- 		if (curFurnitureID >= maxFurniture) then
-- 			curFurnitureID = 1
-- 		end
		
-- 		nextFurnitureID = curFurnitureID + 1
-- 		if (nextFurnitureID >= maxFurniture) then
-- 			nextFurnitureID = 1
-- 		end
		
-- 		ghost = game.ReplicatedStorage.FurnitureModels:FindFirstChild(curFurnitureID):Clone()
-- 		mouse.TargetFilter = ghost
-- 		ghost.Parent = workspace
		
-- 		local last = tweenService:Create(furnitureUI.Last, TweenInfo.new(transitionTime, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {Position = UDim2.fromScale(.5, -.1), ImageTransparency = 1, Size = UDim2.fromScale(0, 0)})
-- 		last.Completed:Connect(function()
-- 			furnitureUI.Last.Position = UDim2.fromScale(.5, .1)
-- 			furnitureUI.Last.ImageTransparency = 0.5
-- 			furnitureUI.Last.Size = UDim2.fromScale(.15, .15)
-- 		end)
-- 		last:Play()

-- 		local current = tweenService:Create(furnitureUI.Current, TweenInfo.new(transitionTime, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {Position = UDim2.fromScale(.5, .1), ImageTransparency = .5, Size = UDim2.fromScale(0.15, 0.15)})
-- 		current.Completed:Connect(function()
-- 			furnitureUI.Current.Position = UDim2.fromScale(.5, .5)
-- 			furnitureUI.Current.ImageTransparency = 0
-- 			furnitureUI.Current.Size = UDim2.fromScale(.5, .5)
-- 		end)
-- 		current:Play()

-- 		local nextTween = tweenService:Create(furnitureUI.Next, TweenInfo.new(transitionTime, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {Position = UDim2.fromScale(.5, .5), ImageTransparency = 0, Size = UDim2.fromScale(0.5, 0.5)})
-- 		nextTween.Completed:Connect(function()
-- 			furnitureUI.Next.Position = UDim2.fromScale(.5, .9)
-- 			furnitureUI.Next.ImageTransparency = .5
-- 			furnitureUI.Next.Size = UDim2.fromScale(.15, .15)
-- 		end)
-- 		nextTween:Play()

-- 		local nextSlideInTween = tweenService:Create(furnitureUI.Next_SlideIn, TweenInfo.new(transitionTime, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {Position = UDim2.fromScale(.5, .9), ImageTransparency = 0.5, Size = UDim2.fromScale(0.15, 0.15)})
-- 		nextSlideInTween.Completed:Connect(function()
-- 			furnitureUI.Next_SlideIn.Position = UDim2.fromScale(.5, 1.1)
-- 			furnitureUI.Next_SlideIn.ImageTransparency = 1
-- 			furnitureUI.Next_SlideIn.Size = UDim2.fromScale(0, 0)
			
-- 			transitioning = false
			
-- 			createViewportObject(game.ReplicatedStorage.FurnitureModels:FindFirstChild(lastFurnitureID), furnitureUI.Last.ViewportFrame) 
-- 			createViewportObject(ghost, furnitureUI.Current.ViewportFrame) 
-- 			createViewportObject(game.ReplicatedStorage.FurnitureModels:FindFirstChild(nextFurnitureID), furnitureUI.Next.ViewportFrame)
-- 			createViewportObject(game.ReplicatedStorage.FurnitureModels:FindFirstChild(nextFurnitureID), furnitureUI.Next_SlideIn.ViewportFrame)
-- 		end)
-- 		nextSlideInTween:Play()
-- 	end
-- end)