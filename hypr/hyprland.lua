-- ~/.config/hypr/hyprland.lua
-- Hyprland 0.55+ Lua config for the hypr-rice setup.

local home = os.getenv("HOME") or ""

local fallback_colors = {
  base = "#1e1e2e",
  mantle = "#181825",
  surface = "#313244",
  surface_high = "#45475a",
  text = "#cdd6f4",
  muted = "#9399b2",
  primary = "#cba6f7",
  secondary = "#89b4fa",
  tertiary = "#f5c2e7",
  green = "#a6e3a1",
  yellow = "#f9e2af",
  red = "#f38ba8",
}

local ok, generated_colors = pcall(dofile, home .. "/.config/hypr/colors.lua")
local colors = ok and generated_colors or fallback_colors

local function rgba(hex, alpha)
  return "rgba(" .. hex:gsub("#", "") .. alpha .. ")"
end

local terminal = "kitty"
local file_manager = "nautilus"
local menu = "qs -c hypr-rice ipc call hypr-rice toggleDashboard"
local quickshell = "quickshell --config hypr-rice --daemonize"

hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = "auto",
})

hl.on("hyprland.start", function()
  hl.exec_cmd("swww-daemon")
  hl.exec_cmd("~/.config/hypr/scripts/wallpaper.sh")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
  hl.exec_cmd("wl-paste --watch cliphist store")
  hl.exec_cmd("hyprctl setcursor catppuccin-mocha-dark-cursors 24")
  hl.exec_cmd("hyprpm reload -n")
  -- Start Quickshell after the compositor is ready (needs --daemonize to stay alive).
  hl.timer(function()
    hl.exec_cmd(quickshell)
  end, { timeout = 200, type = "oneshot" })
  -- Plugin keys are registered only after hyprpm reload finishes.
  hl.timer(apply_plugin_config, { timeout = 500, type = "oneshot" })
end)

local function is_plugin_loaded(name)
  if type(hl.get_loaded_plugins) ~= "function" then
    return false
  end
  for _, plugin in ipairs(hl.get_loaded_plugins()) do
    if plugin.name == name then
      return true
    end
  end
  return false
end

function apply_plugin_config()
  local plugins = {}

  if is_plugin_loaded("dynamic-cursors") then
    plugins["dynamic-cursors"] = {
      enabled = true,
      mode = "stretch",
      threshold = 2,
      stretch_factor = 1.2,
    }
  end

  if is_plugin_loaded("hyprexpo") then
    plugins.hyprexpo = {
      columns = 3,
      gap_size = 5,
      bg_col = "rgb(111111)",
      workspace_method = "center current",
    }
  end

  if next(plugins) then
    hl.config({ plugin = plugins })
  end
end

hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "catppuccin-mocha-dark-cursors")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "catppuccin-mocha-dark-cursors")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 12,
    border_size = 2,
    col = {
      active_border = {
        colors = {
          rgba(colors.primary, "ee"),
          rgba(colors.tertiary, "ee"),
          rgba(colors.secondary, "ee"),
        },
        angle = 45,
      },
      inactive_border = rgba(colors.surface_high, "aa"),
    },
    layout = "dwindle",
    resize_on_border = true,
    allow_tearing = false,
  },

  decoration = {
    rounding = 14,
    active_opacity = 1.0,
    inactive_opacity = 0.92,
    shadow = {
      enabled = true,
      range = 25,
      render_power = 3,
      color = "rgba(11111baa)",
    },
    blur = {
      enabled = true,
      size = 8,
      passes = 3,
      vibrancy = 0.18,
      new_optimizations = true,
      ignore_opacity = true,
      xray = true,
    },
  },

  animations = {
    enabled = true,
  },

  input = {
    kb_layout = "us",
    follow_mouse = 1,
    sensitivity = 0,
    touchpad = {
      natural_scroll = true,
      tap_to_click = true,
    },
  },

  dwindle = {
    preserve_split = true,
  },

  master = {
    new_status = "master",
  },

  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    animate_manual_resizes = true,
    animate_mouse_windowdragging = true,
    enable_swallow = true,
    swallow_regex = "^(kitty)$",
  },
})

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})

hl.gesture({
  fingers = 3,
  direction = "up",
  action = "special",
  workspace_name = "magic",
})

hl.curve("easeOutExpo", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("easeOutBack", { type = "bezier", points = { { 0.34, 1.56 }, { 0.64, 1 } } })
hl.curve("smoothIn", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1 } } })
hl.curve("smoothOut", { type = "bezier", points = { { 0.36, 0 }, { 0.66, -0.56 } } })
hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "easeOutExpo", style = "popin 80%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "easeOutBack", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "smoothOut", style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "easeOutExpo" })
hl.animation({ leaf = "fade", enabled = true, speed = 6, bezier = "smoothIn" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 4, bezier = "smoothIn" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 4, bezier = "smoothOut" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 6, bezier = "smoothIn" })
hl.animation({ leaf = "border", enabled = true, speed = 8, bezier = "linear" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "linear", style = "loop" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "easeOutExpo", style = "slidefadevert 15%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "overshot", style = "slidevert" })
hl.animation({ leaf = "layers", enabled = true, speed = 5, bezier = "easeOutExpo", style = "slide" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 5, bezier = "easeOutBack", style = "popin 80%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 4, bezier = "smoothOut", style = "popin 80%" })

hl.layer_rule({ name = "rofi-blur", match = { namespace = "rofi" }, blur = true, ignore_alpha = 1 })

hl.layer_rule({ name = "quickshell-bar-blur", match = { namespace = "hypr-rice-bar" }, blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ name = "quickshell-bar-animate", match = { namespace = "hypr-rice-bar" }, animation = "slide" })

hl.window_rule({ name = "kitty-opacity", match = { class = "^(kitty)$" }, opacity = "0.92 0.85" })
hl.window_rule({ name = "pavucontrol-float", match = { class = "^(pavucontrol)$" }, float = true, size = "800 600" })
hl.window_rule({ name = "network-editor-float", match = { class = "^(nm-connection-editor)$" }, float = true })

local mod = "SUPER"

hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind(mod .. " + E", hl.dsp.exec_cmd(file_manager))
hl.bind(mod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + V", hl.dsp.exec_cmd("qs -c hypr-rice ipc call hypr-rice toggleClipboard"))
hl.bind(mod .. " + N", hl.dsp.exec_cmd("qs -c hypr-rice ipc call hypr-rice toggleNotificationCenter"))
hl.bind(mod .. " + I", hl.dsp.exec_cmd("qs -c hypr-rice ipc call hypr-rice toggleSettings"))
hl.bind(mod .. " + P", hl.dsp.window.pseudo())
hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpaper.sh"))
hl.bind(mod .. " + G", hl.dsp.exec_cmd("~/.config/hypr/scripts/gamemode.sh"))
hl.bind(mod .. " + TAB", hl.dsp.exec_raw("hyprexpo:expo toggle"))

hl.bind(mod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "down" }))

for i = 1, 10 do
  local key = tostring(i % 10)
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh area"))
hl.bind(mod .. " + CTRL + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("PRINT", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh area"))
hl.bind(mod .. " + PRINT", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh full"))
hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenrecord.sh"))
hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("~/.config/hypr/scripts/colorpicker.sh"))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh up"),
  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh down"),
  { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh mute"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("~/.config/hypr/scripts/brightness.sh up"),
  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("~/.config/hypr/scripts/brightness.sh down"),
  { locked = true, repeating = true })
