-- Default saving / loading system using profile service.
-- Use this data service, or plug in your own existing data service!

-- Furniture is saved in JSON format.
-- {["Furniture"] = 
--    {[GUID] = {         -- GUID is a STRING unique identifier for each piece of furniture, generated using httpService:GenerateGUID()
--     FurnitureModelName = STRING, -- Name of the furniture model.
--     PositionOffsetX = NUMBER,    -- X position offset from the origin of the player's plot.
--     PositionOffsetY = NUMBER,    -- Y position offset from the origin of the player's plot.
--     PositionOffsetZ = NUMBER,    -- Z position offset from the origin of the player's plot.
--     RotationOffsetY = NUMBER,    -- Y rotation offset in degrees.
--    }
-- }

-- If you would like to use your OWN existing data service for saving / loading furniture data (requires some programming knowledge),
-- UNCOMMENT the lines in the custom data service block, DELETE / COMMENT all lines in the default data service block.
-- Then, you can use your own data service in the functions below to grab the player's furniture data.
-- If you have your own dataservice module, you could require it here, and use it in the functions below,
-- to grab the player's furniture data.
-- For me, my data service would require I grab the player's profile, and return profile["Data].
-- My furniture system will handle the rest of the work once I have your profile!
-- CUSTOM DATA SERVICE ---------------------------------------------------------------------------------
-- local FurnitureDefaultDataService = {}
-- local dataService = require(game.ServerScriptService:WaitForChild("DataService")) -- Example module, Your own data service module.
-- function FurnitureDefaultDataService.GetProfile(player)
-- 	local profile = dataService:GetProfile(player) -- Example function, Your own function to get the player's profile.
-- 	if (profile) then
-- 		return profile["Data"]
-- 	end
-- end
-- return FurnitureDefaultDataService


-- -- DEFAULT DATA SERVICE -----------------------------------------------------------------------------
local FurnitureDefaultDataService = {}

local playerService = game:GetService("Players")

local profileService = require(script:WaitForChild("ProfileService"))
local templateData = {["Furniture"] = {}}

local profileStore = profileService.GetProfileStore(
	"PayerFurniture" .. "1",
	templateData
)

local profiles = {} --[player] = profile 

---- STRUCTURE ----
local function playerAdded(player)
	local profile = FurnitureDefaultDataService.LoadProfile(player)
end

task.spawn(function()
	for _, player in pairs(playerService:GetChildren()) do
		playerAdded(player)
	end
end)

game.Players.PlayerAdded:Connect(function(player)
	playerAdded(player)
end)

game.Players.PlayerRemoving:Connect(function(player)
	FurnitureDefaultDataService.RemoveProfile(player)
end)

game.Close:Connect(function()
	for player, profile in pairs(game.Players:GetChildren()) do
		FurnitureDefaultDataService.RemoveProfile(player)
	end
end)

function FurnitureDefaultDataService.LoadProfile(player)
	local profile = profileStore:LoadProfileAsync("Player_" .. player.UserId)
	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
		profile:ListenToRelease(function()
			profiles[player] = nil
			-- The profile could've been loaded on another Roblox server:
			player:Kick()
		end)
		if player:IsDescendantOf(playerService) == true then
			profiles[player] = profile
			-- A profile has been successfully loaded:
			--profileCreated(player, profile)
			return profile
		else
			-- Player left before the profile loaded:
			profile:Release()
		end
	else
		-- The profile couldn't be loaded possibly due to other
		-- Roblox servers trying to load this profile at the same time:
		player:Kick() 
	end
end

function FurnitureDefaultDataService.RemoveProfile(player)
	local profile = FurnitureDefaultDataService.GetProfile(player)
	if (profile) then
		profile:Release()
		profiles[player] = nil
	end
end

function FurnitureDefaultDataService.GetProfile(player)
	local profile = profiles[player]["Data"]
	if (profile) then
		return profile
	end
end

return FurnitureDefaultDataService