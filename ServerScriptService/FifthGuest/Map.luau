-- Minimal round-test arena, deliberately separate from the eventual house.
local Map = {}
local containerName = "FifthGuestPrototype"

function Map.validate()
	local model = workspace:FindFirstChild(containerName)
	if not model then
		return nil, "Run tools/BuildPrototype.luau in the Studio Command Bar first."
	end
	local points = {}
	for _, name in { "LobbySpawn", "SurvivorSpawn", "GhostHold", "GhostSpawn" } do
		local part = model:FindFirstChild(name)
		if not part or not part:IsA("BasePart") then
			return nil, "Missing BasePart: Workspace." .. containerName .. "." .. name
		end
		points[name] = part
	end
	return points, nil
end

return Map
