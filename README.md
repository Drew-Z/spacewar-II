# Space War II (Mobile Shooter Reference)

This repo targets a vertical space shooter inspired by the classic mobile Space War 2 era, rebuilt in Godot 4.6.1.

## Current Focus

- Vertical scrolling combat
- Simple ship movement and auto fire
- Two enemy types (scout, tank)
- Pickups for weapon level and bombs
- Lives + HP system
- Compact HUD and score tracking
- Result screen with key stats

## Run

```powershell
& 'D:\Development\Godot\Godot_v4.6.1-stable_win64.exe' --path 'D:\workspace4Cursor\game\spacewar II'
```

Headless smoke test:

```powershell
& 'D:\Development\Godot\Godot_v4.6.1-stable_win64_console.exe' --headless --path 'D:\workspace4Cursor\game\spacewar II' -s res://scripts/SmokeTest.gd
```

## Controls

- Move: `WASD` or Arrow Keys
- Fire: `Space`
- Bomb: `X`

## Key Files

- Battle logic: `scripts/NokiaBattle.gd`
- Player: `scripts/NokiaPlayer.gd`
- Enemy: `scripts/NokiaEnemy.gd`
- Pickups: `scripts/NokiaPickup.gd`
- HUD: `scripts/NokiaHUD.gd`
- Result: `scripts/NokiaResult.gd`

## GDD

See `docs/GDD.md` for the main design document.
