pragma Singleton
import QtQuick
import Quickshell

// Central place for the two typefaces the shell uses:
// - `icon` for Material Symbols glyphs (system/UI icons)
// - `sans` for actual readable text (labels, clock, notification bodies, etc.)
// JetBrains Mono Nerd Font is still used in kitty and other terminal-facing
// config, just not for shell UI chrome anymore.
Singleton {
    readonly property string icon: "Material Symbols Rounded"
    readonly property string sans: "Inter"
}
