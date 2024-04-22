-- Example usage of using Furniture Service in a real environment:
local houses = workspace:WaitForChild("Houses")
local furnitureService = require(game:GetService("ServerScriptService"):WaitForChild("Main"):WaitForChild("FurnitureService"))


---- STRUCTURE --------------------------------------------------------------
game.Players.PlayerRemoving:Connect(function(player)
    -- Look for the player's house.
    for _, house in pairs(houses:GetChildren()) do
        local ownerValueObject : StringValue = house:WaitForChild("Owner")
        if (ownerValueObject.Value == player.Name) then
            ownerValueObject.Value = ""

            -- Remove all this player's furniture.

            -- Make claim part visible again.
            house.Claim.Transparency = 0
            house.Claim.SurfaceGui.Enabled = true
            break
        end
    end
end)

for _, house in pairs(houses:GetChildren()) do
    local ownerValueObject : StringValue = house:WaitForChild("Owner")
    local claim : BasePart = house:WaitForChild("Claim")
    claim.Touched:Connect(function(hit)
        -- See if someone already owns it.
        if (ownerValueObject.Value ~= "") then
            return
        end

        -- See if it's a player touching it.
        local player = game.Players:GetPlayerFromCharacter(hit.Parent)
        if (not player) then
            return
        end

        -- See if the touching player already owns a house.
        for _, house in pairs(houses:GetChildren()) do
            local ownerValueObject : StringValue = house:WaitForChild("Owner")
            if (ownerValueObject.Value == hit.Parent.Name) then
                return
            end
        end
        
        -- Claim the house.
        ownerValueObject.Value = player.Name

        -- Imagine a cubic region in your head,
        -- point1 being the bottom left corner of the cube,
        -- point2 being the top right corner of the cube.
        -- This is what the build region is.
        -- The build region is the region where the player can place furniture.
        -- It's very similar to cube selection on the minecraft plugin "WorldEdit" if you need a visual reference!
        -- Also, Region3 cannot have a rotation!
        local centerPosition = house.Origin.Position
        local desiredSize = Vector3.new(50, 50, 50)
        local point1 = centerPosition - desiredSize / 2
        local point2 = centerPosition + desiredSize / 2
        local newBuildRegion = Region3.new(point1, point2)
        furnitureService.changePlayerBuildRegion(player, newBuildRegion)

        -- Change the player's origin of their house, plot, etc.
        -- Used for placing furniture in the right location, and saving accurately.
        furnitureService.changePlayerOrigin(player, centerPosition)

        -- Make claim part invisible.
        house.Claim.Transparency = 1
        house.Claim.SurfaceGui.Enabled = false

        -- Place the players saved furniture in their newly claimed house.
        furnitureService.loadFurniture(player)
    end)
end