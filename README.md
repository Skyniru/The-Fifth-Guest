# The Fifth Guest — Milestone 1

Local implementation: lobby, shuffled one-ghost roster, up to four survivors, intermission, a selection placeholder, head start, eight-minute timer, elimination on death/reset/disconnect, results, and round cleanup. No combat, ritual gameplay, escape, ghost abilities, or spectating yet. The Veiled is a role placeholder, not a completed playable ghost selection. With no escape mechanic, normal rounds currently end in zero escapes.

Initial inspection found only an empty ServerScriptService directory. There was no Git repository, Rojo project, or local evidence of Script Sync. No Studio control tool is available. **Connection and runtime behavior still require your Studio checks.** No commit or push was made.

## Connect Studio and local files

1. Open or create a Baseplate place in Roblox Studio and save it. Open Explorer, Output, and the Command Bar from Studio's interface.
2. In Explorer create the three **Folder** instances listed below (create the surrounding folders where needed). Do not create duplicate folders if they already exist.
3. Right-click each Folder, select **Sync to…**, and choose its exact local directory below. In any conflict dialog, review the changes and choose **Keep Disk** for these newly supplied scripts. Preserve any unrelated Studio scripts first.

| Studio Folder | Local directory relative to this README |
| --- | --- |
| ServerScriptService > FifthGuest | ServerScriptService/FifthGuest |
| ReplicatedStorage > FifthGuestShared | ReplicatedStorage/FifthGuestShared |
| StarterPlayer > StarterPlayerScripts > FifthGuest | StarterPlayer/StarterPlayerScripts/FifthGuest |

The project root is `E:\PROYEKTO CODE\Develop game\The_Fifth_Guest`. Sync each named folder to the corresponding directory itself, not to its parent. Do not sync `tools`.

4. Confirm Studio shows Main as a server Script, Map and Config as ModuleScripts, and Hud as a LocalScript. Script Sync uses `.server.luau`, `.luau`, and `.local.luau` for those types. If Sync to… is absent, update Studio; do not install Rojo for this project.
5. Verify **both directions**: add a harmless comment to Config in Studio and confirm it appears in VS Code. Change that comment in VS Code and confirm it appears in Studio. Start a test and confirm Output prints `[Fifth Guest] Fifth Guest sync check 1`. Until both edits propagate, syncing is unverified.
6. Stop the test. Open `tools/BuildPrototype.luau` in VS Code, copy its entire contents, paste into Studio's Command Bar, and run once in edit mode. It creates `Workspace > FifthGuestPrototype` and refuses to overwrite that name. It never deletes existing objects. Save the place. This arena is temporary, not the full boarding house.
7. In the experience's published place settings set maximum server players to **5**. The script caps participation at five even if this setting is overlooked.

Official reference: https://create.roblox.com/docs/scripting/sync

## First playtest

Use Studio's multiplayer **Server & Clients** test with **2 clients**, then start. Menu labels can vary by Studio version. Testing with one client should remain in Waiting. Keyboard uses standard Roblox movement; touch uses Roblox's built-in movement/jump controls. This milestone has no additional action buttons.

- With one ready player: Waiting, required count 2, no round starts.
- With two: 20-second intermission, then exactly one Ghost and one Survivor. Roles remain fixed through the round. Selection lasts 15 seconds and provides no unfinished ghost choices.
- Survivors enter the arena first. Ghost waits in a closed room for 10 seconds, then appears across the arena. The eight-minute timer includes this head start.
- Reset the survivor: they are eliminated; results show 0 escaped, 1 eliminated, 0 remaining. After 10 seconds, everyone returns to the lobby and a new round can start.
- Reset or disconnect the ghost: results explicitly cancel the round, with no ghost victory.
- Disconnect the last active survivor: round ends and cleanup runs. Disconnect during intermission: countdown returns to Waiting if fewer than two remain.
- Add a client after role assignment: they stay in the lobby until the next round. Test this using Studio's add-client control if available, or a private published test with five starting players and spare capacity temporarily configured.
- Let the timer expire: survivors inside become eliminated and results appear. For faster testing, temporarily set MatchDuration to 30 in Config; restore it to `8 * 60` afterward. Test two consecutive rounds for stale state.
- Use Studio's device emulator to check the HUD and built-in touch controls on a phone-sized display.
- Remove/rename a required spawn in a saved copy: Output should warn with its path and the HUD should wait rather than starting a broken round. Restore it afterward.
- Published servers always require five even though StudioTwoPlayerTest is true. Confirm that gate in a private published test before release.

Server authority covers role assignment, time, participant state, results, and movement speed settings. No client request remotes exist in this milestone. Movement anti-cheat, chase state, revives, and objective validation belong to later milestones. Reset counts as elimination; it is not a revive. Results include disconnected survivors as eliminated. Cancelled rounds can show survivors remaining, because they are not awarded a loss.

## Working together and backups

The gameplay owner edits the synced script folders. The map owner builds the house and assets in Studio using Team Create. Publish/save the place, use Studio's Collaborate controls to grant your teammate edit access, and open the same shared place. Avoid simultaneous script edits through different sync connections; agree on ownership first.

GitHub will store scripts, this setup generator, and documentation after you initialize a repository and explicitly choose to commit/push. It does **not** automatically back up Studio geometry, lighting, sounds, imported assets, instance properties, or Team Create history. Save/publish those in Studio and keep deliberate `.rbxl`/`.rbxlx` place backups separately. Do not treat the generator as a backup of later map edits. Never store account tokens or credentials in scripts.

## Verification boundary and next step

Source paths and Script Sync extensions were checked against official documentation. The round code was reviewed locally for late joins, player removal, missing map markers, reset handling, and timer cleanup. Roblox Studio is unavailable here; no runtime test, successful sync, or multiplayer playtest is claimed. Run the checklist and report Output errors plus the failing step. Fix those before Milestone 2 (stamina, attacks, downing, revive, and touch action buttons).
