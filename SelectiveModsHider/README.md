# Selective Mods Hider (PAYDAY 2 Diesel 3.0 / 64-bit)

> **Third-party mod, mirrored here for backup.** Original author: DiegoBellik (unknowncheats.me).

Controls which of your installed mods are advertised to other players in a lobby. Per-mod on/off toggles in **Options > Mod Options > Selective Mods Hider**; new mods default to hidden. Technically it filters `MenuCallbackHandler:build_mods_list`, which feeds `NetworkPeer:synced_mods()` (the lobby "Installed Mods" list).

## Install

Requires SuperBLT 64-bit (Diesel 3.0): `PAYDAY 2/mods/SelectiveModsHider/` containing `mod.txt` + `main.lua` + `hook.lua` + `menu.lua` + `en.json`. Only `main.lua` is hooked (`lib/managers/menumanager`); it loads the rest via `dofile` in order.

1. Copy the `SelectiveModsHider` folder to `PAYDAY 2/mods/`.
2. Enable in Mods menu, restart if prompted.
3. Toggle mods in Mod Options (settings persist to `SelectiveModsHider.json` in the BLT save path).

Proton/Linux: `WINEDLLOVERRIDES="wsock32=n,b" %command%`
