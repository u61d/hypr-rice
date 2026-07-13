import QtQuick
import QtQuick.Layouts
import Quickshell

SettingsPage {
    Text {
        text: "Colors are generated automatically from your wallpaper via matugen — pick a new one in the Wallpaper tab to re-theme everything."
        color: Theme.muted
        font.family: Fonts.sans
        font.pixelSize: 13
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }

    SettingsSection {
        title: "PALETTE"

        GridLayout {
            columns: 4
            columnSpacing: 12
            rowSpacing: 14
            Layout.fillWidth: true

            Repeater {
                model: [
                    {
                        "name": "base",
                        "c": Theme.base
                    },
                    {
                        "name": "mantle",
                        "c": Theme.mantle
                    },
                    {
                        "name": "surface",
                        "c": Theme.surface
                    },
                    {
                        "name": "surfaceHigh",
                        "c": Theme.surfaceHigh
                    },
                    {
                        "name": "text",
                        "c": Theme.text
                    },
                    {
                        "name": "muted",
                        "c": Theme.muted
                    },
                    {
                        "name": "primary",
                        "c": Theme.primary
                    },
                    {
                        "name": "secondary",
                        "c": Theme.secondary
                    },
                    {
                        "name": "tertiary",
                        "c": Theme.tertiary
                    },
                    {
                        "name": "green",
                        "c": Theme.green
                    },
                    {
                        "name": "yellow",
                        "c": Theme.yellow
                    },
                    {
                        "name": "red",
                        "c": Theme.red
                    }
                ]

                ColumnLayout {
                    spacing: 6

                    Rectangle {
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 48
                        radius: 12
                        color: modelData.c
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.08)
                    }

                    Text {
                        text: modelData.name
                        color: Theme.text
                        font.family: Fonts.sans
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: {
                            const c = modelData.c;
                            const hex = function hex(v) {
                                return Math.round(v * 255).toString(16).padStart(2, "0");
                            };
                            return "#" + hex(c.r) + hex(c.g) + hex(c.b);
                        }
                        color: Theme.muted
                        font.family: Fonts.sans
                        font.pixelSize: 11
                    }
                }
            }
        }
    }

    SettingsSection {
        title: "BEHAVIOR"

        SettingsToggle {
            label: "Hyprland animations"
            description: "Persisted to ~/.config/hypr-rice/settings.json — re-applied automatically every time the shell starts, so this actually sticks now."
            checked: Settings.options.hyprlandAnimations
            onToggled: function(value) {
                Settings.options.hyprlandAnimations = value;
                Quickshell.execDetached(["hyprctl", "keyword", "animations:enabled", value ? "1" : "0"]);
            }
        }
    }
}
