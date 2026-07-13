import QtQuick
import QtQuick.Layouts

SettingsPage {
    Text {
        text: "Built with Hyprland, Quickshell, and a matugen-driven color pipeline that re-themes the bar, terminal, and lock screen from your wallpaper."
        color: Theme.muted
        font.family: Fonts.sans
        font.pixelSize: 13
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }

    Text {
        text: "github.com/u61d/hypr-rice"
        color: Theme.secondary
        font.family: Fonts.sans
        font.pixelSize: 13
    }
}
