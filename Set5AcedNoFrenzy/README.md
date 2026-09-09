# Set 5 All Aced No Frenzy + All Weapon Mods (PAYDAY 2 Diesel 3.0 / 64-bit)

Two helpers. **Only Skill Set 5 is ever touched** — sets 1–4 and 6+ are left alone.

- **Ace Set 5 (no Frenzy)** — sets 89 skills to aced, Frenzy stays locked. Trees 1–14 get 46 points, tree 15 gets 34. Includes an unsuspend guard (Set 5's 678 points would otherwise count as suspended) and an optional network spoof so peers see your Switch 1 totals when Set 5 is selected (`spoof_enabled` in `set5_logic.lua`).
- **Give All Weapon Mods x999** — sets every weapon attachment to 999 and removes duplicates.

Use the buttons in **Options > Mod Options > Set 5 + Weapon Mods**, or the keybinds in **Options > Mod Keybinds** (both run in Main Menu only).

## Install

Requires SuperBLT 64-bit (Diesel 3.0): `PAYDAY 2/mods/Set5AcedNoFrenzy/` containing `mod.txt` + the `.lua` files.

1. Copy the `Set5AcedNoFrenzy` folder to `PAYDAY 2/mods/`.
2. Enable in Mods menu, restart if prompted.
3. In Main Menu, press the buttons or keybinds, verify (Skills > Set 5 / Blackmarket), then save (Options > Save or restart — the mod also calls `save_progress()` itself).

Proton/Linux: `WINEDLLOVERRIDES="wsock32=n,b" %command%`

## Files

- `set5.lua` / `set5_apply.lua` / `set5_logic.lua` — skill logic + spoof + unsuspend fix
- `weapons_apply.lua` / `weapons_logic.lua` — weapon mod logic
- `menu.lua` — Mod Options buttons
