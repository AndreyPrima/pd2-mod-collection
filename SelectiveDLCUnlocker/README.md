# Selective DLC Unlocker (PAYDAY 2 Diesel 3.0 / 64-bit)

> **Third-party mod, mirrored here for backup.** Original authors: SilentSeduction, updated by DiegoBellik (unknowncheats.me). Only use this with DLCs you own.

Unlocks DLCs selectively: per-DLC on/off toggles in **Options > Mod Options > Selective DLC Unlocker**. Technically it wraps the `_check_dlc_data` ownership check on the Steam/Epic/Windows DLC managers (`unlock.lua`, hook: `lib/tweak_data/...` via `lib/managers/dlcmanager`) and reports the toggled DLCs as owned.

## Install

Requires SuperBLT 64-bit (Diesel 3.0): `PAYDAY 2/mods/SelectiveDLCUnlocker/` containing `mod.txt` + `menu.lua` + `save.lua` + `unlock.lua` + `en.json`.

1. Copy the `SelectiveDLCUnlocker` folder to `PAYDAY 2/mods/`.
2. Enable in Mods menu, restart if prompted.
3. Toggle DLCs in Mod Options.

Proton/Linux: `WINEDLLOVERRIDES="wsock32=n,b" %command%`
