local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local state = ReplicatedStorage:WaitForChild("FifthGuestState")
local gui = Instance.new("ScreenGui")
gui.Name = "FifthGuestHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local panel = Instance.new("TextLabel")
panel.Size = UDim2.new(0.9, 0, 0, 180)
panel.Position = UDim2.new(0.05, 0, 0, 8)
panel.BackgroundColor3 = Color3.fromRGB(20, 23, 30)
panel.BackgroundTransparency = 0.15
panel.TextColor3 = Color3.fromRGB(240, 240, 230)
panel.Font = Enum.Font.Gotham
panel.TextSize = 17
panel.TextWrapped = true
panel.Parent = gui

while gui.Parent do
	local seconds = math.max(0, math.ceil((state:GetAttribute("Deadline") or 0) - workspace:GetServerTimeNow()))
	local phase = state:GetAttribute("Phase") or "Waiting"
	local timer = if phase == "Waiting" then "" else string.format(" %d:%02d", math.floor(seconds / 60), seconds % 60)
	panel.Text = string.format("THE FIFTH GUEST | %s%s\nPlayers: %d | Required: %d%s\nYou: %s | %s\n%s\nEscaped: %d   Eliminated: %d   Remaining: %d\n%s",
		phase, timer, state:GetAttribute("PlayerCount") or 0, state:GetAttribute("MinimumPlayers") or 5,
		if state:GetAttribute("StudioTest") then " (Studio test)" else "",
		player:GetAttribute("Role") or "Lobby", player:GetAttribute("SurvivorState") or "Waiting",
		state:GetAttribute("Message") or "", state:GetAttribute("Escaped") or 0,
		state:GetAttribute("Eliminated") or 0, state:GetAttribute("Remaining") or 0,
		if phase == "Results" then state:GetAttribute("Result") or "" else "")
	task.wait(0.2)
end
