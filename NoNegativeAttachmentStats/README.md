# No Negative Attachment Stats + Ammo x5 (PAYDAY 2 Diesel 3.0 / 64-bit)

Two tweaks, both applied at tweak-data init via `PostHook`:

- `NoNegativeAttachments.lua` (hook: `lib/tweak_data/weaponfactorytweakdata`) — flips negative attachment stats into bonuses: flat `-X` becomes `+X`, sub-1.0 multipliers are reflected above 1.0 (`0.9` → `1.1`), and above-1.0 recoil/spread multipliers are reflected below 1.0. Non-stat keys (`ammo_offset`, `sort_number`) are never touched.
- `AmmoX5.lua` (hook: `lib/tweak_data/weapontweakdata`) — multiplies total ammo (`AMMO_MAX`) and ammo pickup (`AMMO_PICKUP`) by 5 for every weapon. Weapons with a zero pickup range get a small one enabled first (2–4% of max), otherwise the multiplier would have no effect. Tweak `AMMO_MULT` at the top of the file to change the factor.

## Install

Requires SuperBLT 64-bit (Diesel 3.0): `PAYDAY 2/mods/NoNegativeAttachmentStats/` containing `mod.txt` + both `.lua` files.

1. Copy the `NoNegativeAttachmentStats` folder to `PAYDAY 2/mods/`.
2. Enable in Mods menu, restart if prompted.

Proton/Linux: `WINEDLLOVERRIDES="wsock32=n,b" %command%`
