import QtQuick
import QtQuick.Layouts

// Already owns a Flickable for its own scroll, so — like Wallpaper — this
// skips the shared SettingsPage wrapper and is its own root.
Flickable {
    id: root

    property var win: null

    anchors.fill: parent
    clip: true
    contentWidth: width
    contentHeight: keybindsFlow.implicitHeight

    ColumnLayout {
        id: keybindsFlow

        width: parent.width
        spacing: 18

        Repeater {
            model: [
                {
                    "section": "Apps & windows",
                    "items": [
                        {
                            "keys": ["Super", "Return"],
                            "desc": "Open terminal"
                        },
                        {
                            "keys": ["Super", "E"],
                            "desc": "Open file manager"
                        },
                        {
                            "keys": ["Super", "Space"],
                            "desc": "Toggle app launcher"
                        },
                        {
                            "keys": ["Super", "I"],
                            "desc": "Open this settings panel"
                        },
                        {
                            "keys": ["Super", "Q"],
                            "desc": "Close focused window"
                        },
                        {
                            "keys": ["Super", "Shift", "Q"],
                            "desc": "Exit Hyprland"
                        },
                        {
                            "keys": ["Super", "Shift", "V"],
                            "desc": "Toggle floating"
                        },
                        {
                            "keys": ["Super", "P"],
                            "desc": "Toggle pseudotile"
                        },
                        {
                            "keys": ["Super", "J"],
                            "desc": "Toggle split direction"
                        },
                        {
                            "keys": ["Super", "F"],
                            "desc": "Toggle fullscreen"
                        },
                        {
                            "keys": ["Super", "L"],
                            "desc": "Lock screen"
                        }
                    ]
                },
                {
                    "section": "Workspaces & focus",
                    "items": [
                        {
                            "keys": ["Super", "\u2190/\u2192/\u2191/\u2193"],
                            "desc": "Focus window in direction"
                        },
                        {
                            "keys": ["Super", "1-0"],
                            "desc": "Switch to workspace"
                        },
                        {
                            "keys": ["Super", "Shift", "1-0"],
                            "desc": "Move window to workspace"
                        },
                        {
                            "keys": ["Super", "S"],
                            "desc": "Toggle special workspace"
                        },
                        {
                            "keys": ["Super", "Ctrl", "S"],
                            "desc": "Move window to special workspace"
                        },
                        {
                            "keys": ["Super", "Tab"],
                            "desc": "Toggle workspace overview"
                        }
                    ]
                },
                {
                    "section": "Bar & menus",
                    "items": [
                        {
                            "keys": ["Super", "V"],
                            "desc": "Clipboard history"
                        },
                        {
                            "keys": ["Super", "N"],
                            "desc": "Notification center"
                        }
                    ]
                },
                {
                    "section": "Screenshots & media",
                    "items": [
                        {
                            "keys": ["Print"],
                            "desc": "Screenshot (area)"
                        },
                        {
                            "keys": ["Super", "Print"],
                            "desc": "Screenshot (full)"
                        },
                        {
                            "keys": ["Super", "Shift", "S"],
                            "desc": "Screenshot (area)"
                        },
                        {
                            "keys": ["Super", "Shift", "R"],
                            "desc": "Screen recording"
                        },
                        {
                            "keys": ["Super", "Shift", "C"],
                            "desc": "Color picker"
                        },
                        {
                            "keys": ["Super", "W"],
                            "desc": "Random wallpaper + re-theme"
                        },
                        {
                            "keys": ["Super", "G"],
                            "desc": "Toggle gamemode"
                        }
                    ]
                },
                {
                    "section": "Media keys",
                    "items": [
                        {
                            "keys": ["Vol +/-"],
                            "desc": "Adjust volume"
                        },
                        {
                            "keys": ["Mute"],
                            "desc": "Mute audio"
                        },
                        {
                            "keys": ["Bright +/-"],
                            "desc": "Adjust screen brightness"
                        }
                    ]
                },
                {
                    "section": "Mouse",
                    "items": [
                        {
                            "keys": ["Super", "L-drag"],
                            "desc": "Move window"
                        },
                        {
                            "keys": ["Super", "R-drag"],
                            "desc": "Resize window"
                        }
                    ]
                }
            ]

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: modelData.section
                    color: Theme.primary
                    font.family: Fonts.sans
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }

                Repeater {
                    model: modelData.items

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        RowLayout {
                            spacing: 4
                            Layout.preferredWidth: 190
                            Layout.alignment: Qt.AlignVCenter

                            Repeater {
                                model: modelData.keys

                                // === 3D keycap widget ===
                                Rectangle {
                                    id: keyCap

                                    readonly property real bw: 1
                                    readonly property real extraBottom: 2

                                    implicitWidth: keyFace.implicitWidth + bw * 2
                                    implicitHeight: keyFace.implicitHeight + bw * 2 + extraBottom
                                    radius: 7
                                    color: Qt.rgba(Theme.mantle.r, Theme.mantle.g, Theme.mantle.b, 0.95)

                                    Rectangle {
                                        id: keyFace

                                        implicitWidth: keyLabel.implicitWidth + 14
                                        implicitHeight: keyLabel.implicitHeight + 6
                                        radius: 6
                                        color: Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.95)

                                        anchors {
                                            fill: parent
                                            topMargin: keyCap.bw
                                            leftMargin: keyCap.bw
                                            rightMargin: keyCap.bw
                                            bottomMargin: keyCap.bw + keyCap.extraBottom
                                        }

                                        Text {
                                            id: keyLabel

                                            anchors.centerIn: parent
                                            text: modelData
                                            color: Theme.text
                                            font.family: Fonts.sans
                                            font.pixelSize: 11
                                            font.weight: Font.DemiBold
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            text: modelData.desc
                            color: Theme.muted
                            font.family: Fonts.sans
                            font.pixelSize: 12
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }
}
