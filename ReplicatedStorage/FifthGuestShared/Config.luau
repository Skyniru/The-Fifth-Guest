-- Shared starting values. Test mode is additionally gated by RunService:IsStudio().
return table.freeze({
	MaxPlayers = 5,
	ProductionMinimum = 5,
	StudioTwoPlayerTest = true,
	Intermission = 20,
	Selection = 15,
	HeadStart = 10,
	MatchDuration = 8 * 60,
	ResultsDuration = 10,
	SurvivorSpeed = 12,
	GhostSpeed = 14,
	SyncCheck = "Fifth Guest sync check 1",
})
