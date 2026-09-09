# 3x Favors Pre-Planning (PAYDAY 2 Diesel 3.0 / 64-bit)

Triples the Pre-Planning favor pool. Example: 10 favors -> 30 favors.
Money costs unchanged. Per-type limits (e.g. max 2 ammo bags) unchanged.

## How it works

Hooks `lib/managers/preplanningmanager` and multiplies only the total
from `PrePlanningManager:get_current_budget()` by 3.

That one function is the choke point for:
- `can_reserve_mission_element` (buy assets)
- `can_vote_on_plan` (escape / entry / vault votes)
- `execute_reserved_mission_elements` (server spawn, host-only)
- `get_current_preplan` (active plan list)
- favor UI counter

Works for all heists incl. DLC/custom, no tweak_data enumeration needed.

Big Bank achievement `bigbank_8` is preserved: it awards when you spend
>= vanilla total (10/30 counts, 30/30 also counts).

## Client / host

Host is authoritative. HOST must have the mod for extra favors to spawn.
Clients should also install it, otherwise their own `can_reserve` check
blocks requests over vanilla budget even if host would allow.

- Host + client both modded: works both ways.
- Host modded, client vanilla: vanilla client capped at vanilla favors.
- Host vanilla, client modded: host rejects + host execution caps. No effect.

This is the standard safe approach. Bypassing a vanilla host would need
network spoofing and risks desync/crash - not included.

## Install

Requires SuperBLT 64-bit Beta (Diesel 3.0):
`PAYDAY 2/mods/3xFavors/` containing `mod.txt` + `triple_favors.lua`.

1. Copy `3xFavors` folder to `PAYDAY 2/mods/`
2. Enable in Mods menu, restart if prompted
3. All lobby members use same version

Proton/Linux: `WINEDLLOVERRIDES="wsock32=n,b" %command%`

## Test

1. Solo: Big Bank preplanning should show 30 favors.
2. Buy >10 worth, start heist, verify assets spawn.
3. Lobby: host+client both modded, client buys over vanilla cap.
4. Check `mods/logs/` for `[3xFavors] loaded`.

## Change multiplier

Edit top of `triple_favors.lua`: `ThreeXFavors.MULT = 3`
