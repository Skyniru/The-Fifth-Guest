local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(ReplicatedStorage:WaitForChild("FifthGuestShared"):WaitForChild("Config"))
local Map = require(script.Parent:WaitForChild("Map"))

local previous = ReplicatedStorage:FindFirstChild("FifthGuestState")
if previous then
	error("FifthGuestState already exists. Check for duplicate Main scripts.")
end
local state = Instance.new("Folder")
state.Name = "FifthGuestState"
state.Parent = ReplicatedStorage
local minimum = if RunService:IsStudio() and Config.StudioTwoPlayerTest then 2 else Config.ProductionMinimum
local roster = {}
local ghost = nil
local active = false
local phase = "Waiting"
local deadline = 0
local headStartEnds = 0
local connections = {}
local rng = Random.new()

local function publish(nextPhase, seconds, message)
	phase = nextPhase
	deadline = workspace:GetServerTimeNow() + seconds
	state:SetAttribute("Phase", phase)
	state:SetAttribute("Deadline", deadline)
	state:SetAttribute("Message", message or "")
end

local function counts()
	local escaped, eliminated, remaining = 0, 0, 0
	for _, entry in roster do
		if entry.role == "Survivor" then
			if entry.status == "Escaped" then escaped += 1
			elseif entry.status == "Eliminated" then eliminated += 1
			else remaining += 1 end
		end
	end
	state:SetAttribute("Escaped", escaped)
	state:SetAttribute("Eliminated", eliminated)
	state:SetAttribute("Remaining", remaining)
	return escaped, eliminated, remaining
end

local function status(player, value)
	local entry = roster[player]
	if entry then entry.status = value end
	player:SetAttribute("SurvivorState", value)
	counts()
end

local function move(player, point, speed, offset)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if character and humanoid and humanoid.Health > 0 then
		humanoid.WalkSpeed = speed
		character:PivotTo(point.CFrame + Vector3.new(offset or 0, 4, 0))
		return true
	end
	return false
end

local function lobby(player)
	player:SetAttribute("Role", "Lobby")
	player:SetAttribute("SurvivorState", "Waiting")
	local points = Map.validate()
	if points then move(player, points.LobbySpawn, Config.SurvivorSpeed) end
end

local function finish(reason, aborted)
	if not active then return end
	active = false
	local escaped, _, remaining = counts()
	local result = if aborted then "Round cancelled: " .. reason
		elseif escaped == 0 then "Ghost victory: nobody escaped."
		elseif remaining == 0 and state:GetAttribute("Eliminated") == 0 then "Survivor victory: everyone escaped."
		else "Partial escape."
	state:SetAttribute("Result", result)
	publish("Results", Config.ResultsDuration, reason)
end

local function watchCharacter(player, character)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if not humanoid or player.Character ~= character then return end
	-- Resetting or respawning never restores an active participant.
	local entry = roster[player]
	if active and entry then
		if entry.role == "Ghost" then finish("Ghost character reset or replaced.", true)
		elseif entry.status == "Healthy" then status(player, "Eliminated") end
	end
	lobby(player)
	local connection = humanoid.Died:Connect(function()
		local current = roster[player]
		if not active or not current then return end
		if current.role == "Ghost" then finish("Ghost died or reset.", true)
		elseif current.status == "Healthy" then status(player, "Eliminated") end
	end)
	if connections[player] then connections[player]:Disconnect() end
	connections[player] = connection
end

local function joined(player)
	lobby(player)
	player.CharacterAdded:Connect(function(character) watchCharacter(player, character) end)
	if player.Character then task.spawn(watchCharacter, player, player.Character) end
end
Players.PlayerAdded:Connect(joined)
Players.PlayerRemoving:Connect(function(player)
	if active and roster[player] then
		if player == ghost then finish("Ghost disconnected; no victory awarded.", true)
		elseif roster[player].status == "Healthy" then status(player, "Eliminated") end
	end
	if connections[player] then connections[player]:Disconnect(); connections[player] = nil end
end)
for _, player in Players:GetPlayers() do joined(player) end

state:SetAttribute("MinimumPlayers", minimum)
state:SetAttribute("StudioTest", RunService:IsStudio() and Config.StudioTwoPlayerTest)
print("[Fifth Guest] " .. Config.SyncCheck)

while true do
	state:SetAttribute("PlayerCount", #Players:GetPlayers())
	local points, problem = Map.validate()
	if not active and phase ~= "Results" then
		local ready = {}
		for _, player in Players:GetPlayers() do
			local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then table.insert(ready, player) end
		end
		if not points then
			if state:GetAttribute("Message") ~= problem then warn("[Fifth Guest] " .. problem) end
			publish("Waiting", 0, problem)
		elseif #ready < minimum then
			publish("Waiting", 0, "Waiting for " .. minimum .. " ready players.")
		elseif phase ~= "Intermission" then
			publish("Intermission", Config.Intermission, "A new guest is arriving.")
		elseif workspace:GetServerTimeNow() >= deadline then
			-- Shuffle and lock this roster. Later joiners stay in the lobby.
			for i = #ready, 2, -1 do
				local j = rng:NextInteger(1, i)
				ready[i], ready[j] = ready[j], ready[i]
			end
			roster = {}
			ghost = ready[1]
			for i = 1, math.min(#ready, Config.MaxPlayers) do
				local player = ready[i]
				local role = if i == 1 then "Ghost" else "Survivor"
				roster[player] = { role = role, status = "Healthy" }
				player:SetAttribute("Role", role)
				player:SetAttribute("SurvivorState", "Healthy")
			end
			counts()
			state:SetAttribute("Result", "")
			active = true
			publish("Selection", Config.Selection, "Ghost: The Veiled prototype. Abilities arrive in Milestone 4.")
		end
	elseif active then
		local _, _, remaining = counts()
		if not points then finish(problem, true)
		elseif remaining == 0 then finish("All survivors eliminated or left.", false)
		elseif phase == "Selection" and workspace:GetServerTimeNow() >= deadline then
			for player, entry in roster do
				if entry.role == "Ghost" then move(player, points.GhostHold, 0)
				elseif entry.status == "Healthy" then
					if not move(player, points.SurvivorSpawn, Config.SurvivorSpeed, rng:NextInteger(-5, 5)) then status(player, "Eliminated") end
				end
			end
			headStartEnds = workspace:GetServerTimeNow() + Config.HeadStart
			publish("HeadStart", Config.MatchDuration, "Survivors: move out. Ghost releases in 10 seconds.")
		elseif phase == "HeadStart" and workspace:GetServerTimeNow() >= headStartEnds then
			move(ghost, points.GhostSpawn, Config.GhostSpeed)
			phase = "Match"
			state:SetAttribute("Phase", phase)
			state:SetAttribute("Message", "Round foundation test: explore or reset to test elimination. Objectives arrive in Milestone 3.")
		elseif (phase == "Match" or phase == "HeadStart") and workspace:GetServerTimeNow() >= deadline then
			for player, entry in roster do
				if entry.role == "Survivor" and entry.status == "Healthy" then status(player, "Eliminated") end
			end
			finish("Time expired. Survivors still inside were eliminated.", false)
		end
	elseif phase == "Results" and workspace:GetServerTimeNow() >= deadline then
		roster = {}
		ghost = nil
		for _, player in Players:GetPlayers() do lobby(player) end
		counts()
		publish("Waiting", 0, "")
	end
	task.wait(0.2)
end
