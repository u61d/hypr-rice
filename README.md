# Your Hyprland Rice — Lua + Quickshell eye-candy build

A hand-built Hyprland 0.55+ setup for Arch, tuned for heavy animation, a
Quickshell bar built from scratch, and wallpaper-driven colors via matugen.

## What's in here

| Path | Purpose |
|---|---|
| `hypr/hyprland.lua` | Main compositor config: input, keybinds, layout, blur, Lua animation curves, layer rules, and plugin reload |
| `hypr/hyprlock.conf` | Lock screen — blurred screenshot background, clock, animated input field |
| `hypr/hypridle.conf` | Idle daemon — dim → lock → dpms off → suspend timeline |
| `hypr/scripts/wallpaper.sh` | Picks a random wallpaper, generates theme colors with matugen, and animates the transition via `swww` |
| `hypr/scripts/gamemode.sh` | `Super+G` toggle that disables costly blur/shadow/gaps/animations for games |
| `hypr/scripts/overview.sh` | `Super+Tab` overview dispatcher wrapper for Hyprspace / hyprexpo-style plugins |
| `quickshell/hypr-rice/` | Custom Quickshell bar modules: workspaces, active window, Cava, clock, tray, audio, network, CPU, memory, notifications, power |
| `rofi/config.rasi` | App launcher theme (blurred, rounded, animated via Hyprland layer rules) |
| `swaync/` | Notification center config + CSS |
| `kitty/kitty.conf` | Terminal colors + transparency |
| `cava/config` + `quickshell/hypr-rice/scripts/cava.sh` | Live audio visualizer streamed into the Quickshell center module |
| `install.sh` | Installs packages and copies configs into `~/.config` (backs up anything existing) |

## Install

```bash
tar xf hypr-rice.tar.gz
cd hypr-rice
chmod +x install.sh
./install.sh
```

Then drop a few wallpapers into `~/Pictures/Wallpapers` before your first login —
`Super+W` will cycle through them with an animated transition anytime.

## Where the "eye-candy" actually lives

- **Lua animation declarations in `hyprland.lua`** — custom bezier curves (`easeOutExpo`,
  `easeOutBack`, `overshot`) drive window open/close, workspace switches
  (slide+fade), and an animated rotating gradient border (`borderangle`, loop).
- **`blur` + Lua `hl.layer_rule(...)`** — blur is applied to windows, rofi,
  the Quickshell bar, and notifications.
- **swww transitions** — wallpaper changes animate with a `grow` transition
  instead of just cutting.
- **matugen theme generation** — wallpaper changes also rewrite
  `~/.config/hypr/colors.lua` and `~/.config/quickshell/hypr-rice/Theme.qml`.
- **Quickshell module animations** — workspace state, hover states, module
  colors, and widths animate inside the bar itself.
- **Hyprspace overview** — the installer attempts to install the Hyprspace
  overview plugin via `hyprpm`; `Super+Tab` opens it if the dispatcher is
  available.
- **hyprlock** — the lock screen blurs a live screenshot of your desktop
  rather than showing a flat color.

## Keybinds added for the heavy build

- `Super+G` — gamemode toggle.
- `Super+Tab` — workspace overview plugin wrapper.
- `Super+W` — random wallpaper + animated transition + regenerated colors.

## Easy things to change first

- **Color scheme**: drop wallpapers into `~/Pictures/Wallpapers` and hit
  `Super+W`; matugen generates matching Hyprland and Quickshell colors.
- **Animation speed**: the `speed` value in each `hl.animation(...)` call in
  `hyprland.lua` is speed (higher = slower). Try dropping `windows` from
  `5` to `3` for snappier feel, or push it to `8` for more dramatic motion.
- **Bar layout**: `quickshell/hypr-rice/Bar.qml` wires the modules together;
  individual modules are separate QML files.

## About the cava visualizer

It runs as a persistent process (`quickshell/hypr-rice/scripts/cava.sh`) that
Quickshell reads line-by-line, so it updates live rather than polling.
If it shows nothing: check `pactl info` to confirm PipeWire/PulseAudio is
running, or try setting `source` in `cava/config` to a specific monitor name
from `pactl list sources short`. Bar count is set by `bars = 12` in
`cava/config` — more bars = finer resolution but needs more horizontal space
in the bar.

## Notes

Hyprland plugins are native `.so` files loaded into the compositor. This rice
uses Hyprspace as a best-effort overview plugin because it is currently the
more reliable overview path than hyprexpo. The fallback wrapper keeps the
desktop usable even if the plugin fails to build for a specific Hyprland release.
