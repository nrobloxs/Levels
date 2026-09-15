local ReplicatedStorage = game:GetService("ReplicatedStorage")
local dataservicetyped = require(ReplicatedStorage.Packages.dataservicetyped)

local Template = {
	Level = 1,
	XP = 0,
}

return dataservicetyped({
	template = Template,
	resetData = true,
})
