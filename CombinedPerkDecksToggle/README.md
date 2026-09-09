# All Perk Decks Configurable (PAYDAY 2 Diesel 3.0 / 64-bit)

Grants the bonuses of multiple perk decks at once, with per-deck on/off switches.

## How it works

Hooks `lib/managers/upgradesmanager` (`init`/`_setup`/`load`) and `lib/states/menutitlescreenstate` (`at_enter`) via `PostHook` — no vanilla functions are overwritten, so it plays nice with other menu mods.

Edit the `deck_config` table at the top of `ThisIsSoHard.lua`: `true` = deck bonuses apply, `false` = ignored. One tradeoff is deliberately never granted: Anarchist's `player_health_decrease_1` (halves max HP).

## Install

Requires SuperBLT 64-bit (Diesel 3.0): `PAYDAY 2/mods/CombinedPerkDecksToggle/` containing `mod.txt` + `ThisIsSoHard.lua`.

1. Copy the `CombinedPerkDecksToggle` folder to `PAYDAY 2/mods/`.
2. Edit `deck_config` in `ThisIsSoHard.lua` to taste.
3. Enable in Mods menu, restart if prompted.

Proton/Linux: `WINEDLLOVERRIDES="wsock32=n,b" %command%`
