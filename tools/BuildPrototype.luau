-- OPTIONAL: paste this whole file into Studio's Command Bar in EDIT mode.
-- Creates only its own container; refuses to overwrite an existing one.
assert(not game:GetService("RunService"):IsRunning(), "Stop playtesting before building.")
assert(not workspace:FindFirstChild("FifthGuestPrototype"), "Prototype already exists; nothing changed.")
local model = Instance.new("Model")
model.Name = "FifthGuestPrototype"

local function part(name, position, size, color)
	local object = Instance.new("Part")
	object.Name = name
	object.Anchored = true
	object.Size = size
	object.Position = position
	object.Color = color or Color3.fromRGB(100, 105, 110)
	object.TopSurface = Enum.SurfaceType.Smooth
	object.Parent = model
	return object
end
local function marker(name, position, color)
	local object = part(name, position, Vector3.new(10, 1, 10), color)
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(200, 40)
	billboard.StudsOffset = Vector3.new(0, 5, 0)
	billboard.Parent = object
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextSize = 20
	label.Parent = billboard
end
-- Elevated to avoid intersecting a typical baseplate or existing ground.
local y = 100
part("ArenaFloor", Vector3.new(0, y, 0), Vector3.new(180, 2, 180))
for _, x in { -90, 90 } do part("Boundary", Vector3.new(x, y + 10, 0), Vector3.new(2, 20, 180)) end
for _, z in { -90, 90 } do part("Boundary", Vector3.new(0, y + 10, z), Vector3.new(180, 20, 2)) end
-- Short partitions allow paths around either end; this is a test arena, not the final house.
for _, x in { -35, 35 } do
	part("SightlineBreak", Vector3.new(x, y + 7, 0), Vector3.new(3, 14, 80))
end
marker("SurvivorSpawn", Vector3.new(-65, y + 2, -60), Color3.fromRGB(70, 140, 110))
marker("GhostSpawn", Vector3.new(65, y + 2, 60), Color3.fromRGB(140, 80, 110))

local function holdingRoom(name, center)
	part(name .. "Floor", center, Vector3.new(40, 2, 40))
	for _, x in { -20, 20 } do part(name .. "Wall", center + Vector3.new(x, 10, 0), Vector3.new(2, 20, 40)) end
	for _, z in { -20, 20 } do part(name .. "Wall", center + Vector3.new(0, 10, z), Vector3.new(40, 20, 2)) end
	part(name .. "Roof", center + Vector3.new(0, 21, 0), Vector3.new(42, 2, 42))
	marker(name, center + Vector3.new(0, 2, 0), Color3.fromRGB(80, 110, 145))
end
holdingRoom("LobbySpawn", Vector3.new(0, y, 280))
holdingRoom("GhostHold", Vector3.new(280, y, 0))
-- Neutral spawn affects only this prototype; existing spawn objects are untouched.
local spawn = Instance.new("SpawnLocation")
spawn.Name = "PrototypeLobbySpawn"
spawn.Anchored = true
spawn.Neutral = true
spawn.Duration = 0
spawn.Size = Vector3.new(6, 1, 6)
spawn.Position = Vector3.new(0, y + 3, 280)
spawn.Parent = model
model.Parent = workspace
print("[Fifth Guest] Prototype created. Save the place; map geometry does not sync to disk.")
