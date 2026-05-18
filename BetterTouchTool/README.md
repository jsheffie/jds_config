# BetterTouchTool Configuration

Canonical source for the BTT configuration on this machine. Use `make pull` to snapshot the current live state into this repo.

## Files

| File | Description |
|------|-------------|
| `triggers.json` | All triggers and their bound actions (exported via BTT web API) |
| `presets.json` | Preset metadata |
| `btt_user_variables.plist` | BTT user-defined variables |
| `com.hegenberg.BetterTouchTool.plist` | Full app preferences |
| `Makefile` | `make pull` to refresh everything from the running BTT instance |

## Presets

Two presets are configured — one per display. A "Display Configuration Changed" trigger auto-switches between them by detecting whether the LG Ultrawide is connected.

| Preset | Display | Resolution |
|--------|---------|------------|
| `Ultrawide` | LG Ultrawide | 3440 × 1440 |
| `Laptop` | MacBook Pro built-in | 3456 × 2234 |

Auto-switch script (runs on display connect/disconnect):
```bash
if system_profiler SPDisplaysDataType 2>/dev/null | grep -q "LG ULTRAWIDE"; then
    curl -s "http://127.0.0.1:63362/activate_preset/?sharedSecret=bttweb&preset_name=Ultrawide"
else
    curl -s "http://127.0.0.1:63362/activate_preset/?sharedSecret=bttweb&preset_name=Laptop"
fi
```

## Keyboard Shortcuts

All shortcuts are global (apply to every app).

### Hyper = Ctrl+Opt+Fn (all four arrow keys)

Window geometry accounts for SketchyBar (24px at top). All snap actions use
"Move & Resize Window" with explicit coordinates rather than BTT predefined
actions, so windows never overlap the bar.

| Shortcut | Action |
|----------|--------|
| Hyper + ← | Left half |
| Hyper + → | Right half |
| Hyper + ↑ | Top half |
| Hyper + ↓ | Bottom half |

### Ctrl+Opt

| Shortcut | Action |
|----------|--------|
| Ctrl+Opt + U | Top-left quarter |
| Ctrl+Opt + I | Top-right quarter |
| Ctrl+Opt + J | Bottom-left quarter |
| Ctrl+Opt + K | Bottom-right quarter |
| Ctrl+Opt + Return | Maximize (full screen below SketchyBar) |
| Ctrl+Opt + S | Shrink current window slightly |
| Ctrl+Opt + R | Screen recording |

### Window Geometry Reference

All coordinates are in points. Y=0 is top of screen. SketchyBar occupies y=0–24.

#### Ultrawide (3440 × 1440)

Top-anchored — "Top Left Corner → Top Left Corner of screen":

| Slot | X offset | Y offset | Width | Height |
|------|----------|----------|-------|--------|
| Full | 0 | -24 | 3440 | 1416 |
| Left half | 0 | -24 | 1720 | 1416 |
| Right half | 1720 | -24 | 1720 | 1416 |
| Top half | 0 | -24 | 3440 | 708 |
| Top-left quarter | 0 | -24 | 1720 | 708 |
| Top-right quarter | 1720 | -24 | 1720 | 708 |

Bottom-anchored — "Top Left Corner → Bottom Left Corner of screen":

| Slot | X offset | Y offset | Width | Height |
|------|----------|----------|-------|--------|
| Bottom half | 0 | 0 | 3440 | 708 |
| Bottom-left quarter | 0 | 0 | 1720 | 708 |
| Bottom-right quarter | 1720 | 0 | 1720 | 708 |

#### Laptop (3456 × 2234)

Top-anchored — "Top Left Corner → Top Left Corner of screen":

| Slot | X offset | Y offset | Width | Height |
|------|----------|----------|-------|--------|
| Full | 0 | -24 | 3456 | 2210 |
| Left half | 0 | -24 | 1728 | 2210 |
| Right half | 1728 | -24 | 1728 | 2210 |
| Top half | 0 | -24 | 3456 | 1105 |
| Top-left quarter | 0 | -24 | 1728 | 1105 |
| Top-right quarter | 1728 | -24 | 1728 | 1105 |

Bottom-anchored — "Top Left Corner → Bottom Left Corner of screen":

| Slot | X offset | Y offset | Width | Height |
|------|----------|----------|-------|--------|
| Bottom half | 0 | 0 | 3456 | 1105 |
| Bottom-left quarter | 0 | 0 | 1728 | 1105 |
| Bottom-right quarter | 1728 | 0 | 1728 | 1105 |

## Updating

BTT must be running with the web server enabled (Advanced → Webserver, port 63362, shared secret `bttweb`).

```sh
make pull
```

## Restoring

To restore the config on a new machine:

1. Install BetterTouchTool
2. Enable the web server (Advanced → Webserver, port `63362`, shared secret `bttweb`)
3. Import `triggers.json` via BTT → File → Import Preset
4. Copy plists back if needed:
   ```sh
   cp btt_user_variables.plist ~/Library/Application\ Support/BetterTouchTool/
   cp com.hegenberg.BetterTouchTool.plist ~/Library/Preferences/
   ```
