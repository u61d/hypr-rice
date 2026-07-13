import QtQuick
import QtQuick.Layouts
import Quickshell

SettingsPage {
    Text {
        text: "Live info from Quickshell. To rearrange or add custom modelines, edit the monitor block in hyprland.lua."
        color: Theme.muted
        font.family: Fonts.sans
        font.pixelSize: 13
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 10

        Repeater {
            model: Quickshell.screens

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 76
                radius: 14
                color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.6)
                border.width: 1
                border.color: Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.5)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 14

                    Rectangle {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        radius: 12
                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.14)

                        Text {
                            anchors.centerIn: parent
                            text: "\ue30a" // desktop_windows
                            color: Theme.primary
                            font.family: Fonts.icon
                            font.pixelSize: 22
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: modelData.name
                            color: Theme.text
                            font.family: Fonts.sans
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                        }

                        Text {
                            text: modelData.width + "\u00d7" + modelData.height + " \u00b7 scale " + (modelData.devicePixelRatio || 1).toFixed(2) + " \u00b7 position " + modelData.x + "," + modelData.y
                            color: Theme.muted
                            font.family: Fonts.sans
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }
    }
}
