local FurnitureObject = {}
FurnitureObject.__index = FurnitureObject

function FurnitureObject.new(args)
    local self = setmetatable({}, FurnitureObject)
    
    self.ModelInstance = nil

    if (args) then
        self.FurnitureModelName = args.FurnitureModelName
        self.GUID = args.GUID
    end

    return self
end

-- Add your methods and properties here


return FurnitureObject