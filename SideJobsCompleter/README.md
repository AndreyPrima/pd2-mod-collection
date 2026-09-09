# Side Jobs Completer (PAYDAY 2 Diesel 3.0 / 64-bit)

One button in **Options > Mod Options > Side Jobs Completer > Complete All Side Jobs** that completes + claims everything:

- Event jobs (`pda8/pda9/cg22/pda10`, community) — `managers.event_jobs`
- Raid jobs (`aru/jfr`) + future DLC via `managers.generic_side_jobs` registry
- Tango / Gage Spec Ops — `managers.tango`
- Legacy time-limited challenges — `managers.challenge`
- Safehouse trophies + daily — `managers.custom_safehouse`

Pure SuperBLT, no BeardLib. No hardcoded job IDs: iterates live managers, so new DLC jobs are covered.

## Install

Requires SuperBLT 64-bit (Diesel 3.0): `PAYDAY 2/mods/SideJobsCompleter/` containing `mod.txt` + `lua/main.lua`.

1. **BACKUP YOUR SAVE** (`%LOCALAPPDATA%/PAYDAY 2/saves/` or Steam userdata).
2. Copy `SideJobsCompleter` folder to `PAYDAY 2/mods/`.
3. Enable in Mods menu, restart if prompted. Use solo/offline or private lobby.
4. Options > Mod Options > Side Jobs Completer > Complete All Side Jobs > confirm.
5. Restart the game if Crime.net UI lags; progress persists via normal save.

Proton/Linux: `WINEDLLOVERRIDES="wsock32=n,b" %command%`

## Changelog

- **1.2** — Refactor: single shared objective helper, set-based collective prefill, honest "new transitions" counters (re-press reports 0 new), simpler manager collection. No behavior change.
- **1.1** — Menu fix: use standard 3-hook submenu (`NewMenu`/`BuildMenu`/`nodes.blt_options`) instead of a raw button on a non-existent menu (crashed `MenuHelper`).
- **1.0** — Initial release.

## Test

1. Solo main menu, press button, confirm dialog.
2. Crime.net Side Jobs all claimed; trophies + daily done.
3. Check `mods/logs/` for `[SJC]` lines.
4. Restart game, verify persistence. Re-press = no-op, no dupes.
