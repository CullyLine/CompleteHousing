-- Default saving / loading system using profile service.
-- Use this data service, or plug in your own existing data service!
local FurnitureDefaultDataService = {}

local playerService = game:GetService("Players")

local profileService = require(script:WaitForChild("ProfileService"))
local templateData = {["Furniture"] = {}}

local profileStore = profileService.GetProfileStore(
	"PayerFurniture" .. "1",
	templateData
)

local profiles = {} --[player] = profile 


---- STRUCTURE --------------------------------------------------------------------------------------
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
	local profile = profiles[player]
	if (profile) then
		return profile
	end
end

return FurnitureDefaultDataService